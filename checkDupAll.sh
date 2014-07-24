#!/bin/sh

for DIR in Data_2012A Data_2012B Data_2012B_try2 Data_2012C Data_2012D;
do
  echo in $DIR
  for FILE in $DIR/*.txt;
  do
    echo checking file $FILE
    ./checkDuplicatedFiles.sh $FILE
  done
done
