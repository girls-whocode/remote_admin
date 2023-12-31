#!/usr/bin/env bash

function setPattern() {
  compName=$(hostname)
  standardPattern='
      s/\[/\e[1;33m$&\e[0;36m/g; 
      s/\]/\e[1;33m$&\e[0m/g; 
      s/"(.*?)"/\e[0;33m$&\e[0m/g;
      s/[0-9]{2}\-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\-[0-9]{4}/\e[1;94m$&\e[0m/g; 
      s/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s[0-9]{2}\s[0-9]{4}/\e[1;94m$&\e[0m/g;
      s/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s[0-9]{2}/\e[1;94m$&\e[0m/g;
      s/[0-9]{4}\-[0-9]{2}\-[0-9]{2}/\e[1;94m$&\e[0m/g;
      s/[0-9]{4}\/[0-9]{2}\/[0-9]{2}/\e[1;94m$&\e[0m/g;
      s/[0-9]{2}\:[0-9]{2}\:[0-9]{2}/\e[1;34m$&\e[0m/g;
      s/'${compName}'/\e[1;32m$&\e[0m/g;
      s/Log\sstarted\:/\e[0;36m$&\e[0m/g;
      s/Log\sended\:/\e[0;36m$&\e[0m/g;
      s/(WARNING|WARN)/\e[1;93m$&\e[0m/g; 
      s/(ERROR|ERR|error?)/\e[1;31m$&\e[0m/g; 
      s/SEVERE/\e[1;31m$&\e[0m/g; 
      s/INFO/\e[1;36m$&\e[0m/g; 
      s/CMD/\e[0;43m$&\e[0m/g; 
      s/LIST/\e[1;45m$&\e[0m/g;
      s/(DEBUG|DBG|debug)/\e[1;30m$&\e[0m/g; 
      s/(debug1|DEBUG1)/\e[1;93m$&\e[33m/g; 
      s/(debug2|DEBUG2)/\e[1;96m$&\e[36m/g;
      s/(debug3|DEBUG3)/\e[1;91m$&\e[31m/g; 
      s/Started/\e[1;42m$&\e[0m/g; 
      s/Reached/\e[1;46m$&\e[0m/g; 
      s/Mounted/\e[1;42m$&\e[0m/g;
      s/Listening/\e[1;45m$&\e[0m/g;
      s/Finished/\e[1;42m$&\e[0m/g;
      s/^.*============.*/\e[1;32m$&\e[0m/g;
      s/^.*-----.*/\e[1;32m$&\e[0m/g;
  '

  if [ "$1" != "" ]; then
    additionalSearchPattern='s/'$1'/\e[0;30;43m$&\e[0m/g;'
    searchPattern="$standardPattern$additionalSearchPattern"
  else
    searchPattern=$standardPattern
  fi
}

function logview() {
  setPattern $2
  cat $1 | perl -pe "$searchPattern"
  searchPattern=$standardPattern
}
