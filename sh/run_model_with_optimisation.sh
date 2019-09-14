#!/bin/bash

# For running the model, using the precalculated optimised parameters.

fluorescence_modelling_dir=$HOME/Fluorescence_Modelling
spike_finder_dir=$HOME/Spike_finder
train_dir=$spike_finder_dir/train
optimisation_dir=$SPACE/optimisation_csvs
dataset_number=8
spike_file=$train_dir/$dataset_number.train.spikes.csv
fluoro_file=$train_dir/$dataset_number.train.calcium.csv
traces=`head -1 $fluoro_file | sed "s/,/ /g"`

for t in $traces
do
  echo `date +"%Y.%m.%d %T"` " Processing trace number $t..."
  opt_file=$optimisation_dir/comp_opt_"$dataset_number"_"$t"_2e-2.csv
  free_param_options=`$SPACE/julia/bin/julia $fluorescence_modelling_dir/jl/build_command_from_opt.jl --opt_file $opt_file`

  echo `date +"%Y.%m.%d %T"` " Running model with optimised parameters..."
  $SPACE/julia/bin/julia $fluorescence_modelling_dir/jl/fluorescence_modelling.jl --spike_file $spike_file --calcium_file $fluoro_file --frequency 100.0 --colname $t --title "dataset $dataset_number trace $t" --make_plot $free_param_options
  echo `date +"%Y.%m.%d %T"` " Completed trace number $t..."
done

echo `date +"%Y.%m.%d %T"` " Done."

