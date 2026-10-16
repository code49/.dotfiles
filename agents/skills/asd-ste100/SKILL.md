---
name: asd-ste100
description: Format writing, technical explanations, and responses using ASD-STE100 (Simplified Technical English) at an 80% pragmatic effort level for high clarity and readability.
---

# ASD-STE100 (Simplified Technical English) — 80% Effort Level

Apply Simplified Technical English (ASD-STE100) principles to technical responses, documentation, and explanations. 

The **80% effort level** captures the clarity, speed, and precision of STE without the friction of a rigid 3,000-word aerospace dictionary. Enforce core structural and grammatical rules strictly, apply plain vocabulary standards, and permit standard software engineering terms as Technical Names.

---

## 🎯 The 80% Pragmatic Rule

- **Strict Structure (100%):** Enforce sentence length caps, active voice, imperative steps, one idea per sentence, simple tenses, and small noun clusters.
- **Plain Vocabulary (80%):** Replace convoluted, formal, or Latinate words with direct, simple equivalents (e.g., *use* instead of *utilize*, *make sure* instead of *ensure*).
- **Domain Pragmatism:** Do not invent awkward circumlocutions for standard software engineering terminology (e.g., *API*, *endpoint*, *repository*, *runtime*, *middleware*, *closure*, *flake*). Treat these as approved Technical Names under STE Rule 1.

---

## 📏 1. Structural & Sentence Rules

### 1.1 Sentence Length Limits
- **Procedural sentences (instructions, steps):** Maximum **20 words**.
- **Descriptive sentences (explanations, context):** Maximum **25 words**.
- Keep paragraphs short: 1 to 3 sentences maximum. Prefer vertical lists for complex information.

### 1.2 One Idea Per Sentence
- Put only **one instruction** or **one technical fact** in each sentence.
- Split compound steps joined by *and*, *while*, or *then*.
  - ❌ *Incorrect:* Clone the repository and install the dependencies before you start the local development server.
  - ✅ *Correct:* Clone the repository. Install the dependencies. Start the local development server.

### 1.3 Active Voice Only
- Write in the active voice. State who or what performs the action.
  - ❌ *Incorrect:* The configuration file is loaded by the application at startup.
  - ✅ *Correct:* The application loads the configuration file at startup.
  - ❌ *Incorrect:* All errors must be logged.
  - ✅ *Correct:* The service logs all errors.

### 1.4 Imperative Mood for Procedures
- Start procedural steps with an imperative verb (a direct command).
- Do not use polite padding (*please*), suggestions (*you can*, *should*), or future tense (*you will*).
  - ❌ *Incorrect:* You should run the build script to compile the binary.
  - ✅ *Correct:* Run the build script to compile the binary.

### 1.5 Verb Tense Restrictions
Use only four verb forms:
1. **Imperative:** *Run*, *Open*, *Set*, *Delete*.
2. **Simple Present:** *The process starts*, *The client sends*.
3. **Simple Past:** *The script failed*, *The test passed*.
4. **Simple Future:** *The worker will retry*.

**Forbidden verb forms:**
- Continuous / Progressive (`-ing` verb forms):
  - ❌ *Incorrect:* The server is waiting for connections.
  - ✅ *Correct:* The server waits for connections.
- Perfect tenses (`has/have/had + past participle`):
  - ❌ *Incorrect:* The task has completed.
  - ✅ *Correct:* The task completed.
- Passive modals (`can be done`, `must be verified`):
  - ❌ *Incorrect:* The token can be refreshed.
  - ✅ *Correct:* You can refresh the token. / The client refreshes the token.

### 1.6 Noun Clusters (Maximum 3 Nouns)
- Do not string more than **three consecutive nouns** together.
- Break long noun chains with prepositions (*of*, *for*, *in*).
  - ❌ *Incorrect:* User session authentication token refresh failure handler. (6 nouns)
  - ✅ *Correct:* Failure handler for user session token refreshes.

### 1.7 Explicit Pronoun References
- Never use *this*, *that*, *these*, *those*, or *it* alone as a sentence subject.
- Always follow a demonstrative word with its specific noun.
  - ❌ *Incorrect:* This causes an out-of-memory error.
  - ✅ *Correct:* This memory leak causes an out-of-memory error.
  - ❌ *Incorrect:* It is important to back up the database.
  - ✅ *Correct:* Back up the database before the migration.

---

## 📖 2. Vocabulary & Plain Language

### 2.1 Standard Word Substitutions
Always replace complex or bureaucratic phrasing with approved plain terms:

| Complex / Avoid | ASD-STE100 Preferred | Example |
| :--- | :--- | :--- |
| **utilize / leverage** | **use** | Use the `curl` tool. |
| **ensure / ascertain** | **make sure** | Make sure the port is open. |
| **initiate / commence** | **start** | Start the service. |
| **terminate / abort** | **stop / cancel** | Stop the process. |
| **modify / alter** | **change** | Change the timeout value. |
| **demonstrate / indicate** | **show** | The logs show the root cause. |
| **execute / perform** | **run / do** | Run the database migration. |
| **prior to / subsequent to** | **before / after** | Run tests before deployment. |
| **in order to** | **to** | To build the package, run `nix build`. |
| **as well as / additionally** | **and / also** | Install Git and Curl. |
| **due to the fact that** | **because** | The build failed because the disk is full. |
| **in the event that** | **if** | If the service fails, restart it. |
| **never / avoid** | **do not** | Do not edit this file directly. |
| **verify / validate** | **check / make sure** | Check the return code. |
| **transmit / submit** | **send** | Send the payload to the server. |
| **obtain / retrieve** | **get** | Get the API key from the dashboard. |

### 2.2 Vague Words to Eliminate
Delete imprecise words. Provide exact values, limits, or conditions:
- ❌ *Vague:* frequently, periodically, often, occasionally
- ✅ *Exact:* every 5 minutes, after 3 attempts
- ❌ *Vague:* etc., and so on, and the like
- ✅ *Exact:* list all items explicitly, or write "such as X or Y"
- ❌ *Vague:* appropriate, suitable, normal
- ✅ *Exact:* specify the required configuration or range

---

## 🏗️ 3. Formatting & Information Types

### 3.1 Conditionals
State the condition first, then the action:
- Structure: **If [condition], [imperative action].**
- ❌ *Incorrect:* Reboot the machine if the kernel panics.
- ✅ *Correct:* If the kernel panics, reboot the machine.

### 3.2 Vertical Lists & Whitespace Formatting
Use vertical lists for three or more items, conditions, or steps:
- **Numbered lists (`1.`, `2.`):** For sequential instructions where order matters.
- **Bullet lists (`-`):** For collections of items, options, or independent conditions.

#### Whitespace and Indentation Rules for Lists:
- **Surround list blocks with blank lines:** Always place an empty line before and after a list block, and between preceding headings and introductory text.
- **Separate multi-line list items:** If list items contain explanations, multiple sentences, or code, insert a blank line between list items (loose list). Do not jam items together.
- **Indent continuation text:** Indent explanatory text, sub-points, or code blocks under a numbered or bullet item by 3 or 4 spaces (or 1 tab) to nest cleanly under the item header.

**Bad (jammed lines, no indentation, no blank lines between items):**
```markdown
1. Move core settings under settings.config:
In Lua mode, Home Manager maps settings.config directly to hl.config({ ... }).
Move your general, decoration, animations, input, scrolling, and misc sections into settings.config.
2. Enable native swap column wrapping:
Hyprland 0.56.2 supports scrolling.wrap_swapcol = false; natively.
```

**Good (blank line between items, continuation text indented under the item):**
```markdown
1. **Move core settings under `settings.config`:**
   In Lua mode, Home Manager maps `settings.config` directly to `hl.config({ ... })`.
   Move your general, decoration, animations, input, scrolling, and misc sections into `settings.config`.

2. **Enable native swap column wrapping:**
   Hyprland 0.56.2 supports `scrolling.wrap_swapcol = false;` natively.
   You can delete `swapcol_nowrap.py` and use direct `layoutmsg` calls.
```

### 3.3 Notes, Cautions, and Warnings
Follow standard STE severity indicators:
- **WARNING:** Personal injury or fatal risk.
- **CAUTION:** Equipment damage, data loss, or corruption risk.
- **NOTE:** Supplementary clarification or helpful context.

---

## 🔍 4. Self-Audit Checklist (The 80% Review)

Before sending responses or writing documentation, check against these 6 questions:

1. **Sentence length:** Is any procedural sentence over 20 words? Is any descriptive sentence over 25 words?
2. **Action mood:** Are instructions written in the imperative mood without polite filler?
3. **Voice & tense:** Are all sentences in the active voice using simple tenses (no `-ing` verbs or perfect tenses)?
4. **Noun chains:** Are there any noun clusters with more than 3 nouns?
5. **Word choices:** Did you replace *utilize*, *ensure*, *initiate*, and *prior to*?
6. **One idea:** Does each sentence express only one action or fact?

---

## 💡 5. Before & After Examples

### Example 1: Procedural Instructions
- ❌ **Before (Wordy, passive, complex):**
  > In order to initiate the compilation process, it is recommended that you utilize the cargo tool to build the binary, while ensuring that the necessary environment variables have been appropriately configured prior to running the command.
- ✅ **After (80% ASD-STE100):**
  > Set the required environment variables. Then run `cargo build` to compile the binary.

### Example 2: Architecture Explanation
- ❌ **Before (Long sentences, passive voice, progressive tenses):**
  > The frontend application is continuously monitoring user input through event listeners, which are subsequently transmitting request payloads to the backend API endpoint whenever a state mutation is occurring.
- ✅ **After (80% ASD-STE100):**
  > The frontend listens for user input. When state changes occur, the frontend sends request payloads to the backend API.
