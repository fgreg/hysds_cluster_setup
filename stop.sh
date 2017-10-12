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

#./stop_verdi.sh || check_error stop_verdi.sh
./stop_factotum.sh || check_error stop_factotum.sh
./stop_metrics.sh || check_error stop_metrics.sh
./stop_mozart.sh || check_error stop_mozart.sh
./stop_grq.sh || check_error stop_grq.sh
