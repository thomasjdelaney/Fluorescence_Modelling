## for building a command to run deterministic_dynamics.jl using the optimal free parameters
## as returned by the optimisation process

using ArgParse
using CSV
using DataFrames

function parseParams()
  s = ArgParseSettings()
  @add_arg_table s begin
    "--opt_file"
      help = "the name and path to the optimisation csv."
      arg_type = String
      default = "/space/td16954/optimisation_csvs/new_opt_8_0_tc_0.1.csv"
    "--opt_params"
      help = "The parameters affected by optimisation"
      arg_type = String
      default = "calcium_rate,excitation,release,capture_rate"
    "--debug"
      help = "Enter debug mode."
      action = :store_true
  end
  p = parse_args(s)
  p["opt_params"] = split(p["opt_params"], ",")
  return p
end

function main()
  params = parseParams()
  if params["debug"]; info(" Entering debug mode."); return nothing; end
  opt_frame = CSV.read(params["opt_file"])
  opt_row = opt_frame[opt_frame[:rms] .== minimum(opt_frame[:rms]),:]
  param_string = ""
  for p in params["opt_params"]
    param_string = param_string * " --" * p * " " * string(opt_row[Symbol(p)][1])
  end
  print(param_string)
end

main()
