#!/bin/bash

trap 'rm -f /tmp/pi' HUP INT TERM KILL EXIT

mkfifo /tmp/pi 

exec 9<>/tmp/pi
pi ${1:-51} >&9

echo 'PI:'
while read -n1 -u9 p
do

  if [[ "x${p}" == "x" ]]
  then
    echo -e '\nNice'
    exec 9>&-
    exit 0
  fi

  read -n1 -u0 -s d
  if [[ "${d}" == "${p}" ]]
  then
    echo -n "${p}"
  else
    echo -e "\n${d} -> ${p}"
    exec 9>&-
    exit 1
  fi

done 

