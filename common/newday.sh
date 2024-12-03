#!/bin/bash

day=$1

if [ -z "$day" ]; then
  echo "Usage: $0 DAY"
  echo " DAY is a day number like 03, 14, 25, etc"
  exit 1
fi

mkdir $day
cp `dirname $0`/solution.rb ${day}/${day}.rb
cd $day
