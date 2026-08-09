#!/usr/bin/env python3
import time
import json
import subprocess
import glob
import os

def get_cpu_percent(interval=0.2):
    def read_cpu_times():
        with open('/proc/stat', 'r') as f:
            first_line = f.readline()
        parts = first_line.split()
        times = [float(x) for x in parts[1:9]]
        idle = times[3] + times[4]
        total = sum(times)
        return total, idle

    try:
        t1, i1 = read_cpu_times()
        time.sleep(interval)
        t2, i2 = read_cpu_times()
        total_diff = t2 - t1
        idle_diff = i2 - i1
        if total_diff == 0:
            return 0
        return round(((total_diff - idle_diff) / total_diff) * 100)
    except Exception:
        return 0

def get_mem_percent():
    try:
        with open('/proc/meminfo', 'r') as f:
            meminfo = {}
            for line in f:
                parts = line.split()
                if len(parts) >= 2:
                    meminfo[parts[0].rstrip(':')] = int(parts[1])
        total = meminfo.get('MemTotal', 1)
        available = meminfo.get('MemAvailable', None)
        if available is None:
            free = meminfo.get('MemFree', 0)
            buffers = meminfo.get('Buffers', 0)
            cached = meminfo.get('Cached', 0)
            available = free + buffers + cached
        used = total - available
        return round((used / total) * 100)
    except Exception:
        return 0

def get_cpu_temp():
    # 1. Try hwmon (Ryzen/Intel Core sensors)
    for path in glob.glob('/sys/class/hwmon/hwmon*'):
        try:
            with open(os.path.join(path, 'name'), 'r') as f:
                name = f.read().strip()
            if name in ('k10temp', 'coretemp'):
                temp_files = sorted(glob.glob(os.path.join(path, 'temp*_input')))
                if temp_files:
                    with open(temp_files[0], 'r') as f:
                        return round(int(f.read().strip()) / 1000.0)
        except Exception:
            pass
    # 2. Try ACPI fallback
    for path in glob.glob('/sys/class/thermal/thermal_zone*'):
        try:
            with open(os.path.join(path, 'type'), 'r') as f:
                t = f.read().strip()
            if t in ('acpitz', 'x86_pkg_temp'):
                with open(os.path.join(path, 'temp'), 'r') as f:
                    return round(int(f.read().strip()) / 1000.0)
        except Exception:
            pass
    return None

def get_gpu_usage():
    for path in glob.glob('/sys/class/drm/card*/device/gpu_busy_percent'):
        try:
            with open(path, 'r') as f:
                val = f.read().strip()
                if val.isdigit():
                    return int(val)
        except Exception:
            pass
    return None

def get_gpu_temp():
    for path in glob.glob('/sys/class/hwmon/hwmon*'):
        try:
            with open(os.path.join(path, 'name'), 'r') as f:
                name = f.read().strip()
            if name == 'amdgpu':
                temp_files = sorted(glob.glob(os.path.join(path, 'temp*_input')))
                if temp_files:
                    with open(temp_files[0], 'r') as f:
                        return round(int(f.read().strip()) / 1000.0)
        except Exception:
            pass
    return None

def get_top_processes(sort_by="pcpu", count=5):
    try:
        cmd = ["ps", "-eo", "pcpu,pmem,comm", f"--sort=-{sort_by}", "--no-headers"]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        lines = res.stdout.strip().split('\n')
        
        processes = []
        for line in lines[:count]:
            parts = line.strip().split(None, 2)
            if len(parts) >= 3:
                pcpu, pmem, comm = parts[0], parts[1], parts[2]
                comm = os.path.basename(comm).lstrip('.')
                if len(comm) > 18:
                    comm = comm[:15] + "..."
                processes.append((pcpu, pmem, comm))
        return processes
    except Exception:
        return []

def get_cpu_text(cpu, temp):
    cpu_label = "<span color='#bdb2ff'></span>"
    if cpu >= 85:
        cpu_val = f"<span color='#ffadad'>{cpu}%</span>"
    elif cpu >= 60:
        cpu_val = f"<span color='#fdffb6'>{cpu}%</span>"
    else:
        cpu_val = f"<span>{cpu}%</span>"
        
    if temp is not None:
        if temp >= 80:
            temp_val = f"<span color='#ffadad'>({temp}°)</span>"
        elif temp >= 65:
            temp_val = f"<span color='#fdffb6'>({temp}°)</span>"
        else:
            temp_val = f"<span color='#9bf6ff'>({temp}°)</span>"
        return f"{cpu_label} {cpu_val} {temp_val}"
    return f"{cpu_label} {cpu_val}"

def get_mem_text(mem):
    mem_label = "<span color='#caffbf'></span>"
    if mem >= 85:
        mem_val = f"<span color='#ffadad'>{mem}%</span>"
    elif mem >= 70:
        mem_val = f"<span color='#fdffb6'>{mem}%</span>"
    else:
        mem_val = f"<span>{mem}%</span>"
    return f"{mem_label} {mem_val}"

def get_gpu_text(gpu, temp):
    if gpu is None:
        return ""
    gpu_label = "<span color='#daa9ff'>󰢮</span>"
    if gpu >= 85:
        gpu_val = f"<span color='#ffadad'>{gpu}%</span>"
    elif gpu >= 60:
        gpu_val = f"<span color='#fdffb6'>{gpu}%</span>"
    else:
        gpu_val = f"<span>{gpu}%</span>"
        
    if temp is not None:
        if temp >= 80:
            temp_val = f"<span color='#ffadad'>({temp}°)</span>"
        elif temp >= 65:
            temp_val = f"<span color='#fdffb6'>({temp}°)</span>"
        else:
            temp_val = f"<span color='#9bf6ff'>({temp}°)</span>"
        return f"{gpu_label} {gpu_val} {temp_val}"
    return f"{gpu_label} {gpu_val}"

def main():
    cpu = get_cpu_percent()
    mem = get_mem_percent()
    cpu_temp = get_cpu_temp()
    gpu = get_gpu_usage()
    gpu_temp = get_gpu_temp()
    
    top_cpu = get_top_processes("pcpu")
    top_mem = get_top_processes("pmem")
    
    text_parts = [get_cpu_text(cpu, cpu_temp), get_mem_text(mem)]
    gpu_text = get_gpu_text(gpu, gpu_temp)
    if gpu_text:
        text_parts.append(gpu_text)
        
    text = "  |  ".join(text_parts)
    
    # Generate Tooltip (all lowercase, wrapped in tt for monospace alignment)
    lines = []
    lines.append("<b>hardware status overview</b>")
    lines.append("─" * 35)
    
    cpu_temp_str = f" ({cpu_temp}°c)" if cpu_temp is not None else ""
    lines.append(f"<span color='#bdb2ff'> cpu:</span>   {cpu:2d}%{cpu_temp_str}")
    lines.append(f"<span color='#caffbf'> ram:</span>   {mem:2d}%")
    
    if gpu is not None:
        gpu_temp_str = f" ({gpu_temp}°c)" if gpu_temp is not None else ""
        lines.append(f"<span color='#daa9ff'>󰢮 gpu:</span>   {gpu:2d}%{gpu_temp_str}")
        
    lines.append("")
    lines.append("<b>top cpu processes</b>")
    lines.append("─" * 35)
    lines.append(f"{'process':<18} {'cpu':>6} {'mem':>6}")
    for pcpu, pmem, comm in top_cpu:
        lines.append(f"{comm.lower():<18} {pcpu:>5}% {pmem:>5}%")
        
    lines.append("")
    lines.append("<b>top memory processes</b>")
    lines.append("─" * 35)
    lines.append(f"{'process':<18} {'cpu':>6} {'mem':>6}")
    for pcpu, pmem, comm in top_mem:
        lines.append(f"{comm.lower():<18} {pcpu:>5}% {pmem:>5}%")
        
    tooltip = "<tt>" + "\n".join(lines) + "</tt>"
    
    print(json.dumps({"text": text, "tooltip": tooltip}))

if __name__ == '__main__':
    main()
