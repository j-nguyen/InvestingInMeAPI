#!/usr/bin/env bash

# Setups the project for us so that it should use
# Created by: Johnny Nguyen
# Version: 1.0.0

# We need to first ensure that the services are installed
# If it's not installed, then we can just update the homebrew

which -s brew
if [[ $? != 0 ]] ; then
  # Install Homebrew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Try to install the packages
brew tap vapor/homebrew-tap
brew update
brew install postgresql
brew install libpq

