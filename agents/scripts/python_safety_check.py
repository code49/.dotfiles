#!/usr/bin/env python3
"""Antigravity PreToolUse hook: Python command safety validator.

Inspects Python command lines and scripts using AST analysis.
- Safe read-only inspection operations return {"decision": "allow"}.
- Destructive, file-modifying, or process-spawning calls return {"decision": "force_ask"}.
- Non-Python commands return {"decision": "ask"} to defer to settings.json rules.
"""

import ast
import json
import os
import shlex
import sys

DESTRUCTIVE_CALLS = {
    "remove", "unlink", "rmdir", "removedirs", "rmtree",
    "rename", "replace", "move", "system", "popen",
    "kill", "killpg", "chmod", "chown", "truncate",
    "write_text", "write_bytes", "copy", "copy2", "copyfile", "copytree"
}

DANGEROUS_MODULES = {"subprocess", "socket"}
DANGEROUS_BUILTINS = {"exec", "eval"}
SAFE_PIPE_COMMANDS = {"grep", "head", "tail", "wc", "cat", "sort", "uniq", "column"}
SAFE_PYTHON_MODULES = {"json.tool", "timeit", "calendar"}


def analyze_ast(tree):
    """Scan Python AST nodes for mutating or dangerous function calls."""
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            func_name = ""
            if isinstance(node.func, ast.Name):
                func_name = node.func.id
            elif isinstance(node.func, ast.Attribute):
                func_name = node.func.attr

            if func_name in DESTRUCTIVE_CALLS:
                return False, f"Destructive function called: {func_name}"
            if func_name in DANGEROUS_BUILTINS:
                return False, f"Dynamic execution called: {func_name}"

            if func_name == "open":
                mode = "r"
                if len(node.args) >= 2:
                    if isinstance(node.args[1], ast.Constant) and isinstance(node.args[1].value, str):
                        mode = node.args[1].value
                    else:
                        return False, "Non-constant mode in open()"
                for kw in node.keywords:
                    if kw.arg == "mode":
                        if isinstance(kw.value, ast.Constant) and isinstance(kw.value.value, str):
                            mode = kw.value.value
                        else:
                            return False, "Non-constant mode keyword in open()"
                if any(m in mode for m in ["w", "a", "x", "+"]):
                    return False, f"File opened with write mode: {mode}"

        elif isinstance(node, (ast.Import, ast.ImportFrom)):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    root_mod = alias.name.split(".")[0]
                    if root_mod in DANGEROUS_MODULES:
                        return False, f"Dangerous module imported: {alias.name}"
            elif isinstance(node, ast.ImportFrom):
                if node.module:
                    root_mod = node.module.split(".")[0]
                    if root_mod in DANGEROUS_MODULES:
                        return False, f"Dangerous module imported: {node.module}"

    return True, "Safe"


def inspect_command(command_line):
    """Inspect a command line string and return a hook decision dictionary."""
    if not command_line or not command_line.strip():
        return {"decision": "ask"}

    try:
        tokens = shlex.split(command_line)
    except Exception as err:
        return {"decision": "force_ask", "reason": f"Shell tokenization failed: {err}"}

    if not tokens:
        return {"decision": "ask"}

    # If the command starts with python/python3 (or path to python)
    binary = os.path.basename(tokens[0])
    if not (binary.startswith("python") or binary.startswith("pypy")):
        # Non-Python command: defer to settings.json
        return {"decision": "ask"}

    # Check for file redirection (">" or ">>") outside quotes
    if ">" in tokens or ">>" in tokens:
        return {"decision": "force_ask", "reason": "Command contains output redirection writing to disk"}

    # Handle pipelines
    if "|" in tokens:
        pipe_idx = tokens.index("|")
        py_tokens = tokens[:pipe_idx]
        rest_tokens = tokens[pipe_idx + 1:]
        # Check downstream pipe command
        if not rest_tokens or os.path.basename(rest_tokens[0]) not in SAFE_PIPE_COMMANDS:
            return {"decision": "force_ask", "reason": f"Piped into unvetted command: {' '.join(rest_tokens[:2])}"}
    else:
        py_tokens = tokens

    # Case 1: python -c "<code>"
    if "-c" in py_tokens:
        c_idx = py_tokens.index("-c")
        if c_idx + 1 >= len(py_tokens):
            return {"decision": "force_ask", "reason": "Missing code string after -c"}
        code = py_tokens[c_idx + 1]
        try:
            tree = ast.parse(code)
        except Exception as parse_err:
            return {"decision": "force_ask", "reason": f"Python syntax parse failure: {parse_err}"}

        safe, reason = analyze_ast(tree)
        if safe:
            return {"decision": "allow", "reason": "Read-only Python code"}
        return {"decision": "force_ask", "reason": reason}

    # Case 2: python -m <module>
    if "-m" in py_tokens:
        m_idx = py_tokens.index("-m")
        if m_idx + 1 < len(py_tokens):
            mod_name = py_tokens[m_idx + 1]
            if mod_name in SAFE_PYTHON_MODULES:
                return {"decision": "allow", "reason": f"Safe module: {mod_name}"}
        return {"decision": "force_ask", "reason": "Unvetted Python module execution"}

    # Case 3: python <script.py>
    # Find script argument (first token not starting with '-' after binary)
    script_path = None
    for token in py_tokens[1:]:
        if not token.startswith("-"):
            script_path = token
            break

    if script_path and os.path.isfile(script_path):
        try:
            with open(script_path, "r", encoding="utf-8", errors="replace") as sf:
                script_code = sf.read()
            tree = ast.parse(script_code)
            safe, reason = analyze_ast(tree)
            if safe:
                return {"decision": "allow", "reason": f"Read-only script: {script_path}"}
            return {"decision": "force_ask", "reason": f"{reason} in {script_path}"}
        except Exception as script_err:
            return {"decision": "force_ask", "reason": f"Failed to inspect {script_path}: {script_err}"}

    # Default fallback for complex or interactive python invocations
    return {"decision": "force_ask", "reason": "Manual confirmation required for Python execution"}


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            json.dump({"decision": "ask"}, sys.stdout)
            return

        payload = json.loads(raw_input)
        tool_call = payload.get("toolCall", {})
        if tool_call.get("name") != "run_command":
            json.dump({"decision": "ask"}, sys.stdout)
            return

        cmd = tool_call.get("args", {}).get("CommandLine", "")
        result = inspect_command(cmd)
        json.dump(result, sys.stdout)
    except Exception as err:
        json.dump({"decision": "force_ask", "reason": f"Safety check error: {err}"}, sys.stdout)


if __name__ == "__main__":
    main()
