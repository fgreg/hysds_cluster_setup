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

./update_grq.sh || check_error update_grq.sh
./update_mozart.sh || check_error update_mozart.sh
./update_metrics.sh || check_error update_metrics.sh
./update_factotum.sh || check_error update_factotum.sh
./update_verdi.sh || check_error update_verdi.sh
