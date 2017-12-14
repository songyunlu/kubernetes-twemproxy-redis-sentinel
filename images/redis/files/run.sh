#!/bin/sh

function launchmaster() {
  if [[ ! -e /data ]]; then
    echo "Redis master data doesn't exist, data won't be persistent!"
    mkdir /data
  fi
  redis-server /redis-master/redis.conf --protected-mode no
}

function launchsentinel() {
  namespace=${NAMESPACE:-infra}
  sentinel_number=$(hostname | sed -e "s/sentinel-//g")
  sentinel_conf=sentinel.conf
  n=0

  echo "configure sentinel ${sentinel_number}"
  # write to sentinel.conf
  echo "bind 0.0.0.0" > ${sentinel_conf}
  echo 'dir "/tmp"' >> ${sentinel_conf}
  while [ $n -le $sentinel_number ]; do

    master=redis-${n}.redis.${namespace}.svc.cluster.local
    master_name=redis-master-${n}

    while true; do
      redis-cli -h ${master} INFO
      if [[ "$?" == "0" ]]; then
        break
      fi
      echo "Connecting to master failed.  Waiting..."
      sleep 10
    done

    echo "sentinel monitor ${master_name} ${master} 6379 2" >> ${sentinel_conf}
    echo "sentinel down-after-milliseconds ${master_name} 60000" >> ${sentinel_conf}
    echo "sentinel failover-timeout ${master_name} 180000" >> ${sentinel_conf}
    echo "sentinel parallel-syncs ${master_name} 1" >> ${sentinel_conf}
    n=$(( n+1 ))
  done

  redis-sentinel ${sentinel_conf} --protected-mode no
}

function launchslave() {
  while true; do
    master=$(redis-cli -h ${SENTINEL_SERVICE_HOST} -p ${SENTINEL_SERVICE_PORT} --csv SENTINEL get-master-addr-by-name mymaster | tr ',' ' ' | cut -d' ' -f1)
    if [[ -n ${master} ]]; then
      master="${master//\"}"
    else
      echo "Failed to find master."
      sleep 60
      exit 1
    fi 
    redis-cli -h ${master} INFO
    if [[ "$?" == "0" ]]; then
      break
    fi
    echo "Connecting to master failed.  Waiting..."
    sleep 10
  done
  sed -i "s/%master-ip%/${master}/" /redis-slave/redis.conf
  sed -i "s/%master-port%/6379/" /redis-slave/redis.conf
  redis-server /redis-slave/redis.conf --protected-mode no
}

if [[ "${MASTER}" == "true" ]]; then
  launchmaster
  exit 0
fi

if [[ "${SENTINEL}" == "true" ]]; then
  launchsentinel
  exit 0
fi

launchslave
