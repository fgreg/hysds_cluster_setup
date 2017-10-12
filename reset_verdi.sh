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

# stop services on workers
fab -f cluster.py -R verdi verdid_stop || check_error verdid_stop

# kill hung
fab -f cluster.py -R verdi kill_hung || check_error kill_hung

# remove all docker images
#fab -f cluster.py -R verdi remove_docker_images || check_error remove_docker_images

# restart
fab -f cluster.py -R verdi verdid_clean_start || check_error verdid_clean_start
