#!/bin/bash
set -e

# Check if this is PR execution PR_NUMBER not empty
if [[ -n "$PR_NUMBER" ]]; then
  echo "This is a PR execution. PR Number: $PR_NUMBER"
else
  echo "This is not a PR execution. Skip validation."
  exit 0
fi
