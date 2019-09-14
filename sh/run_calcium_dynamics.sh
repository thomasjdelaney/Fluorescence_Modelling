#!/bin/bash

## The point here is to save some useful command line set ups for the
## deterministic_dynamics.lj script
# /home/pgrads/td16954/linux/julia/julia jl/deterministic_dynamics.jl --outflux 1e-12 --excitation 0.5 --release 1e-2 --title "demo maxes outflux 1e-12 excitation 0.5 release 1e-2"

fluorescence_modelling_dir=$HOME/Fluorescence_Modelling
spike_finder_dir=$HOME/Spike_finder
train_dir=$spike_finder_dir/train
optimisation_dir=$SPACE/optimisation_csvs
dataset_number=8
spike_file=$train_dir/$dataset_number.train.spikes.csv
fluoro_file=$train_dir/$dataset_number.train.calcium.csv

for i in {0..20}
do
  opt_file_name=comp_opt_"$dataset_number"_"$i"_2e-2.csv
  echo `date +"%Y.%m.%d %T"` " Optimising trace number $i..."
  $SPACE/julia/bin/julia $fluorescence_modelling_dir/jl/fluorescence_training.jl --spike_file $spike_file --calcium_file $fluoro_file --frequency 100.0 --colname x$i --title $opt_file_name --opt_params calcium_rate,excitation,release,capture_rate
  echo `date +"%Y.%m.%d %T"` " Optimised..."
  opt_file=$optimisation_dir/$opt_file_name

  free_param_options=`$SPACE/julia/bin/julia jl/build_command_from_opt.jl --opt_file $opt_file`
  echo `date +"%Y.%m.%d %T"` " Running model with optimised parameters..."
  $SPACE/julia/bin/julia $fluorescence_modelling_dir/jl/fluorescence_modelling.jl --spike_file $spike_file --calcium_file $fluoro_file --frequency 100.0 --colname $i --title "dataset $dataset_number trace $i" --make_plot $free_param_options
  echo `date +"%Y.%m.%d %T"` " Completed trace number $i..."
done

# /home/pgrads/td16954/linux/julia/julia jl/deterministic_dynamics.jl --spike_file "/home/pgrads/td16954/linux/Spike_finder/train/8.train.spikes.csv" --calcium_file "/home/pgrads/td16954/linux/Spike_finder/train/8.train.calcium.csv" --frequency 100.0 --colname x$i --title "8.$i.model.calcium.csv" --from_file --save_fluoro
