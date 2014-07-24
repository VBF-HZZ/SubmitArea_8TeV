#!/bin/sh

list=""
list="$list Submission_Data_2012A_RMDUP "
list="$list Submission_Data_2012B_RMDUP "
list="$list Submission_Data_2012C_RMDUP "
list="$list Submission_Data_2012D_RMDUP "

for f in $list ;
do
  ./Submit.sh $f
done
