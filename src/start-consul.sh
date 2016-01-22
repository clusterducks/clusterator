#!/bin/bash -e

if [[ $# < 2 ]]; then
echo 'required params: <docker-machine name pattern> <start|stop>'
exit 1
fi

MACHINE_PATTERN=$1
COMMAND=$2

# defaults for docker-compose.yml
export MACHINE_IP=""
export CONSUL_QUORUM_OR_JOIN=""
export CLUSTER_NAME=barney
export DOCKER_MACHINE_CERTS=/var/lib/boot2docker

. @BARNEYDIR@/docker-machines
MACHINE_NAMES=($(grep_docker_machine_names $MACHINE_PATTERN | awk '{print $1}'))

start_consul() {
MACHINE_COUNT=`echo "$MACHINE_NAMES" | wc -l`
CONSUL_QUORUM="-bootstrap-expect $(($MACHINE_COUNT / 2 + 1))"
FIRST=${MACHINE_NAMES[0]}
CONSUL_JOINABLE="-join $(docker-machine ip $FIRST):8301"

for machine in ${MACHINE_NAMES[@]}; do
  if [ "$machine" != "$FIRST" ]; then
    export CONSUL_QUORUM_OR_JOIN="$CONSUL_JOINABLE"
  else
    export CONSUL_QUORUM_OR_JOIN="$CONSUL_QUORUM"
  fi

  echo $machine
  export MACHINE_IP=$(docker-machine ip $machine)
  echo $MACHINE_IP
  echo $CONSUL_QUORUM_OR_JOIN

  eval "$(docker-machine env $machine)"
  docker-compose -f @ADATADIR@/docker-compose.yml up -d
done

}

stop_consul() {
for machine in ${MACHINE_NAMES[@]}; do
  echo $machine
  eval "$(docker-machine env $machine)"
  docker-compose -f @ADATADIR@/docker-compose.yml stop
  docker-compose -f @ADATADIR@/docker-compose.yml rm -fv
done
}

if [ "$COMMAND" = "start" ]; then
  start_consul
elif [ "$COMMAND" = "stop" ]; then
  stop_consul
else
  echo 'Unknown command: ' $COMMAND
  exit 1
fi
