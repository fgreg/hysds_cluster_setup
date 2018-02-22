#!/bin/bash

source $HOME/mozart/bin/activate

cd $(dirname $0)

# source yaml parser
source ./yaml.sh


echoerr() { echo "$@" 1>&2; }


function check_error {
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "Failed to run $1." 1>&2
    exit $STATUS
  fi
}


# source sds config
SDS_CFG=$HOME/.sds/config
if [ ! -e "$SDS_CFG" ]; then
  echoerr "Failed to find SDS configuration at $SDS_CFG. Run 'sds configure'."
  exit 1
fi
create_variables $SDS_CFG


# kill all running docker instances
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi,ci remove_running_containers || check_error remove_running_containers

# remove docker volumes
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi,ci remove_docker_volumes || check_error docker_volumes

# remove all docker images
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi,ci remove_docker_images || check_error remove_docker_images

# list docker images
fab -f cluster.py -R mozart,metrics,grq,factotum,verdi,ci list_docker_images || check_error list_docker_images
