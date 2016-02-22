#!/bin/bash
[ -f $1/merged.csv ] && rm $1/merged.csv

for f in $1/worker_*.csv; do 
    cat $f >> $1/merged.csv
done
#echo "Merging done."