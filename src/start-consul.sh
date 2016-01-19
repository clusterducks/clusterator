#!/bin/bash -e

if [[ $# < 1 ]]; then
echo 'docker-machine name pattern required'
exit 1
fi

MACHINE_PATTERN=$1

. @BARNEYDIR@/docker-machines

MACHINE_NAMES=($(grep_docker_machine_names $MACHINE_PATTERN | awk '{print $1}'))
#echo "$MACHINE_NAMES"

MACHINE_COUNT=`echo "$MACHINE_NAMES" | wc -l`
#echo "count:" $MACHINE_COUNT

CONSUL_QUORUM="-bootstrap-expect $(($MACHINE_COUNT / 2 + 1))"
#echo "quorum:" $QUORUM

FIRST=${MACHINE_NAMES[0]}
#echo "first: " $FIRST

CONSUL_JOINABLE="-join $(docker-machine ip $FIRST):8301"
#echo $CONSUL_JOINABLE

for machine in ${MACHINE_NAMES[@]}; do
  if [ "$machine" != "$FIRST" ]; then
    export CONSUL_QUORUM_OR_JOIN="$CONSUL_JOINABLE"
  else
    export CONSUL_QUORUM_OR_JOIN="$CONSUL_QUORUM"
  fi

  echo $machine
  export CONSUL_BIND_ADDR=$(docker-machine ip $machine)
  echo $CONSUL_BIND_ADDR
  echo $CONSUL_QUORUM_OR_JOIN

  eval "$(docker-machine env $machine)"
  docker-compose up -f @ADATADIR@/docker-compose.yml -d consul
done

#docker-machine ls | grep clusterator | awk '{print $1}' | xargs 'eval "\$(docker-machine env {})" && docker ps'