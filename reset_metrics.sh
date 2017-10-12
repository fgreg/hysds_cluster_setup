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
fab -f cluster.py -R metrics metricsd_stop || check_error metricsd_stop

# clean redis on metrics
fab -f cluster.py -R metrics redis_flush || check_error redis_flush

# restart
fab -f cluster.py -R metrics metricsd_clean_start || check_error metricsd_clean_start
