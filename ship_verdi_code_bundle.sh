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

# create code bundles for each project
for project in $PROJECTS; do

  # send project-specific install.sh script and datasets.json
  fab -f cluster.py -R verdi rm_rf:~/verdi/ops/install.sh || check_error rm_rf
  fab -f cluster.py -R verdi rm_rf:~/verdi/etc/datasets.json || check_error rm_rf
  fab -f cluster.py -R verdi rm_rf:~/verdi/etc/supervisord.conf || check_error rm_rf
  fab -f cluster.py -R verdi rm_rf:~/verdi/etc/supervisord.conf.tmpl || check_error rm_rf
  fab -f cluster.py -R verdi send_project_config:${project} || check_error send_project_config
  fab -f cluster.py -R verdi chmod:755,~/verdi/ops/install.sh || check_error chmod
  fab -f cluster.py -R verdi chmod:644,~/verdi/etc/datasets.json || check_error chmod
  
  # copy config
  fab -f cluster.py -R verdi rm_rf:~/verdi/ops/etc || check_error rm_rf
  fab -f cluster.py -R verdi cp_rp:~/verdi/etc,~/verdi/ops/ || check_error cp_rp
  
  # copy creds
  fab -f cluster.py -R verdi rm_rf:~/verdi/ops/creds || check_error rm_rf
  fab -f cluster.py -R verdi mkdir:~/verdi/ops/creds,ops,ops || check_error mkdir
  fab -f cluster.py -R verdi cp_rp:~/.netrc,~/verdi/ops/creds/ || check_error cp_rp
  fab -f cluster.py -R verdi cp_rp:~/.boto,~/verdi/ops/creds/ || check_error cp_rp
  fab -f cluster.py -R verdi cp_rp:~/.s3cfg,~/verdi/ops/creds/ || check_error cp_rp
  fab -f cluster.py -R verdi cp_rp:~/.aws,~/verdi/ops/creds/ || check_error cp_rp
  
  # send work directory stylesheets
  fab -f cluster.py -R verdi rm_rf:~/verdi/ops/beefed-autoindex-open_in_new_win.tbz2 || check_error rm_rf
  fab -f cluster.py -R verdi copy:~/hysds_cluster_setup/files/beefed-autoindex-open_in_new_win.tbz2,~/verdi/ops/beefed-autoindex-open_in_new_win.tbz2 || check_error copy
  
  # create ops bundle
  fab -f cluster.py -R verdi rm_rf:~/${project}-ops.tbz2 || check_error rm_rf
  fab -f cluster.py -R verdi ship_code:~/verdi/ops,~/${project}-ops.tbz2,true || check_error ship_code
done
