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

./start_grq.sh || check_error start_grq.sh
./start_mozart.sh || check_error start_mozart.sh
./start_metrics.sh || check_error start_metrics.sh
./start_factotum.sh || check_error start_factotum.sh
#./start_verdi.sh || check_error start_verdi.sh
