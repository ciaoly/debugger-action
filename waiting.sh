#!/bin/bash

set -e

if [[ ! -z "$SKIP_DEBUGGER" ]]; then
  echo "Skipping debugger because SKIP_DEBUGGER enviroment variable is set"
  exit
fi


# Wait for connection to close or timeout in 15 min
timeout=$((15*60))
while [ -S /tmp/tmate.sock ]; do
  sleep 1
  timeout=$(($timeout-1))

  if [ ! -f /tmp/keepalive ]; then
    if (( timeout < 0 )); then
      echo Waiting on tmate connection timed out!
      exit 1
    fi
  fi
done
