__precompile__()

module Pathogen

  # Dependencies
  using DataFrames
  using Distributions
  using RecipesBase
  using ProgressMeter

  # Types
  include("types/EpidemicModel.jl")
  include("types/DiseaseState.jl")
  include("types/Events/Event.jl")
  include("types/Events/EventExtents.jl")
  include("types/Events/EventObservations.jl")
  include("types/Events/EventRates.jl")
  include("types/Events/Events.jl")
  include("types/Risks/RiskFunctions.jl")
  include("types/Risks/RiskParameters.jl")
  include("types/Risks/RiskPriors.jl")
  include("types/Transmissions/Transmission.jl")
  include("types/Transmissions/TransmissionNetwork.jl")
  include("types/Transmissions/TransmissionRate.jl")
  include("types/Simulation.jl")

  # Functions
  include("functions/initialize.jl")
  include("functions/generate.jl")
  include("functions/observe.jl")
  include("functions/update!.jl")

  export
    SEIR, SEI, SIR, SI,
    DiseaseState, DiseaseStates,
    # EventExtents,
    # EventObservations,
    RiskFunctions, RiskParameters, #RiskPriors,
    Simulation

end
