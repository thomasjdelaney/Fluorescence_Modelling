##################################################################################
##
## For training the model of calcium indicator fluorescence
##
## julia -i jl/deterministic_dynamics.jl
##
##################################################################################

push!(LOAD_PATH, homedir() * "/Fluorescence_Modelling/jl")
push!(LOAD_PATH, homedir() * "/Fluorescence_Model/jl")
push!(LOAD_PATH, homedir() * "/Julia_Utils/jl")
using CSV
using FluorescenceModelling
using FluorescenceModel
using DataFrames
using JuliaUtils: rms, getPowerSpectrum, smoothen
using BlackBoxOptim
using StatsBase
using Dates

function getDataModelRMS(configurable_parameters)
  for i = 1:length(configurable_parameters)
    parameter_to_configure = string(params["opt_params"][i])
    params[parameter_to_configure] = configurable_parameters[i]
  end
  spike_train = convert(Array{Int64,1}, CSV.read(params["spike_file"])[!, params["colname"]])
  fluorescence, spiking_sim, spiking_sim_time = calciumFluorescenceModel(spike_train, calcium_rate=params["calcium_rate"], indicator=params["indicator"], endogeneous=params["endogeneous"], immobile=params["immobile"], b_i=params["b_i"], f_i=params["f_i"], b_e=params["b_e"], f_e=params["f_e"], b_im=params["b_im"], f_im=params["f_im"], excitation=params["excitation"], release=params["release"], peak=params["peak"], frequency=params["frequency"], capture_rate=params["capture_rate"])
  fl_trace = CSV.read(params["calcium_file"])[!, params["colname"]]
  zscore_fluorescence = zscore(fluorescence)
  zscore_fl = zscore(fl_trace)
  model_freq_array, model_power = getPowerSpectrum(zscore_fluorescence, params["frequency"])
  fluoro_freq_array, fluoro_power = getPowerSpectrum(zscore_fl, params["frequency"])
  smooth_model_power = smoothen(model_power, win_length=31, win_method=1)
  smooth_fluoro_power = smoothen(fluoro_power, win_length=31, win_method=1)
  log_model_power = 10*log10.(smooth_model_power[model_freq_array.<30.0]) # drop off occurs at 30Hz
  log_fluoro_power = 10*log10.(smooth_fluoro_power[fluoro_freq_array.<30.0]) # drop off occurs at 30Hz
  return rms(log_model_power - log_fluoro_power) + rms(zscore_fluorescence - zscore_fl) 
end

function main_opt()
  @info(string(now(), " INFO: ",  " Starting training function..."))
  global params = parseParams()
  if params["debug"]; @info(string(now(), " INFO: ", " Entering debug mode.")); return nothing; end
  opt_methods = [:adaptive_de_rand_1_bin_radiuslimited, :xnes, :de_rand_1_bin_radiuslimited, :adaptive_de_rand_1_bin, :generating_set_search, :probabilistic_descent, :de_rand_1_bin, :random_search]
  num_params = length(params["opt_params"])
  num_methods = length(opt_methods)
  args = zeros(Float64, (num_methods, num_params))
  vals = zeros(Float64, num_methods)
  times = zeros(Float64, num_methods)
  for i = 1:num_methods
    opt_method = opt_methods[i]
    @info(string(now(), " INFO: ", "using $opt_method..."))
    start_time = time()
    try 
      res = bboptimize(getDataModelRMS; SearchRange = [(0.0, 1000.0), (0.0, 30.0), (0.0, 30.0), (0.000001, 0.999)], NumDimensions = 4, Method = opt_method, MaxTime = 300.0, TraceMode = :verbose)
      args[i,:] = best_candidate(res)
      vals[i] = best_fitness(res)
    catch
      args[i,:] = zeros(num_params)
      vals[i] = NaN
    end
    time_taken = time() - start_time
    times[i] = time_taken
  end
  opt_frame = DataFrame()
  for i = 1:length(params["opt_params"])
    opt_frame[params["opt_params"][i]] = args[:,i]
  end
  opt_frame[:rms] = vals
  opt_frame[:time] = times
  opt_frame[:method] = opt_methods
  filename = ENV["SPACE"] * "/optimisation_csvs/" * replace(params["title"], " "=>"_")
  writetable(filename, opt_frame, header=true)
  @info(string(now(), " INFO: ", " optimisation results written to $filename..."))
  @info(string(now(), " INFO: ", " Done."))
end

main_opt()
