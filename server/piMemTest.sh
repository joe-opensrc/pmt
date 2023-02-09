#!/bin/bash

trap '{ rm -f /tmp/pi; exit 0;}' HUP INT TERM KILL EXIT

mkfifo /tmp/pi 
function assertInteger(){
  if ! [[ ${1} =~ ^[0-9]+$ ]]
  then
   echo "type(${np}) != Integer" >&2
   exit 9
  fi
}

exec 9<>/tmp/pi
pi ${1:-51} >&9

# state; but if you're capable of memorizing pi upto MAX_INTEGER
# this is the least of your worries
i=0

echo 'PI (q-quit):'
while read -n1 -u9 p
do
  if [[ "x${p}" == "x" ]]
  then
    echo -e '\nNice'
    exec 9>&-
    exit 0
  fi

  while read -n1 -u0 -s d
  do

    if [[ "${d}" == $'\f' ]]
    then
      clear
      pi ${i} | head -c -2
      continue
    fi

    if [[ "${d}" == "${p}" ]]
    then
      echo -n "${p}"
      break
    else

      if [[ "${d}" == "q" ]]
      then
        echo -e "\nBye."
        exit 0
      fi

      echo -e "${d} -> ${p}"
      pi ${i} | head -c -2 # utf8-yerself 

    fi
  done

  (( i++ ))
done 

