# for making a graph showing the trajectory of the rms over optimisation iterations

using DataFrames
using PyPlot
using Seaborn

opt_dir = homedir() * "/Calcium_Deconvolution/csv/optimisation/"
file_list = readdir(opt_dir)
num_files = length(file_list)
all_opts = DataFrame()
for filename in file_list
  file = opt_dir * filename
  opt_frame = readtable(file)
  opt_frame[:iteration] = range(1,size(opt_frame)[1])
  all_opts = [all_opts; opt_frame]
end

iterations = sort(unique(all_opts[:iteration]))
means = zeros(Float64, length(iterations))
stds = zeros(Float64, length(iterations))
for i in iterations
  means[i], stds[i] = mean_and_std(all_opts[all_opts[:iteration] .== i, :rms])
end

upper_stds = means + stds
lower_stds = lower_stds = means - stds
lower_stds[lower_stds .<= 0] = 0.0
iterations = iterations - 1

PyPlot.plot(iterations, means, label="mean root mean squared difference")
PyPlot.plot(iterations, upper_stds, linestyle="--", color="green", label="+/- standard deviation")
PyPlot.plot(iterations, lower_stds, linestyle="--", color="green")
PyPlot.fill_between(iterations, lower_stds, upper_stds, alpha=0.5)
PyPlot.xlabel("Number of iterations", fontsize="large")
PyPlot.ylabel("Root mean squared difference", fontsize="large")
PyPlot.legend(fontsize="large")
PyPlot.tick_params(labelsize="large")
PyPlot.title("Mean and standard deviation of root mean squared values over iterations", fontsize="large")

  
