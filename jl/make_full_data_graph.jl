# for displaying all of the spike finder data on the one page

using DataFrames
using PyPlot
using Seaborn

fluoro_file = homedir() * "/Spike_finder/train/8.train.calcium.csv"
spike_file = homedir() * "/Spike_finder/train/8.train.spikes.csv"
fluoro_frame = readtable(fluoro_file)
spike_frame = readtable(spike_file)

num_frames, num_traces = size(fluoro_frame)
time = range(0, num_frames)/100.0
PyPlot.figure(figsize=(11,17))
for i in 1:num_traces
  fluoro_trace = fluoro_frame[i]
  fluoro_trace[isna(fluoro_trace)] = 0.0
  spike_train = spike_frame[i]
  spike_train[isna(spike_train)] = 0.0
  PyPlot.subplot(num_traces, 1, i)
  PyPlot.plot(time, spike_train-1, label="spike train")
  PyPlot.plot(time, fluoro_trace, label="fluorescence")
  PyPlot.tick_params(labelsize="large")
  PyPlot.tick_params(axis="y", labelleft="off")
  if i < num_traces
    PyPlot.tick_params(axis="x", labelbottom="off")
  end
end
PyPlot.xlabel("Time (s)", fontsize="large")
save_name = homedir() * "/Latex/fluorescence_modelling/figures/all_spikefinder_data.png"
PyPlot.savefig(save_name)
  

