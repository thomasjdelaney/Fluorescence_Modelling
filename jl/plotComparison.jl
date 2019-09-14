# Compare the spikefinder data to the modelled fluorescence trace,
# and their power spectra after zscoring
# Arguments:  title, the title of the figure, and the file name.
#             spike_train, String, the csv file in which the spike train is to be found
#             calcium_file, String, the csv file in which the calcium trace is to be found
#             sampling_freq, the samplong frequency
#             colname, Symbol, name of the column in which the spike train is to be found
#             fluorescence, the fluorescence trace,
#             time, the time for the fluorescence trace
# Returns:    the name of the file where the figure is saved.

function plotComparison(title::String, spike_train::Array{Int64,1}, calcium_file::String, sampling_freq::Float64, colname::Symbol, fluorescence::Array{Float64,1}, time::Array{Float64,1})
  fl_trace = CSV.read(calcium_file)[!,colname]
  zscore_fl = zscore(fl_trace)
  zscore_model = zscore(fluorescence)
  fluoro_freq_array, fluoro_power = getPowerSpectrum(zscore_fl, sampling_freq)
  model_freq_array, model_power = getPowerSpectrum(zscore_model, sampling_freq)
  smooth_fluoro_power = smoothen(fluoro_power, win_length=21, win_method=1)
  smooth_fluoro_power = [max(0.0, sfp) for sfp in smooth_fluoro_power]
  smooth_fluoro_power = smooth_fluoro_power[fluoro_freq_array.<30.0] # drop off at 30Hz
  fluoro_freq_array = fluoro_freq_array[fluoro_freq_array .< 30.0]
  smooth_model_power = smoothen(model_power, win_length=21, win_method=1)
  smooth_model_power = [max(0.0, smp) for smp in smooth_model_power]
  smooth_model_power = smooth_model_power[model_freq_array.<30.0] # drop off at 30Hz
  model_freq_array = model_freq_array[model_freq_array .< 30.0]
  fig = PyPlot.figure(figsize=(16,16))
  PyPlot.title(title, fontsize="large")
  PyPlot.subplot(3,1,1)
  PyPlot.plot(time, spike_train/2 .- 1, label="Spikes")
  PyPlot.plot(time, fl_trace, label="Fluorescence")
  PyPlot.legend(fontsize="large")
  PyPlot.xlabel("Time (s)", fontsize="large"); PyPlot.ylabel(L"$\Delta F/F_0$", fontsize="large");
  PyPlot.xticks(fontsize="large"); PyPlot.yticks(fontsize="large");
  PyPlot.subplot(3,1,2)
  PyPlot.plot(time, spike_train/2 .- 1, label="Spikes")
  PyPlot.plot(time, fluorescence, color="orange", label="Modelled Fluorescence")
  PyPlot.legend(fontsize="large")
  PyPlot.xlabel("Time (s)", fontsize="large")
  PyPlot.ylabel(L"$\Delta F/F_0$", fontsize="large")
  PyPlot.xticks(fontsize="large"); PyPlot.yticks(fontsize="large");
  PyPlot.subplot(3,1,3)
  PyPlot.plot(fluoro_freq_array, 10*log10.(smooth_fluoro_power), color="green", label="Observed Fluorescence")
  PyPlot.plot(model_freq_array, 10*log10.(smooth_model_power), color="orange", label="Modelled Fluorescence")
  PyPlot.xlabel("Frequency (Hz)", fontsize="large")
  PyPlot.ylabel("Power (dB)", fontsize="large")
  PyPlot.xticks(fontsize="large"); PyPlot.yticks(fontsize="large");
  PyPlot.legend(fontsize="large")
  filename = string(pwd(), "/images/fluorescence_trace_comparisons/", replace(title, " "=>"_"), ".png")
  title != "" && PyPlot.savefig(filename)
  return filename
end
