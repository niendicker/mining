#!/bin/bash

input_file=query_out.csv
write_data=tsdb_write_gpu1.sh

while [ true ]
do
   if [ -f $input_file ]
   then
      ./$write_data
      rm $input_file
   else
      sleep .1
   fi
done
