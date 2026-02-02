## NOTE: this file is meant to be sourced, not executed in a subshell
## This is needed so that environment variables defined here are available
## to the top level shell and all its subshells and subprocesses

echo "Initializing environment variables for CodeBuild"
if [[ -v CODEBUILD_WEBHOOK_EVENT && $CODEBUILD_WEBHOOK_EVENT == "PULL_REQUEST_"* ]]; then
  echo "Detected a pull request event"
  export IS_PULL_REQUEST=1
else
  echo "Not a pull request event"
  export IS_PULL_REQUEST=0
fi

if [[ $IS_PULL_REQUEST = 1 && $CODEBUILD_SOURCE_VERSION == "pr/"* ]]; then
  echo "Pull request number detected: ${CODEBUILD_SOURCE_VERSION:3}"
  export PR_NUMBER=${CODEBUILD_SOURCE_VERSION:3}
else
  echo "No pull request number detected"
  export PR_NUMBER=""
fi

# check if trigger is main branch webhook event PUSH and head_ref refs/heads/main
if [[ -v CODEBUILD_WEBHOOK_EVENT && $CODEBUILD_WEBHOOK_EVENT == "PUSH" && $CODEBUILD_WEBHOOK_HEAD_REF == "refs/heads/main" ]]; then
  echo "Detected a push event to the main branch"
  export IS_MAIN_BRANCH=1
else
  echo "Not a push event to the main branch"
  export IS_MAIN_BRANCH=0
fi

