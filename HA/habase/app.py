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


def get_stdout_stderr(cmd, input_s=None, shell=True):
    '''
    Run a cmd, return (rc, stdout, stderr)
    '''
    proc = subprocess.Popen(cmd,
                            shell=shell,
                            stdin=input_s and subprocess.PIPE or None,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    stdout_data, stderr_data = proc.communicate(input_s)
    return proc.returncode, to_ascii(stdout_data).strip(), to_ascii(stderr_data).strip()


