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

# stop services on mozart
fab -f cluster.py -R mozart mozartd_stop || check_error mozartd_stop

# update reqs
fab -f cluster.py -R mozart pip_install_with_req:mozart,~/mozart/ops/osaka || check_error pip_install_with_req
fab -f cluster.py -R mozart pip_install_with_req:mozart,~/mozart/ops/prov_es || check_error pip_install_with_req
fab -f cluster.py -R mozart pip_install_with_req:mozart,~/mozart/ops/hysds_commons || check_error pip_install_with_req
fab -f cluster.py -R mozart pip_install_with_req:mozart,~/mozart/ops/hysds/third_party/celery-v3.1.25.pqueue || check_error pip_install_with_req
fab -f cluster.py -R mozart pip_install_with_req:mozart,~/mozart/ops/hysds || check_error pip_install_with_req
fab -f cluster.py -R mozart pip_install_with_req:mozart,~/mozart/ops/sciflo || check_error pip_install_with_req
fab -f cluster.py -R mozart pip_install_with_req:mozart,~/mozart/ops/mozart || check_error pip_install_with_req

# update celery config
fab -f cluster.py -R mozart rm_rf:~/mozart/ops/hysds/celeryconfig.py || check_error rm_rf
fab -f cluster.py -R mozart rm_rf:~/mozart/ops/hysds/celeryconfig.pyc || check_error rm_rf
fab -f cluster.py -R mozart send_celeryconf:mozart || check_error send_celeryconf

# update supervisor config
fab -f cluster.py -R mozart rm_rf:~/mozart/etc/supervisord.conf || check_error rm_rf
fab -f cluster.py -R mozart send_template:supervisord.conf.mozart,~/mozart/etc/supervisord.conf,~/mozart/ops/hysds/configs/supervisor || check_error send_template

# update orchestrator config
fab -f cluster.py -R mozart rm_rf:~/mozart/etc/orchestrator_*.json || check_error rm_rf
fab -f cluster.py -R mozart copy:~/mozart/ops/hysds/configs/orchestrator/orchestrator_jobs.json,~/mozart/etc/orchestrator_jobs.json || check_error copy
fab -f cluster.py -R mozart copy:~/mozart/ops/hysds/configs/orchestrator/orchestrator_datasets.json,~/mozart/etc/orchestrator_datasets.json || check_error copy

# update job_creators
fab -f cluster.py -R mozart rm_rf:~/mozart/etc/job_creators || check_error rm_rf
fab -f cluster.py -R mozart cp_rp:~/mozart/ops/hysds/scripts/job_creators,~/mozart/etc/ || check_error cp_rp

# update datasets config; overwrite datasets config with domain-specific config
fab -f cluster.py -R mozart rm_rf:~/mozart/etc/datasets.json || check_error rm_rf
fab -f cluster.py -R mozart send_template:datasets.json,~/mozart/etc/datasets.json || check_error send_template

# ship logstash shipper configs
fab -f cluster.py -R mozart send_shipper_conf:mozart,/home/hysdsops/mozart/log,${MOZART_ES_CLUSTER},127.0.0.1,${METRICS_ES_CLUSTER},${METRICS_PVT_IP} || check_error send_shipper_conf

# update mozart config
fab -f cluster.py -R mozart rm_rf:~/mozart/ops/mozart/settings.cfg || check_error rm_rf
fab -f cluster.py -R mozart send_mozartconf || check_error send_mozartconf
fab -f cluster.py -R mozart rm_rf:~/mozart/ops/mozart/actions_config.json || check_error rm_rf
fab -f cluster.py -R mozart copy:~/mozart/ops/mozart/configs/actions_config.json.example,~/mozart/ops/mozart/actions_config.json || check_error copy

# update figaro config
fab -f cluster.py -R mozart rm_rf:~/mozart/ops/figaro/settings.cfg || check_error rm_rf
fab -f cluster.py -R mozart send_figaroconf || check_error send_figaroconf

# create user_rules index
~/mozart/ops/mozart/scripts/create_user_rules_index.py || check_error create_user_rules

# ensure self-signed SSL certs exist
fab -f cluster.py -R mozart ensure_ssl:mozart || check_error ensure_ssl

# link ssl certs to apps
fab -f cluster.py -R mozart ln_sf:~/ssl/server.key,~/mozart/ops/mozart/server.key || check_error ln_sf
fab -f cluster.py -R mozart ln_sf:~/ssl/server.pem,~/mozart/ops/mozart/server.pem || check_error ln_sf

# expose hysds log dir via webdav
fab -f cluster.py -R mozart ln_sf:~/mozart/log,/data/work/log || check_error ln_sf

# ship netrc
if [ -e "files/netrc.mozart" ]; then
  fab -f cluster.py -R mozart send_template:netrc.mozart,.netrc || check_error send_template
  fab -f cluster.py -R mozart chmod:600,.netrc || check_error chmod
fi

# ship AWS creds
fab -f cluster.py -R mozart send_awscreds || check_error send_awscreds
