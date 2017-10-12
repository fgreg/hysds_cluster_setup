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
fab -f cluster.py -R grq grqd_stop || check_error grqd_stop

# clean out ES
#fab -f cluster.py -R grq clean_hysds_ios || check_error clean_hysds_ios

# restart
fab -f cluster.py -R grq grqd_clean_start || check_error grqd_clean_start
