#!/bin/bash
# Script to execute csv-to-sdk.py --force in the pipeline

set -e

# Check if this is main branc execution IS_MAIN_BRANCH=1
if [[ "$IS_MAIN_BRANCH" == "1" ]]; then
  echo "This is a main branch execution."
else
  echo "This is not a main branch execution. Skip deploy."
  exit 0
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r csv-to-sdk/requirements.txt > /dev/null 2>&1

# Ensure the JWT is available for the script
echo "Setting up JWT for Open Metadata..."
echo $OM_JWT > jwt

# Run the Python script
echo "Running csv-to-sdk.py..."
python3 csv-to-sdk/csv-to-sdk.py --force

echo "Running csv-descriptions-to-sdk.py..."
python3 csv-to-sdk/csv-descriptions-to-sdk.py