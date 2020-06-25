# module for holding function common to both pdmp dynamics and deterministic dynamics

push!(LOAD_PATH, homedir() * "/Julia_Utils/jl")

module FluorescenceModelling

using ArgParse
using CSV
using DataFrames
using JuliaUtils: getPowerSpectrum, sphereVolume, smoothen
using PyPlot
using StatsBase

export getSupTitle,
  parseParams,
  plotDynamics,
  plotComparison,
  plotPowerSpectrum,
  saveModelFluorescence

include("getSupTitle.jl")
include("parseParams.jl")
include("plotDynamics.jl")
include("plotPowerSpectrum.jl")
include("plotComparison.jl")
include("saveModelFluorescence.jl")

end
