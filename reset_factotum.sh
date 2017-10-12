#!/bin/bash

source $HOME/mozart/bin/activate

cd $(dirname $0)

function check_error {
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "Failed to run $1." 1>&2
    exit $STATUS
  fi
}

# stop services
fab -f cluster.py -R factotum verdid_stop || check_error verdid_stop

# kill hung
fab -f cluster.py -R factotum kill_hung || check_error kill_hung

# restart
fab -f cluster.py -R factotum verdid_clean_start || check_error verdid_clean_start
