#!/usr/bin/python

# Sets up the project, assumes you have rvm though
import subprocess
import util
import build

def install_package(name):
    try:
        print subprocess.check_output(['brew', 'install', name])
    except:
        pass

def main():
    # Install homebrew
    print util.log('Installing Homebrew')
    brew = subprocess.check_output(['which', 'brew']).replace('\n','')
    if brew == '/usr/local/bin/brew':
        print subprocess.check_output(['brew', 'update'])
    else:
        print subprocess.check_output(['/usr/bin/ruby', '-e', '"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'])
    # Set up vapor
    print util.log('Installing Vapor')
    install_package('vapor')
    # Setup other dependicies
    print util.log('Installing dependencies')
    install_package('postgresql')
    install_package('redis')
    install_package('libpq')
    # attempt to build
    build.main()
