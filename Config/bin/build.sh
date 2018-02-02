#!/usr/bin/env bash

# Attempts to pull, and then build the script as well as generate the vapor xcode files for you
# Created by: Johnny Nguyen
# Version: 1.0.0

LOCAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# We can run the setup script here, but im not going to
# instead, we'll just run the norm
echo "Pulling Git repo from staging"
git fetch --all --prune
git checkout staging
git pull
echo "Checking back to ${LOCAL_BRANCH}"

# Setup back
echo "Attempting to merge git branch..."
git checkout $LOCAL_BRANCH
git merge staging
