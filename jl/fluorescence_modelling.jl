##################################################################################
##
## For modelling the dynamics of calcium fluorescence as a set of ODEs
##
## julia -i jl/deterministic_dynamics.jl
##
##################################################################################

push!(LOAD_PATH, homedir() * "/Fluorescence_Model/jl")
push!(LOAD_PATH, homedir() * "/Fluorescence_Modelling/jl")
using FluorescenceModelling
using FluorescenceModel
using Logging
using CSV

function main()
  @info(" Starting modelling function...")
  params = parseParams()
  if params["debug"]; @info(" Entering debug mode."); return nothing; end
  spike_train = convert(Array{Int64,1}, CSV.read(params["spike_file"])[!,params["colname"]])
  @info(" starting modelling the fluorescence...")
  fluorescence, spiking_sim, spiking_sim_time = calciumFluorescenceModel(spike_train, 
    cell_radius=params["cell_radius"], baseline=params["baseline"], calcium_rate=params["calcium_rate"], 
    indicator=params["indicator"], endogeneous=params["endogeneous"], immobile=params["immobile"], 
    b_i=params["b_i"], f_i=params["f_i"], b_e=params["b_e"], f_e=params["f_e"], b_im=params["b_im"], 
    f_im=params["f_im"], excitation=params["excitation"], release=params["release"], peak=params["peak"], 
    frequency=params["frequency"], capture_rate=params["capture_rate"])
  if params["make_plot"]
    fig_file_name = plotComparison(params["title"], spike_train, params["calcium_file"], params["frequency"], params["colname"], fluorescence, spiking_sim_time)
    @info(" Figure saved: $fig_file_name")
    fig_file_name = plotDynamics(spiking_sim, spiking_sim_time, params["title"], params["cell_volume"])
    @info(" Figure saved: $fig_file_name")
  end
  if params["save_fluoro"]
    file_name = saveModelFluorescence(params["title"], fluorescence, params["spike_file"], params["colname"])
    @info(" Fluorescence saved: $file_name")
  end
  @info(" Done.")
end

main()
