#!/bin/sh

list=""
#list="$list Submission_Data_2012A "
list="$list Submission_Data_2012B "
list="$list Submission_Data_2012B_try2 "
list="$list Submission_Data_2012C "
list="$list Submission_Data_2012D "

for f in $list ;
do
  ./Submit.sh $f
done
