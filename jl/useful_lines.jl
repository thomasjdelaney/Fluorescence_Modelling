using PyPlot, Seaborn, DataFrames 

train_dir = homedir() * "/Spike_finder/train/";

calc_file = train_dir * "8.train.calcium.csv";  
spike_file = train_dir * "8.train.spikes.csv";
mod_file = train_dir * "8.model.calcium.csv";
pan_train_file = train_dir * "8.paninski.train.spikes.csv";
pan_model_file = train_dir * "8.paninski.model.spikes.csv";
of_train_file = train_dir * "8.oasis.first.train.spikes.csv";
of_model_file = train_dir * "8.oasis.first.model.spikes.csv";
os_train_file = train_dir * "8.oasis.second.train.spikes.csv";
os_model_file = train_dir * "8.oasis.second.model.spikes.csv";
lz_train_file = train_dir * "8.lzero.train.spikes.csv";
lz_model_file = train_dir * "8.lzero.model.spikes.csv";

calc_frame = readtable(calc_file);
spike_frame = readtable(spike_file);
mod_frame = readtable(mod_file);
pan_train_frame = readtable(pan_train_file);
pan_model_frame = readtable(pan_model_file);
of_train_frame = readtable(of_train_file);
of_model_frame = readtable(of_model_file);
os_train_frame = readtable(os_train_file);
os_model_frame = readtable(os_model_file);
lz_train_frame = readtable(lz_train_file);
lz_model_frame = readtable(lz_model_file);

colname = :x18
calc_train = calc_frame[colname];
spike_train = spike_frame[colname];
mod_train = mod_frame[colname];
pan_train_train = pan_train_frame[colname];
pan_model_train = pan_model_frame[colname];
of_train_train = of_train_frame[colname];
of_model_train = of_model_frame[colname];
os_train_train = os_train_frame[colname];
os_model_train = os_model_frame[colname];
lz_train_train = lz_train_frame[colname];
lz_model_train = lz_model_frame[colname];


trial_time = (0:size(calc_frame, 1)-1)/100       
PyPlot.subplot(2,1,1);
PyPlot.plot(trial_time, calc_train, label="Observed fluorescence");
PyPlot.plot(trial_time, spike_train-1, label="Observed spike train");
PyPlot.plot(trial_time, pan_train_train-2, label="Paninski spike train");
PyPlot.plot(trial_time, of_train_train-3, label="OASIS first spike train");
PyPlot.plot(trial_time, os_train_train-4, label="OASIS second spike train");
PyPlot.plot(trial_time, lz_train_train-5, label="Lzero spike train");
PyPlot.xlabel("Time (s)");
PyPlot.legend();

PyPlot.subplot(2,1,2);
PyPlot.plot(trial_time, mod_train, label="Modelled fluorescence");
PyPlot.plot(trial_time, spike_train-1, label="Observed spike train");
PyPlot.plot(trial_time, pan_model_train-2, label="Paninski Model spike train");
PyPlot.plot(trial_time, of_model_train-3, label="OASIS first Model spike train"); 
PyPlot.plot(trial_time, os_model_train-4, label="OASIS second Model spike train");
PyPlot.plot(trial_time, lz_model_train-5, label="Lzero Model spike train");
PyPlot.xlabel("Time (s)");
PyPlot.legend();

