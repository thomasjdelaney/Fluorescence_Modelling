# Plots the continuous and discrete variables across time
# Args:     result, Nx5 array, the values of the model
#           time, the time points of each record of values
#           ftime, the times at which the fluorescence was sampled
#           title, the title of the figure
#           cell_volume, the volume of the cell
# returns:  the name of the file where the figure is saved.

function plotDynamics(result, time, title, cell_volume)
  @info(" plotting results...")
  fig = PyPlot.figure(figsize=(24,12))
  PyPlot.plot(time, result[:,1], color="red", label="[Ca2+]")
  PyPlot.plot(time, result[:,2], color="blue", label="[BCa]")
  PyPlot.plot(time, result[:,3], color="black", label="[ECa]")
  PyPlot.plot(time, result[:,4], color="green", label="[ImCa]")
  PyPlot.plot(time, result[:,5], color="orange", label="[BCa*]")
  PyPlot.legend(fontsize="large")
  PyPlot.xlabel("Time (s)", fontsize="large")
  PyPlot.ylabel("Molar Concentration (M)", fontsize="large")
  PyPlot.xticks(fontsize="large"); PyPlot.yticks(fontsize="large");
  PyPlot.ticklabel_format(style="sci")
  filename = string(pwd(), "/images/concentration_dynamics/", replace(title, " "=>"_"), ".png")
  title != "" && PyPlot.savefig(filename)
  return filename
end
