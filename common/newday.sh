#!/bin/bash

day=$1
err=0

if [ -z "$day" ]; then
  echo "DAY must be specified."
  err=1
fi

if [ -e "$day" ]; then
  echo "DAY directory $day exists."
  err=2
fi

if [ $err -ne 0 ]; then
  echo "Usage: $0 DAY"
  echo " DAY is a day number like 03, 14, 25, etc"
  exit $err
fi

mkdir $day
cp `dirname $0`/solution.rb ${day}/${day}.rb
cd $day
