#!/bin/bash
source context.sh
source $HOME/mozart/bin/activate

cd $(dirname $0)

function check_error {
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "Failed to run $1." 1>&2
    exit $STATUS
  fi
}

supervisorctl shutdown

# clean out rabbitmq queues
user=$MOZART_RABBIT_USER
passwd=$MOZART_RABBIT_PASSWORD
for i in `curl -s -u ${user}:${passwd} ${MOZART_RABBIT_PVT_IP}:15672/api/queues?columns=name | python -m json.tool | grep '"name"' | awk 'BEGIN{FS="\""}{print $4}'`; do
  curl -s -u ${user}:${passwd} -XDELETE ${MOZART_RABBIT_PVT_IP}:15672/api/queues/%2f/$i
  echo "Deleted queue $i."
done

# clean out redis
redis-cli -h ${MOZART_REDIS_PVT_IP} flushall

# clean out ES
curl -XDELETE http://${MOZART_ES_PVT_IP}:9200/_template/*_status
echo
$HOME/mozart/ops/hysds/scripts/clean_job_status_indexes.sh http://${MOZART_ES_PVT_IP}:9200
echo
$HOME/mozart/ops/hysds/scripts/clean_task_status_indexes.sh http://${MOZART_ES_PVT_IP}:9200
echo
$HOME/mozart/ops/hysds/scripts/clean_worker_status_indexes.sh http://${MOZART_ES_PVT_IP}:9200
echo
$HOME/mozart/ops/hysds/scripts/clean_event_status_indexes.sh http://${MOZART_ES_PVT_IP}:9200
echo
#$HOME/mozart/ops/hysds/scripts/clean_job_spec_container_indexes.sh http://${MOZART_ES_PVT_IP}:9200
#echo

# clean out logs
rm -rf ~/mozart/log/*

# start supervisord
supervisord
