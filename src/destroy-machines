#!/bin/bash

## ==================================
## Script to delete Docker hosts
## Initial verison: Mike Sandman
## Updated version: Petar Smilajkov
## ==================================
## Updates:
## - 12/16/2015 - expanded the initial version - Petar Smilajkov
## ================================================================

# set fonts for help highlights
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

function show_help {
  cat << EOF
Usage: ${BOLD}destroy-machines${NORM} [-n|--name | -q|--quantity]

Example: ${REV}destroy-machines -n dh.do.nyc3 -q 3${NORM}
-> Destroys a specified -q NUMBER of Docker Hosts prefixed with -n dockerhost.do.nyc3 name.
-> I.e. 0001.dockerhost.do.nyc3, 0002.dockerhost.do.nyc3, and 0003.dockerhost.do.nyc3

Example: ${REV}destroy-machines -n 0001.dockerhost.do.nyc3${NORM}
-> Destroys 0001.dockerhost.do.nyc3 machine (single machine w/ full name as specified)

        -h|--help               displays this help

        -n|--name NAME          [REQUIRED] full name of the docker host to remove
                                ex: 0001.dh.do.nyc3 (for removing a single machine)
				ex2: dh.do.nyc (w/o #) if used with -q switch (deletes > 1 machine)

	-q|--quantity NUMBER	[OPTIONAL] number of docker hosts to delete 
                                -> will start from 0001 and go UP to NUMBER specified (inclusive)
                                ex: 3 -> this will delete hosts 0001.NAME, 0002.NAME and 0003.NAME
				if not provided, only docker host specified with -n NAME will be deleted

EOF
}

function destroy_machines {
  local NAME=$1
  local QUANTITY=$2

  if [[ $QUANTITY -eq 1 ]]; then
    destroy_machine $NAME
  else
    for ((a=1; a <= QUANTITY ; a++)) do
      PREFIX=""
      case ${#QUANTITY} in
        0)
          echo "What a heck?"
          exit 1
          ;;
        1)
          PREFIX="000$a"
          ;;
        2)
          PREFIX="00$a"
          ;;
        3)
          PREFIX="0$a"
          ;;
        *)
          PREFIX="$a"
          ;;
      esac

      destroy_machine "$PREFIX.$NAME"
    done
  fi  
}

function destroy_machine {
  local NAME=$1
  echo "Destorying machine: $NAME"
  docker-machine rm "$NAME" &
}

NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
  show_help
fi

# init vars to default values
NAME=""
PROVIDER="do"
QUANTITY=0

while getopts "h help n::name::p:provider:q:quantity:" opt; do
  case $opt in
    n|name)
      NAME=$OPTARG
      ;;
    p|provider)
      PROVIDER=$OPTARG
      ;;
    q|quantity)
      QUANTITY=$OPTARG
      ;;
    h|help)
      show_help
      exit 1;
      ;;
    \?)
      show_help
      exit 1
      ;;
  esac
  shift $((OPTIND-1))
done

destroy_machines $NAME $QUANTITY
