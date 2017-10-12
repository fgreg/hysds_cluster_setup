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

./reset_grq.sh || check_error reset_grq.sh
./reset_mozart.sh || check_error reset_mozart.sh
./reset_metrics.sh || check_error reset_metrics.sh
./reset_factotum.sh || check_error reset_factotum.sh
#./reset_verdi.sh || check_error reset_verdi.sh
