#!/bin/bash

source $HOME/mozart/bin/activate

cd $(dirname $0)

source ./context.sh

function check_error {
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "Failed to run $1." 1>&2
    exit $STATUS
  fi
}

# kill all running docker instances
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi remove_running_containers || check_error remove_running_containers

# remove docker volumes
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi remove_docker_volumes || check_error docker_volumes

# remove all docker images
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi remove_docker_images || check_error remove_docker_images

# list docker images
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi list_docker_images || check_error list_docker_images
