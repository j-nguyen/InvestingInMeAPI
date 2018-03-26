#!/usr/env/python

# This script seeks to try to build the project
import subprocess
import util

def main():
    # Attempt to build with vapor 
    print util.log('Building Project')
    print subprocess.check_output(['vapor', 'build', '--verbose'])
    print subprocess.check_output(['vapor', 'run', 'drop', '--verbose'])
    print subprocess.check_output(['vapor', 'run', 'seed'])
    print util.log('Done.')