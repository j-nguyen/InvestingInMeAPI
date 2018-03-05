#!/usr/bin/python

# Created by: Johnny Nguyen
# This script attempts to ask for a pull request to merge

import urllib2
import urllib
import base64
import json
import subprocess
import util

def read_config():
    with open('./bin/config.json', 'r') as f:
        return json.loads(f.read())

def get_current_branch():
    return subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).replace('\n', '')

def update_branch():
    # Log out the stuff
    print util.log('Updating Branch')
    current_branch = get_current_branch()
    print current_branch
    # Attempt to pull
    try:
        subprocess.check_call(['git', 'pull', 'origin', 'staging'])
    except subprocess.CalledProcessError as error:
        print error
    print util.log('Pushing to remote branch')
    # If it's updated, let's go through with the next process
    print subprocess.check_output(['git', 'push', 'origin', 'HEAD'])

def create_pull_request():
    status = subprocess.check_output(['git', 'status', '--porcelain'])
    # Check if there's nothing to be commited
    if status == '':
        config = read_config()
        update_branch()
        # Now attempt to get the title and name
        title = raw_input('Enter in the pull request name: ')
        body = {'base': 'staging', 'head': get_current_branch(), 'title': title}
        # CALL THE REQUEST
        url = 'https://api.github.com/repos/j-nguyen/InvestingInMeAPI/pulls'
        req = urllib2.Request(url)
        encoded = base64.b64encode('{0}:{1}'.format(config['user'], config['token']))
        req.add_header('Authorization', 'Basic {0}'.format(encoded))
        req.add_data(json.dumps(body))
        response = urllib2.urlopen(req)
        print util.log('Reading Response')
        print response.read()
    else:
        print util.FAIL + util.BOLD + 'Your GIT status needs to be committed.' + util.ENDC


def main():
    """ Our main function """
    create_pull_request()