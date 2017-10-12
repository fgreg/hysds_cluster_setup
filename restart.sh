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

# restart
#fab -f cluster.py -R verdi verdid_clean_start || check_error verdid_clean_start
fab -f cluster.py -R metrics mozartd_clean_start || check_error mozartd_clean_start
