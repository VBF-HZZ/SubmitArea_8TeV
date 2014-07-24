#!/bin/sh

for DIR in Data_2012A Data_2012B Data_2012B_try2 Data_2012C Data_2012D;
do
  echo in $DIR
  outdir="${DIR}_RMDUP"
  if [ ! -e $outdir ]; then 
    mkdir $outdir
  fi

  for FILE in $DIR/*.txt;
  do
    echo checking file $FILE
    basefile=`basename $FILE`
    ./removeDuplicatedFiles.sh $FILE $outdir/$basefile
  done
done
