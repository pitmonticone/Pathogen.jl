module Pathogen

using Distributions, Distances, DataFrames, BioSeq, ProgressMeter

export
  # types.jl
  Population,
  RateArray,
  SEIR_actual,
  SEIR_observed,
  SEIR_augmented,
  Trace,
  Priors,
  SEIR_priors,
  SEIR_trace,
  PhyloSEIR_priors,
  PhyloSEIR_trace,

  # utilities.jl
  findstate,
  plotdata,
  convert,
  maximum,

  # mutate.jl
  jc69,

  # simulate.jl
  create_seq,
  create_population,
  create_powerlaw,
  create_constantrate,
  create_ratearray,
  onestep!,

  # infer.jl
  surveil,
  SEIR_augmentation,
  SEIR_loglikelihood,
  SEIR_logprior,
  SEIR_initialize,
  SEIR_MCMC,
  seq_distances,
  seq_loglikelihood,
  network_loglikelihood

include("types.jl")
include("utilities.jl")
include("mutate.jl")
include("simulate.jl")
include("infer.jl")

end
