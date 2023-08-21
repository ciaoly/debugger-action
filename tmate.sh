#!/bin/bash

set -e

if [[ ! -z "$SKIP_DEBUGGER" ]]; then
  echo "Skipping debugger because SKIP_DEBUGGER enviroment variable is set"
  exit
fi

# Install tmate on macOS or Ubuntu
echo Setting up tmate...
if [ -x "$(command -v brew)" ]; then
  brew install tmate > /tmp/brew.log
fi
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get install -y tmate openssh-client > /tmp/apt-get.log
fi

# Generate ssh key if needed
[ -e ~/.ssh/id_rsa ] || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

if [ ! -d /home/runner/work/tmp/ ]; then 
  mkdir -p /home/runner/work/tmp/;
fi

cd /home/runner/work/tmp/
# Run deamonized tmate
echo Running tmate...
tmate -S /tmp/tmate.sock new-session -d
tmate -S /tmp/tmate.sock wait tmate-ready

# Print connection info
echo ________________________________________________________________________________
echo
echo To connect to this session copy-n-paste the following into a terminal:
tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}'
echo After connecting you can run 'touch /tmp/keepalive' to disable the 15m timeout

if [[ ! -z "$SLACK_WEBHOOK_URL" ]]; then
  MSG=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}')
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"\`$MSG\`\"}" $SLACK_WEBHOOK_URL
fi