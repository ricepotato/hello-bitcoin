#!/bin/sh

mkdir /root/bitcoin_data/bitcoind

rm /root/bitcoin_data/debug.log

## Pre execution handler
pre_execution_handler() {
  ## Pre Execution
  echo "pre_execution"
}

## Post execution handler
post_execution_handler() {
  ## Post Execution
  echo "post_execution"
  echo "wait 5s"
  /root/bitcoin/bin/bitcoin-cli stop
  sleep 5
  echo "finished"
}

## Sigterm Handler
sigterm_handler() { 
  if [ $pids -ne 0 ]; then
    # the above if statement is important because it ensures 
    # that the application has already started. without it you
    # could attempt cleanup steps if the application failed to
    # start, causing errors.
    kill -15 "$pids"
    wait "$pids"
    post_execution_handler
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

## Setup signal trap
# on callback execute the specified handler
trap 'sigterm_handler' TERM

## Initialization
pre_execution_handler

## Start Process
# run process in background and record PID
pids=""
RESULT=0

echo "start bitcoind"

/root/bitcoin/bin/bitcoind  -conf=/root/bitcoin.conf -datadir=/root/bitcoin_data/bitcoind -rpcauth=$RPC_AUTH &
pids="$pids $!"

## Wait until one app dies
for pid in $pids; do
    wait $pid || RESULT=1
done
if [ "$RESULT" = "1" ]; then
    exit 1
fi
return_code="$?"

## Cleanup
post_execution_handler
# echo the return code of the application
exit $return_code