#!/usr/env/python

# Created by: Johnny Nguyen
# Last modified: March 1st 2018

import util
import merge
import build
import setup
import branch

def show_menu():
    """ Shows a menu """
    print '================== ' + util.HEADER + 'WORKFLOW MENU' + util.ENDC + ' =================='
    print '1) Development - Create a git branch off of staging'
    print '2) Merge - Merge your development branch to staging (GitHub)'
    print '3) Build - Builds project, and attempts to reseed your database for you'
    print '4) Setup - Setups project'
    print '5) Exit - Exits workflow'
    print '==================================================='

    choice = raw_input('Enter in a number (1-5): ')

    while choice not in ['1', '2', '3', '4', '5']:
        choice = raw_input(util.FAIL + 'Invalid Input! ' + util.ENDC + 'Please enter in a number (1-5): ')

    return choice 


def main():
    # Save option
    option = int(show_menu())
    # Go through
    if option == 1:
        branch.main()
    elif option == 2:
        merge.main()
    elif option == 3:
        build.main()
    elif option == 4:
        setup.main()
    elif option == 5:
        quit()

# Run the class
main()
