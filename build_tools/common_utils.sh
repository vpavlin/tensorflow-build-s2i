#!/bin/bash -e
# Common functions
#
# ----------------------------

command_exists () { type "$1" &> /dev/null ; }
file_exists () { test -f $1 ; }
folder_exists () { test -d $1 ; }
MY_EXIT_1() {  echo "ERROR:variable not set" && exit 1; }
MY_RETURN_1() {  return 1; }
MY_RETURN_0() {  return 0; }
env_check () {
  exit_function=MY_RETURN_0;
  # If exit function is passed as $2 use it.
  if [[ ! -z "$2" ]];then exit_function=$2 ;fi 
  if [ $# -eq 0 ];then printf "No arguments supplied. \nUsage:\n env_check \"ENV_NAME\" [\"exit_function\"]\n" && $exit_function;fi
  param=$1;
  # The exclamation mark makes param to get the value of the variable with that name.
  if [[ -z "${!param}" ]];then echo "$1 is undefined" && $exit_function; else echo "$1 = "${!param} ;fi 
}

major=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
minor=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f2)
OSVER=$(cat /etc/redhat-release | cut -d' ' -f1 |  awk '{print tolower($0)}')
echo "OSVER = "$OSVER
export OS_VERSION="$OSVER$major"
echo "OS_VERSION = "$OS_VERSION
