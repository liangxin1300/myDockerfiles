import subprocess

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
    return proc.returncode, stdout_data

print(get_stdout("rpm -qa crmsh")[1])
print(get_stdout("rpm -qa pacemaker")[1])
print(get_stdout("rpm -qa corosync")[1])
