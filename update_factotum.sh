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


# stop services on factotum
fab -f cluster.py -R factotum verdid_stop || check_error verdid_stop

# kill hung
fab -f cluster.py -R factotum kill_hung || check_error kill_hung

# update factotum
fab -f cluster.py -R factotum rm_rf:~/verdi/ops/* || check_error rm_rf
fab -f cluster.py -R factotum rsync_code:factotum,verdi || check_error rsync_code
fab -f cluster.py -R factotum set_spyddder_settings || check_error set_spyddder_settings

# update reqs
fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/osaka || check_error pip_install_with_req
fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/prov_es || check_error pip_install_with_req
fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/hysds_commons || check_error pip_install_with_req
fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/hysds/third_party/celery-v3.1.25.pqueue || check_error pip_install_with_req
fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/hysds || check_error pip_install_with_req
#fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/sciflo || check_error pip_install_with_req
#fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/qquery || check_error pip_install_with_req
#fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/asf || check_error pip_install_with_req
#fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/apihub || check_error pip_install_with_req
#fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/scihub || check_error pip_install_with_req
#fab -f cluster.py -R factotum pip_install_with_req:verdi,~/verdi/ops/unavco || check_error pip_install_with_req

# update celery config
fab -f cluster.py -R factotum rm_rf:~/verdi/ops/hysds/celeryconfig.py || check_error rm_rf
fab -f cluster.py -R factotum rm_rf:~/verdi/ops/hysds/celeryconfig.pyc || check_error rm_rf
fab -f cluster.py -R factotum send_celeryconf:verdi || check_error send_celeryconf

# update supervisor config
fab -f cluster.py -R factotum rm_rf:~/verdi/etc/supervisord.conf || check_error rm_rf
fab -f cluster.py -R factotum send_template:supervisord.conf.factotum,~/verdi/etc/supervisord.conf,~/mozart/ops/hysds/configs/supervisor || check_error send_template

# update datasets config; overwrite datasets config with domain-specific config
fab -f cluster.py -R factotum rm_rf:~/verdi/etc/datasets.json || check_error rm_rf
fab -f cluster.py -R factotum send_template:datasets.json,~/verdi/etc/datasets.json || check_error send_template

# update worker configs for factotum
fab -f cluster.py -R factotum rm_rf:~/verdi/etc/workers || check_error rm_rf
fab -f cluster.py -R factotum mkdir:~/verdi/etc/workers,ops,ops || check_error mkdir

# expose hysds log dir via webdav
fab -f cluster.py -R factotum ln_sf:~/verdi/log,/data/work/log || check_error ln_sf

# ship netrc
if [ -e "files/netrc" ]; then
  fab -f cluster.py -R factotum copy:files/netrc,.netrc || check_error copy
  fab -f cluster.py -R factotum chmod:600,.netrc || check_error chmod
fi

# ship AWS creds
fab -f cluster.py -R factotum send_awscreds || check_error send_awscreds
