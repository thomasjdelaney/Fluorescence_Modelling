function getSupTitle(spike_file, colname)
  dataset = splitdir(spike_file)[2][:1]
  return "Dataset = " * string(dataset) * ", Trace = " * string(colname)
end
