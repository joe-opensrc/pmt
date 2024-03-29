#!/bin/bash

trap '{ rm -f /tmp/pi; exit 0;}' HUP INT TERM KILL EXIT

function assertInteger(){
  if ! [[ ${1} =~ ^[0-9]+$ ]]
  then
   echo "type(${1}) != Integer" >&2
   exit 9
  fi
}

helpMenu="
  q or Ctrl+d := quit
  i           := info
  h           := this help menu
  Ctrl+l      := clear"

usg="
$(basename ${0}) [<no. of decimals>] [<start/offset>]
${helpMenu}"

# num places
np=6 #1
# start place
sp=1

# state; but if you're capable of memorizing pi upto MAX_INTEGER
# this is the least of your worries :)
i=0
e=0

# basic help standard
echo "${@}" | grep -E '(\-h|\-\-help)' &>/dev/null
if [[ $? -eq 0 ]]
then
  echo -en "${usg}\n\n"
  exit 0
fi

if [[ ${#} -gt 0 ]]
then
    assertInteger ${1}
    np=$(( ${1} + 1 ))
fi

  mkfifo /tmp/pi 
  exec 9<>/tmp/pi
  pi ${np} >&9

  if [[ -n ${2} ]]
  then
    assertInteger ${2}
    sp=$(( ${2} + 2 ))
    if [[ ${2} -lt $(( ${np} -1 )) ]]
    then
      read -n ${sp} -u9 
      i=${sp} 
    else
      echo -e "${0} <num_decimals> <start_offset>\nE: start_offset !< num_decimals" >&2
      exit 9
    fi
  fi



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
    if [[ "${d}" == '' ]]
    then
      clear
      pi ${i} | head -c -2
      continue
    fi

    if [[ "${d}" == "${p}" ]]
    then
      echo -n "${p}"
      (( i++ ))
      (( e++ ))
      break
    else

      if [[ "${d}" == "q" || "${d}" == '' ]]
      then
        echo -e "\nBye."
        exit 0
      fi


      if [[ "${d}" == "i" ]]
      then
        clear
        echo "pos: ${i}|attempts: ${e}"
        continue
      fi

      if [[ "${d}" == "h" ]]
      then
        clear
        echo -ne "${helpMenu}" 
        continue
      fi

      echo -e "${d} -> ${p}"
      pi ${i} | head -c -2 # utf8-yerself 

      (( e++ ))

    fi
  done

done 


