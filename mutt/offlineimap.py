#!/usr/bin/python
import re, subprocess
def get_keychain_pass(account=None, server=None):
    params = {
        'security': '/usr/bin/security',
        'command': 'find-internet-password',
        'account': account,
        'server': server,
        'keychain': '/Users/kylem/Library/Keychains/login.keychain',
    }
    command = "sudo -u kylem %(security)s -v %(command)s -g -a %(account)s -s %(server)s %(keychain)s" % params
    output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
    outtext = [l for l in output.splitlines()
               if l.startswith('password: ')][0]

    pw = re.match(r'password: "(.*)"', outtext).group(1)
    return pw
