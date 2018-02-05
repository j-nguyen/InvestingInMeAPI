#!/usr/bin/env bash

# Resets the project back to its normal settings
# This means clearing the database, and resetting the seeds with vapor

set -e

echo "Building project..."
vapor build --verbose
echo "Done."
echo "Running Drop Command..."
vapor run drop --verbose
echo "Done."
echo "Running Seed Command..."
vapor run seed --verbose
echo "Done."
