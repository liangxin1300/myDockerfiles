import subprocess


def to_ascii(s):
    """Convert the bytes string to a ASCII string
    Usefull to remove accent (diacritics)"""
    if s is None:
        return s
    if isinstance(s, str):
        return s
    try:
        return str(s, 'utf-8')
    except UnicodeDecodeError:
        import traceback
        traceback.print_exc()
        return s


def get_stdout(cmd, input_s=None, stderr_on=True, shell=True):
    if stderr_on:
        stderr = None
    else:
        stderr = subprocess.PIPE
    proc = subprocess.Popen(cmd,
                            shell=shell,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=stderr)
    stdout_data, stderr_data = proc.communicate(input_s)
    return proc.returncode, to_ascii(stdout_data)


def get_interface():
    import re
    iface_res = get_stdout("ip addr show")[1]
    for line in iface_res.split('\n'):
        res = re.match(r'^[0-9]+:\s+(eth0.*):\s+<', line)
        if res:
            return res.group(1)
    return None

print(get_stdout("rpm -qa crmsh")[1])
print(get_stdout("rpm -qa pacemaker")[1])
print(get_stdout("rpm -qa corosync")[1])
print(get_stdout("ip addr show")[1])
print(get_interface())
print(get_stdout("ps -ef|grep systemd"))
#get_stdout("crm cluster init -i {} -y".format(get_interface()))
