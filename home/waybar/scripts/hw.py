#!/usr/bin/env python3
import time
import json

def get_cpu_percent(interval=0.5):
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
    import glob
    import os
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

def main():
    cpu = get_cpu_percent()
    mem = get_mem_percent()
    temp = get_cpu_temp()
    
    if temp is not None:
        text = f"  {cpu}% |   {mem}% |  {temp}°"
        tooltip = f"{'cpu usage:':<13} {cpu:02d}%\n{'memory usage:':<13} {mem:02d}%\n{'cpu temp:':<13} {temp:02d}°c"
    else:
        text = f"  {cpu}% |   {mem}%"
        tooltip = f"{'cpu usage:':<13} {cpu:02d}%\n{'memory usage:':<13} {mem:02d}%"
        
    print(json.dumps({"text": text, "tooltip": tooltip}))

if __name__ == '__main__':
    main()
