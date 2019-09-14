"""
save the fluorescence down into a nice csv file
Arguments:  title, the name of the file to be saved
            fluorescence, the model fluorescence
            spike_file, the file with the actual spikes in it.
            colname, the column/trial we're using here
Returns:    file_name
"""
function saveModelFluorescence(title::String, fluorescence::Array{Float64, 1}, spike_file::String, colname::Symbol; has_header::Bool=true)
  spike_train = CSV.read(spike_file, header=has_header)[!,colname]
  fluoro_frame = DataFrame([spike_train, fluorescence], [:spike_train, :fluorescence])
  file_name = splitdir(spike_file)[1] * "/" * title 
  CSV.write(file_name, fluoro_frame)
  return file_name
end
