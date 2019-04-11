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


print(get_stdout("which ip")[1])
print(get_stdout("ip addr show")[1])
