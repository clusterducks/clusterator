#!/bin/bash
## ==================================
## Script to spin up Docker hosts
## Initial verison: Mike Sandman
## Updated version: Petar Smilajkov
## ==================================
## Updates: 
## - 12/15/2015 - added option switches and help - Petar Smilajkov
## ================================================================
## Todo: 
##     [] Add other providers (amazon, linode, etc.)
##     [] Do some error checking for provided argument values
##     [] Create better help printout (default one is kindof janky)
##     [] Read API Keys for services from Environment Variables
## ================================================================

# source shflags
source @BASHLIBS@/shflags

DEFINE_string 'name' 'dh' 'name prefix to be used in the full docker host name' 'n'
DEFINE_string 'provider' 'vb' 'provider identifier on which to spin up docker hosts -> vb = VirtualBox, do = Digital Ocean, aws = Amazon Web Services, ssh = Generic Linux Host (via SSH)' 'p'
DEFINE_string 'ip' '127.0.0.1' 'used only with -p as the IP address of the Linux host (csv for more than one)' 'i'
DEFINE_string 'user' 'root' 'used only with -p as the SSH user' 'u'
DEFINE_string 'key' '~/.ssh/id_rsa' 'used only with -p as the path to the SSH key to log into the Linux host' 'k'
DEFINE_string 'quantity' '3' 'number of docker hosts to spin up' 'q'
DEFINE_string 'region' 'local' 'region identifier for new docker hosts -> local (for VirtualBox), nyc1..3, ams1..3, sfo1..3, sgp1..3, lon1..3 (DigitalOcean)' 'r'
DEFINE_string 'size' '2gb' 'Size of machine (512mb, 1gb, 2gb, ..., 64gb)' 's'

# parse the command-line
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# if help - just exit
if [ "${FLAGS_help}" -eq ${FLAGS_TRUE} ]; then exit 1; fi

# set fonts for help highlights
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

# API Keys
DO_KEY=""

function create_machine {
  local PROVIDER=$1
  local REGION=$2
  local SIZE=$3
  local FULLNAME=$4
  local IP_ADDRESS=$5
  local SSH_KEY=$6
  local SSH_USER=$7
  local NODENUMBER=$8
  local PREFIX=""

  case ${#NODENUMBER} in
    0)
      echo "What a heck?"
      exit 1
      ;;
    1)
      PREFIX="000$NODENUMBER"
      ;;
    2)
      PREFIX="00$NODENUMBER"
      ;;
    3)
      PREFIX="0$NODENUMBER"
      ;;
    *)
      PREFIX="$NODENUMBER"
      ;;
  esac

  case $PROVIDER in
    vb)
      echo $PREFIX.$FULLNAME
      docker-machine create \
        --driver virtualbox \
        $PREFIX.$FULLNAME &
      ;;
    do)
      docker-machine create \
        --driver digitalocean \
        --digitalocean-access-token=$DO_KEY \
        --digitalocean-region=$REGION \
        --digitalocean-size=$SIZE \
        $PREFIX.$FULLNAME &
      ;;
    aws)
      echo "Amazon Web Services (TODO)"
      ;;
    ssh)
      docker-machine create \
        --driver generic \
	--generic-ip-address $IP_ADDRESS \
	--generic-ssh-user $SSH_USER \
	--generic-ssh-key $SSH_KEY \
	$PREFIX.$FULLNAME &
      ;;
    *)
      echo "ERROR: Unknown Provider: $PROVIDER"
      flags_help
      exit 1
  esac
}

# init vars to default values
NAME="dh"
PROVIDER="vb"
IP_ADDRESS=""
SSH_KEY=""
SSH_USER="root"
QUANTITY=3
REGION="local"
SIZE="2gb"

echo ""
echo "FLAGS:"
echo "- Name    : ${FLAGS_name}"
echo "- Provider: ${FLAGS_provider}"
echo "- IP      : ${FLAGS_ip}"
echo "- SSH KEY : ${FLAGS_key}"
echo "- SSH USER: ${FLAGS_user}"
echo "- QUANTITY: ${FLAGS_quantity}"
echo "- REGION  : ${FLAGS_region}"
echo "- VM SIZE : ${FLAGS_size}"

# update variables with submitted data
if [[ "${FLAGS_name}" ]]; then NAME="${FLAGS_name}"; fi
if [[ "${FLAGS_provider}" ]]; then PROVIDER="${FLAGS_provider}"; fi
if [[ "${FLAGS_ip}" ]]; then IP_ADDRESS="${FLAGS_ip}"; fi
if [[ "${FLAGS_key}" ]]; then SSH_KEY="${FLAGS_key}"; fi
if [[ "${FLAGS_user}" ]]; then SSH_USER="${FLAGS_user}"; fi
if [[ "${FLAGS_quantity}" ]]; then QUANTITY="${FLAGS_quantity}"; fi
if [[ "${FLAGS_region}" ]]; then REGION="${FLAGS_region}"; fi
if [[ "${FLAGS_size}" ]]; then SIZE="${FLAGS_size}"; fi

echo ""
echo "New Vars:"
echo "- Name    : $NAME"
echo "- Provider: $PROVIDER"
echo "- IP      : $IP_ADDRESS"
echo "- SSH KEY : $SSH_KEY"
echo "- SSH USER: $SSH_USER"
echo "- QUANTITY: $QUANTITY"
echo "- REGION  : $REGION"
echo "- VM SIZE : $SIZE"

FULLNAME="$NAME.$PROVIDER.$REGION"

# if ssh, let's attack this differently
if [ "$PROVIDER" == "ssh" ]; then

# parse CSV IP's into an array for easier management
IFS=',' read -r -a IPARRAY <<< "${FLAGS_ip}"

# update quantity
QUANTITY=${#IPARRAY[@]}

echo ""
echo "Spinning up Docker Cluster: 0001-$QUANTITY.$NAME.$PROVIDER.$REGION"

# go through all IP's
COUNT=0
for currentIp in "${IPARRAY[@]}"
do
    ((COUNT++))
    echo "- Provisionging docker to: $currentIp (node $COUNT/$QUANTITY)"
    create_machine $PROVIDER $REGION $SIZE $FULLNAME $currentIp $SSH_KEY $SSH_USER $COUNT
done

else

#create docker host nodes the usual way
for ((i=1; i <= QUANTITY ; i++)) do
  echo "- Provisioning docker to node #$i/$QUANTITY"
  create_machine $PROVIDER $REGION $SIZE $FULLNAME $IP_ADDRESS $SSH_KEY $SSH_USER $i
done

fi

