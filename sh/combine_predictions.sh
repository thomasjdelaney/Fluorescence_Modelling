#!/bin/bash

# example: ./sh/combine_predictions.sh 8 paninski.thresh.train spikes 3

spike_finder_dir=$HOME/Spike_finder/train/

dataset_number=$1 # first command like argument is the dataset to use
pattern=$2
spikes_or_calcium=$3
column_number=$4
tmp_file=/tmp/tmp.$dataset_number.$pattern.$spikes_or_calcium.csv
final_file=$spike_finder_dir$dataset_number.$pattern.$spikes_or_calcium.csv
column_names=""

for f in `ls -tr $spike_finder_dir$dataset_number*$pattern.csv`
do
  filename_array=(${f//./ })
  column_name=x${filename_array[1]}
  column_names=$column_names$column_name,
  if [ -f $tmp_file ]
  then
    really_tmp_file=`mktemp`
    paste -d, $tmp_file <(cut -d , -f $column_number $f) > $really_tmp_file
    mv $really_tmp_file $tmp_file
  else
    cut -d , -f $column_number $f >> $tmp_file
  fi
  rm $f
done

sed -i "1s;^;$column_names\n;" $tmp_file
sed -i 's/,$//' $tmp_file
mv $tmp_file $final_file
echo $final_file
# add the column names as the first line
