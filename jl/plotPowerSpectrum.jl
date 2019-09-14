# Just plot the power spectrum of the fluorescence trace
# Arguments:  frequencies,
#             log_power
# Returns:    nothing
function plotPowerSpectrum(log_power, frequencies)
  PyPlot.plot(frequencies, log_power, color="blue")
  PyPlot.xlabel("Frequency (Hz)")
  PyPlot.ylabel("Power (dB)")
  return nothing
end
