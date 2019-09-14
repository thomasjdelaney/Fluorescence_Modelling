# for making a correlation plot of the optimal parameters 

using PyPlot, Seaborn, DataFrames, ArgParse, Combinatorics, Logging, Glob

Logging.configure(level=INFO)

function parseParams()
  s = ArgParseSettings()
  @add_arg_table s begin
    "--opt_dir"
      help = "The absolute path to the directory contaning the optimsation files"
      arg_type = String
      default = "/space/td16954/optimisation_csvs/"
    "--file_pattern"
      help = "The pattern for finding which optimisation files we want."
      arg_type = String
      default = "comp*"
    "--opt_params"
      help = "The parameters that were optimised, and are to be analysed."
      arg_type = String
      default = "calcium_rate,excitation,release,capture_rate"
    "--image_dir"
      help = "The directory in which to save the figure"
      arg_type = String
      default = "/home/pgrads/td16954/linux/Fluorescence_Modelling/images/optimsed_parameter_cross_correlation/"
    "--debug"
      help = "Enter debug mode."
      action = :store_true
  end
  p = parse_args(s)
  p["opt_params"] = split(p["opt_params"], ",")
  p["opt_params"] = convert(Array{Symbol, 1}, p["opt_params"])
  return p
end

function scatterIndexPair(index_pair::Array{Int64,1}, grid_size::Int64, 
                          opt_params::Array{Symbol, 1}, opt_frame::DataFrames.DataFrame)
  plot_number = ((index_pair[2]-2)*grid_size) + index_pair[1]
  PyPlot.subplot(grid_size, grid_size, plot_number)
  param_pair = opt_params[index_pair]
  PyPlot.scatter(opt_frame[param_pair[1]], opt_frame[param_pair[2]], c=opt_frame[:rms], cmap="plasma")
  PyPlot.xlim(xmin=0); PyPlot.ylim(ymin=0);
  PyPlot.xticks(fontsize="large"), PyPlot.yticks(fontsize="large")
  mod(plot_number, grid_size) == 1 && PyPlot.ylabel(param_pair[2], fontsize="large")
  div(plot_number, grid_size) >= grid_size - 1 && PyPlot.xlabel(param_pair[1], fontsize="large")
  PyPlot.colorbar()
  return nothing
end

function loadOptFile(opt_file::String)
  opt_frame = readtable(opt_file)
  trace_number = split(opt_file, "_")[5]
  return opt_frame, trace_number
end

function processOptfile(opt_file::String, opt_params::Array{Symbol, 1}, 
                        opt_frame::DataFrames.DataFrame, param_index_pairs::Array{Array{Int64,1},1},
                        trace_number::AbstractString, grid_size::Int64, image_dir::String)
  PyPlot.figure(figsize=(16,9))
  PyPlot.title("trace number $trace_number")
  for index_pair in param_index_pairs
    scatterIndexPair(index_pair, grid_size, opt_params, opt_frame)
  end
  save_name = image_dir * "opcc_$trace_number.png"
  PyPlot.savefig(save_name)
  return save_name
end

function main()
  params = parseParams()
  if params["debug"]; info(" Entering debug mode."); return nothing; end
  opt_files = glob(params["file_pattern"], params["opt_dir"])
  num_params = length(params["opt_params"])
  grid_size = num_params - 1
  param_index_pairs = collect(combinations(1:num_params, 2))
  for opt_file in opt_files
    opt_frame, trace_number = loadOptFile(opt_file)
    save_name = processOptfile(opt_file, params["opt_params"], opt_frame, param_index_pairs, trace_number, grid_size, params["image_dir"])
    info(" Image saved: $save_name")
  end
end

main()
