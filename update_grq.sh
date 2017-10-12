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

# stop services on grq
fab -f cluster.py -R grq grqd_stop || check_error grqd_stop

# update grq
fab -f cluster.py -R grq rm_rf:~/sciflo/ops/* || check_error rm_rf
fab -f cluster.py -R grq rsync_code:grq,sciflo || check_error rsync_code

# ensure latest gunicorn
fab -f cluster.py -R grq pip_upgrade:gunicorn,sciflo || check_error pip_upgrade

# update reqs
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/osaka || check_error pip_install_with_req
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/prov_es || check_error pip_install_with_req
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/hysds_commons || check_error pip_install_with_req
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/hysds/third_party/celery-v3.1.25.pqueue || check_error pip_install_with_req
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/hysds || check_error pip_install_with_req
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/sciflo || check_error pip_install_with_req
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/grq2 || check_error pip_install_with_req
fab -f cluster.py -R grq pip_install_with_req:sciflo,~/sciflo/ops/tosca || check_error pip_install_with_req

# update celery config
fab -f cluster.py -R grq rm_rf:~/sciflo/ops/hysds/celeryconfig.py || check_error rm_rf
fab -f cluster.py -R grq rm_rf:~/sciflo/ops/hysds/celeryconfig.pyc || check_error rm_rf
fab -f cluster.py -R grq send_celeryconf:grq || check_error send_celeryconf

# update grq2 config
fab -f cluster.py -R grq rm_rf:~/sciflo/ops/grq2/settings.cfg || check_error rm_rf
fab -f cluster.py -R grq send_grq2conf || check_error send_grq2conf

# update tosca config
fab -f cluster.py -R grq rm_rf:~/sciflo/ops/tosca/settings.cfg || check_error rm_rf
#fab -f cluster.py -R grq send_toscaconf || check_error send_toscaconf
fab -f cluster.py -R grq send_toscaconf:tosca_settings.cfg.tmpl,~/hysds_cluster_setup/files || check_error send_toscaconf
fab -f cluster.py -R grq ln_sf:~/sciflo/ops/tosca/configs/actions_config.json.example,~/sciflo/ops/tosca/actions_config.json || check_error ln_sf

# update supervisor config
fab -f cluster.py -R grq rm_rf:~/sciflo/etc/supervisord.conf || check_error rm_rf
fab -f cluster.py -R grq send_template:supervisord.conf.grq,~/sciflo/etc/supervisord.conf,~/mozart/ops/hysds/configs/supervisor || check_error send_template

# update datasets config; overwrite datasets config with domain-specific config
fab -f cluster.py -R grq rm_rf:~/sciflo/etc/datasets.json || check_error rm_rf
fab -f cluster.py -R grq send_template:datasets.json,~/sciflo/etc/datasets.json || check_error send_template

# ensure self-signed SSL certs exist
fab -f cluster.py -R grq ensure_ssl:grq || check_error ensure_ssl

# link ssl certs to apps
fab -f cluster.py -R grq ln_sf:~/ssl/server.key,~/sciflo/ops/grq2/server.key || check_error ln_sf
fab -f cluster.py -R grq ln_sf:~/ssl/server.pem,~/sciflo/ops/grq2/server.pem || check_error ln_sf
fab -f cluster.py -R grq ln_sf:~/ssl/server.key,~/sciflo/ops/tosca/server.key || check_error ln_sf
fab -f cluster.py -R grq ln_sf:~/ssl/server.pem,~/sciflo/ops/tosca/server.pem || check_error ln_sf

# expose hysds log dir via webdav
fab -f cluster.py -R grq ln_sf:~/sciflo/log,/data/work/log || check_error ln_sf

# update ES template
fab -f cluster.py -R grq install_es_template || check_error install_es_template

# ship AWS creds
fab -f cluster.py -R grq send_awscreds || check_error send_awscreds
