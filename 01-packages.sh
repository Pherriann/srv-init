#!/bin/bash

cwd=$(dirname $0)

if [[ -f $cwd/packages.lst ]]; then
  for i in $( cat $cwd/packages.lst); do
    sudo yum install $i -y
  done  
else
  echo "File $cwd/packages.lst missing"
  return 1
fi

