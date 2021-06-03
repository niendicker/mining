#!/bin/bash

#Help 
#if [ $1 = "-h" ]
#then
#   echo "+-----------------------------------------------------------------------------------+"
#   echo "|                                     Format                                        |"
#   echo "+-----------------------------------------------------------------------------------+"
#   echo "|Data count: 6                                                                      |"
#   echo "|Data order: temp(C), fan(%), mem_clk(MHz), core_clk(MHz), hash_rate(MH), power(W)  |"
#   echo "+-----------------------------------------------------------------------------------+"
#   exit
#fi

#File received from mining rig with GPU info
input_file=query_out.csv

#Data from CSV file splitted into lines, for [read] command
tmp_file=tmp.info
if [ -f $input_file ] 
then
   cat $input_file | tr -s ', ' '\n' > $tmp_file
else
   echo "Data file $input_file not found. Aborting..."
   exit
fi

#Store data loaded from tmp_file
data_buffer=(0 0 0 0 0 0)
data_idx=0

if [ -f $tmp_file ]
then
   while read gpu_data 
   do
      data_buffer[$data_idx]=$gpu_data
      data_idx=$((data_idx+1))
   done < $tmp_file
   
   #housekeeper
   rm $tmp_file
else
   echo "Temporary file $tmp_file not found. Aborting..."
   exit
fi

gpu_temp=${data_buffer[0]}
gpu_fan=${data_buffer[1]}
gpu_mem_clk=${data_buffer[2]}
gpu_core_clk=${data_buffer[3]}
gpu_hash_rate=0 #I don't know (yet) how to get hash rate
gpu_power=${data_buffer[4]}


#Write [gpu1] new data do [mining] database
if [ $data_idx -eq 5 ]
then
   psql -q -U postgres -h localhost -d mining -c \
      " INSERT INTO gpu1 VALUES(NOW(), $gpu_temp, $gpu_fan, $gpu_mem_clk, $gpu_core_clk, $gpu_hash_rate, $gpu_power); "
   printf .
else
   printf "\nErro na formatação dos dados: ${data_buffer[@]}"
   echo
fi
