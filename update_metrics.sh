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


# stop services on metrics
fab -f cluster.py -R metrics metricsd_stop || check_error metricsd_stop

# update
fab -f cluster.py -R metrics rm_rf:~/metrics/ops/* || check_error rm_rf
fab -f cluster.py -R metrics rsync_code:metrics || check_error rsync_code

# update reqs
fab -f cluster.py -R metrics pip_install_with_req:metrics,~/metrics/ops/osaka || check_error pip_install_with_req
fab -f cluster.py -R metrics pip_install_with_req:metrics,~/metrics/ops/prov_es || check_error pip_install_with_req
fab -f cluster.py -R metrics pip_install_with_req:metrics,~/metrics/ops/hysds_commons || check_error pip_install_with_req
fab -f cluster.py -R metrics pip_install_with_req:metrics,~/metrics/ops/hysds/third_party/celery-v3.1.25.pqueue || check_error pip_install_with_req
fab -f cluster.py -R metrics pip_install_with_req:metrics,~/metrics/ops/hysds || check_error pip_install_with_req
fab -f cluster.py -R metrics pip_install_with_req:metrics,~/metrics/ops/sciflo || check_error pip_install_with_req

# update celery config
fab -f cluster.py -R metrics rm_rf:~/metrics/ops/hysds/celeryconfig.py || check_error rm_rf
fab -f cluster.py -R metrics rm_rf:~/metrics/ops/hysds/celeryconfig.pyc || check_error rm_rf
fab -f cluster.py -R metrics send_celeryconf:metrics || check_error send_celeryconf

# update supervisor config
fab -f cluster.py -R metrics rm_rf:~/metrics/etc/supervisord.conf || check_error rm_rf
fab -f cluster.py -R metrics send_template:supervisord.conf.metrics,~/metrics/etc/supervisord.conf,~/mozart/ops/hysds/configs/supervisor || check_error send_template

# update datasets config; overwrite datasets config with domain-specific config
fab -f cluster.py -R metrics rm_rf:~/metrics/etc/datasets.json || check_error rm_rf
fab -f cluster.py -R metrics send_template:datasets.json,~/metrics/etc/datasets.json || check_error send_template

# ship logstash shipper configs
fab -f cluster.py -R metrics send_shipper_conf:metrics,/home/${OPS_USER}/metrics/log,${MOZART_ES_CLUSTER},${MOZART_PVT_IP},${METRICS_ES_CLUSTER},127.0.0.1 || check_error send_shipper_conf

# ship kibana config
fab -f cluster.py -R metrics send_template:kibana.yml,~/kibana/config/kibana.yml || check_error send_template


# update worker configs for metrics
#fab -f cluster.py -R metrics rm_rf:~/metrics/etc/workers || check_error rm_rf
#fab -f cluster.py -R metrics mkdir:~/metrics/etc/workers,ops,ops || check_error mkdir

# expose hysds log dir via webdav
#fab -f cluster.py -R metrics ln_sf:~/metrics/log,/data/work/log || check_error ln_sf

# ship AWS creds
fab -f cluster.py -R metrics send_awscreds || check_error send_awscreds
