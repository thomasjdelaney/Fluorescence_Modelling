"""
For executing the with parameters provided, and calculating the rms of the difference
between the smoothed log power spectra of the model, and the data.

Arguments:  configurable_parameters, Array{Float64}, array of the values of the configurable parameters.
Returns:    Float64, the rms
"""
function getDataModelRMS(configurable_parameters)
  for i = 1:length(configurable_parameters)
    parameter_to_configure = string(params["opt_params"][i])
    params[parameter_to_configure] = configurable_parameters[i]
  end
  spike_times = getSpikeTimes(params["spike_file"], params["colname"], params["frequency"])
  baseline_sim, baseline_time = baselineDynamics(params, spike_times)
  spiking_sim, spiking_sim_time = spikingDynamics(baseline_sim, baseline_time, spike_times, params)
  lower_freq_sampling_indices = range(1, 100, floor(Int, size(spiking_sim)[1]/100))
  fluorescence = [getPhotonsCollected(ebc, params["release"], params["capture_rate"]) for ebc in spiking_sim[lower_freq_sampling_indices,end]]
  zscore_fluorescence = zscore(fluorescence)
  model_freq_array, model_power = getPowerSpectrum(zscore_fluorescence, params["frequency"])
  smooth_model_power = smoothen(model_power, win_length=31, win_method=1)
  log_model_power = 10*log10(smooth_model_power[model_freq_array.<30.0]) # drop off occurs at 30Hz
  fl_trace = CSV.read(params["calcium_file"])[params["colname"]]
  zscore_fl = zscore(fl_trace)
  fluoro_freq_array, fluoro_power = getPowerSpectrum(zscore_fl, params["frequency"])
  smooth_fluoro_power = smoothen(fluoro_power, win_length=31, win_method=1)
  log_fluoro_power = 10*log10(smooth_fluoro_power[fluoro_freq_array.<30.0]) # drop off occurs at 30Hz
  return rms(log_model_power - log_fluoro_power)
end
