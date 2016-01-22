#!/bin/bash

## ==================================
## Script to delete Docker hosts
## Initial verison: Mike Sandman
## Updated version: Petar Smilajkov
## ==================================
## Updates:
## - 12/16/2015 - expanded the initial version - Petar Smilajkov
## - 01/22/2016 - switched to shflags and fixed some issues
## ================================================================

# source shflags
source @BASHLIBS@/shflags

# set fonts for help highlights
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

DEFINE_string 'name' 'dh' 'full name (or suffix before 000X) of the docker host to remove' 'n'
DEFINE_string 'provider' 'vb' 'provider identifier (vb=virtual box, do=digital ocean, ssh=generic, etc.)' 'p'
DEFINE_string 'quantity' '1' 'number of docker hosts to delete (will start from 0001, up to number you specify)' 'q'

# parse the command-line
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# if help - just exit
if [ "${FLAGS_help}" -eq ${FLAGS_TRUE} ]; then exit 1; fi

function destroy_machines {
  local NAME=$1
  local PROVIDER=$2
  local QUANTITY=$3

  if [ "$PROVIDER" == "vb" ]; then
    SUFFIX=".local"
  else
    SUFFIX=""
  fi

  if [[ $QUANTITY -eq 1 ]]; then
    destroy_machine "0001".$NAME.$PROVIDER$SUFFIX
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

      destroy_machine "$PREFIX.$NAME.$PROVIDER$SUFFIX"
    done
  fi  
}

function destroy_machine {
  local NAME=$1
  echo "Destorying machine: $NAME"
  docker-machine rm "$NAME" &
}

# init vars to default values
NAME=""
PROVIDER="vb"
QUANTITY=0

echo ""
echo "FLAGS:"
echo "- Name    : ${FLAGS_name}"
echo "- Provider: ${FLAGS_provider}"
echo "- Quantity: ${FLAGS_quantity}"

# update variables with submitted data
if [[ "${FLAGS_name}" ]]; then NAME="${FLAGS_name}"; fi
if [[ "${FLAGS_provider}" ]]; then PROVIDER="${FLAGS_provider}"; fi
if [[ "${FLAGS_quantity}" ]]; then QUANTITY="${FLAGS_quantity}"; fi

echo ""
echo "New Vars:"
echo "- Name    : $NAME"
echo "- Provider: $PROVIDER"
echo "- Quantity: $QUANTITY"

destroy_machines $NAME $PROVIDER $QUANTITY
