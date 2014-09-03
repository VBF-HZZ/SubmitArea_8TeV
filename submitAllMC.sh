#!/bin/sh

list=""
#list="$list Submission_HZZSamples_RMDUP "
#list="$list Submission_HZZSamples_ExtendLegacy"
list="$list Submission_HZZSamples_Sept"


for f in $list ;
do
  ./Submit.sh $f
done
