#!/bin/bash

fluorescence_modelling_dir=$HOME/Fluorescence_Modelling
spike_finder_dir=$HOME/Spike_finder/train/
optimisation_dir=$SPACE/optimisation_csvs
dataset_number=$1 # first command like argument is the dataset to use
fl_file=$spike_finder_dir$dataset_number.train.calcium.csv
sp_file=$spike_finder_dir$dataset_number.train.spikes.csv
traces=`head -1 $fl_file | sed "s/,/ /g"`
tmp_file=/tmp/tmp$dataset_number.cols.csv

for t in $traces
do
  echo `date +"%Y.%m.%d %T"` " Processing trace number $t..."
  opt_file=$optimisation_dir/comp_opt_"$dataset_number"_"$t"_2e-2.csv
  free_param_options=`$SPACE/julia/bin/julia $fluorescence_modelling_dir/jl/build_command_from_opt.jl --opt_file $opt_file`

  save_filename=$dataset_number.$t.model.csv
  $SPACE/julia/bin/julia $fluorescence_modelling_dir/jl/fluorescence_modelling.jl --spike_file $sp_file --calcium_file $fl_file --frequency 100.0 --colname $t --title $save_filename --save_fluoro $free_param_options
  echo $save_filename
  save_file=$spike_finder_dir$save_filename
  if [ -f $save_file ]
  then
    if [ -f $tmp_file ]
    then
      really_tmp_file=`mktemp`
      paste -d, $tmp_file <(cut -d , -f 2 $save_file) > $really_tmp_file
      mv $really_tmp_file $tmp_file
    else
      cut -d , -f 2 $save_file > $tmp_file
    fi
    column_name=x$t
    sed -i s/\"fluorescence\"/$column_name/g $tmp_file
    rm $save_file
  else
    echo "$save_file does not exist."
  fi
done

mv $tmp_file $spike_finder_dir$dataset_number.model.calcium.csv
# put some here to put all the modelled traces into the one file. Entitled $dataset.model.calcium.csv
