"""
calcium baseline, ca influx, ca outflux, indicator backward, indicator forward, total indicator,
endogeneous backward, endogeneous forward, total endogeneous buffer,
immobile backward, immobile forward, total immobile,
excitation rate, release rate, calcium peaks, spike times
noise variance, figure title, capture rate, capture variance,
from_file, frequency, debug, excited buffered calcium
"""
function parseParams()
  s = ArgParseSettings()
  @add_arg_table s begin
    "--cell_radius"
      help = "Modelling the cell as a sphere, the radius of that sphere"
      arg_type = Float64
      default = 10e-6
    "--baseline"
      help = "The baseline amount of calcium present in the cell. (M)"
      arg_type = Float64
      default = 0.045e-6
    "--calcium_rate"
      help = "The rate of the calcium influx at rest."
      arg_type = Float64
      default = 0.0001
    "--b_i"
      help = "The rate of BCa unbinding for indicator. (s^-1)"
      arg_type = Float64
      default = 160.0
    "--f_i"
      help = "The rate of calcium and indicator binding. (M^-1 s^-1)"
      arg_type = Float64
      default = 7.766990291262137e8
    "--indicator"
      help = "The total amount of indicator present. (M)"
      arg_type = Float64
      default = 100e-6
    "--b_e"
      help = "The rate of ECa undinding for endogeneous buffer. (s^-1)"
      arg_type = Float64
      default = 10000.0
    "--f_e"
      help = "The rate of calcium and endogeneous buffer binding. (M^-1 s^-1)"
      arg_type = Float64
      default = 100e6
    "--endogeneous"
      help = "The total amount of endogeneous buffer present. (M)"
      arg_type = Float64
      default = 100e-6
    "--b_im"
      help = "The rate of ICa undinding for immobile buffer. (s^-1)"
      arg_type = Float64
      default = 524.0
    "--f_im"
      help = "The rate of calcium and immobile buffer binding. (M^-1 s^-1)"
      arg_type = Float64
      default = 2.47e8
    "--immobile"
      help = "The total amount of immobile buffer present. (M)"
      arg_type = Float64
      default = 78.7e-6
    "--excitation"
      help = "The excitation rate of the BCa."
      arg_type = Float64
      default = 0.15
    "--release"
      help = "The photon release rate of the excited BCa, BCa*."
      arg_type = Float64
      default = 0.11
    "--peak"
      help = "The peak amount of calcium in the cell after a spike. (M)"
      arg_type = Float64
      default = 2.9e-7
    "--title"
      help = "The title of the figure produced."
      arg_type = String
      default = ""
    "--capture_rate"
      help = "The expected proportion of photons captured at any given moment."
      arg_type = Float64
      default = 0.62
    "--frequency"
      help = "The sampling frequency in Hz if spike times are from file."
      arg_type = Float64
      default = 100.0
    "--spike_file"
      help = "The file from which to load the spike train."
      arg_type = String
      default = homedir() * "/Spike_finder/train/8.train.spikes.csv"
    "--calcium_file"
      help = "The file from which to load the calcium trace."
      arg_type = String
      default = homedir() * "/Spike_finder/train/8.train.calcium.csv"
    "--colname"
      help = "The name of the column in which the spike train can be found."
      arg_type = Symbol
      default = Symbol("0")
    "--make_plot"
      help = "Flag to indicate that the plot comparison plot should be created and saved."
      action = :store_true
    "--save_fluoro"
      help = "Flag to indicate that the fluorescence should be saved."
      action = :store_true
    ## optimisation parameters begin here ##
    "--opt_params"
      help = "comma separated list of the parameters to optimise."
      arg_type = String
      default = "" #"calcium_rate,excitation,release,capture_rate"
    "--debug"
      help = "Enter debug mode."
      action = :store_true
  end
  p = parse_args(s)
  p["cell_volume"] = sphereVolume(p["cell_radius"])
  p["frequency"] <= 0.0 && error("frequency must be greater than 0.")
  p["spike_file"] == "" && error("a spike train file name must be provided.")
  p["colname"] == Symbol("") && error("a column name must be provided.")
  if p["make_plot"]
    p["title"] == ""&& error("If the 'make_plot' flag is included, a title must also be included.")
  end
  if p["opt_params"] != ""
    p["opt_params"] = [Symbol(c) for c in split(p["opt_params"], ",")]
  end
  return p
end
