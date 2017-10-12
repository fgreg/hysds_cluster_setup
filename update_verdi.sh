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

# stop services on workers
fab -f cluster.py -R verdi verdid_stop || check_error verdid_stop

# kill hung
fab -f cluster.py -R verdi kill_hung || check_error kill_hung

# remove code bundle stuff
fab -f cluster.py -R verdi rm_rf:~/verdi/ops/etc || check_error rm_rf
fab -f cluster.py -R verdi rm_rf:~/verdi/ops/install.sh || check_error rm_rf

# update verdi
fab -f cluster.py -R verdi rm_rf:~/verdi/ops/* || check_error rm_rf
fab -f cluster.py -R verdi rsync_code:verdi || check_error rsync_code
#fab -f cluster.py -R verdi set_spyddder_settings || check_error set_spyddder_settings

# update reqs
fab -f cluster.py -R verdi pip_install_with_req:verdi,~/verdi/ops/osaka || check_error pip_install_with_req
fab -f cluster.py -R verdi pip_install_with_req:verdi,~/verdi/ops/prov_es || check_error pip_install_with_req
fab -f cluster.py -R verdi pip_install_with_req:verdi,~/verdi/ops/hysds_commons || check_error pip_install_with_req
fab -f cluster.py -R verdi pip_install_with_req:verdi,~/verdi/ops/hysds/third_party/celery-v3.1.25.pqueue || check_error pip_install_with_req
fab -f cluster.py -R verdi pip_install_with_req:verdi,~/verdi/ops/hysds || check_error pip_install_with_req
fab -f cluster.py -R verdi pip_install_with_req:verdi,~/verdi/ops/sciflo || check_error pip_install_with_req

# update celery config
fab -f cluster.py -R verdi rm_rf:~/verdi/ops/hysds/celeryconfig.py || check_error rm_rf
fab -f cluster.py -R verdi rm_rf:~/verdi/ops/hysds/celeryconfig.pyc || check_error rm_rf
fab -f cluster.py -R verdi send_celeryconf:verdi-asg || check_error send_celeryconf

# update supervisor config
fab -f cluster.py -R verdi rm_rf:~/verdi/etc/supervisord.conf || check_error rm_rf
fab -f cluster.py -R verdi send_template:supervisord.conf.verdi,~/verdi/etc/supervisord.conf,~/mozart/ops/hysds/configs/supervisor || check_error copy

# update verdi docker compose with ops user UID/GID
fab -f cluster.py -R verdi rm_rf:~/verdi/ops/hysds-dockerfiles/verdi/docker-compose.yml || check_error rm_rf
fab -f cluster.py -R verdi send_template:docker-compose.yml,~/verdi/ops/hysds-dockerfiles/verdi/docker-compose.yml || check_error send_template

# update datasets config; overwrite datasets config with domain-specific config
fab -f cluster.py -R verdi rm_rf:~/verdi/etc/datasets.json || check_error rm_rf
fab -f cluster.py -R verdi send_template:datasets.json,~/verdi/etc/datasets.json || check_error send_template

# update worker configs for verdi
fab -f cluster.py -R verdi rm_rf:~/verdi/etc/workers || check_error rm_rf
fab -f cluster.py -R verdi mkdir:~/verdi/etc/workers,ops,ops || check_error mkdir

# expose hysds log dir via webdav
fab -f cluster.py -R verdi ln_sf:~/verdi/log,/data/work/log || check_error ln_sf

# ship netrc
if [ -e "files/netrc" ]; then
  fab -f cluster.py -R verdi copy:files/netrc,.netrc || check_error copy
  fab -f cluster.py -R verdi chmod:600,.netrc || check_error chmod
fi

# ship AWS creds
fab -f cluster.py -R verdi send_awscreds || check_error send_awscreds
