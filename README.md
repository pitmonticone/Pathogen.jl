# Pathogen.jl
[![Build Status](https://travis-ci.org/jangevaare/Pathogen.jl.svg?branch=master)](https://travis-ci.org/jangevaare/Pathogen.jl)

## Introduction

Pathogen.jl is a package that provides utilities for the simulation and inference of pathogen phylodynamics, built in the [Julia language](http://julialang.org). Specifically, Pathogen.jl presents an extension to the individual level infectious disease transmission models (ILMs) of Deardon et al. (2010), to simultaneously model infectious disease transmission and evolution. Pathogen genomic sequences are used in conjunction with the covariate and disease state information of individuals to infer disease transmission pathways, external disease pressure, and infectivity parameters.

Pathogen.jl utilizes the packages [PhyloTrees.jl](https://github.com/jangevaare/PhyloTrees.jl) and [PhyloModels.jl](https://github.com/jangevaare/PhyloModels.jl) for pathogen sequence simulation and calculation of phylogenetic tree likelihoods.


![Phylodynamic simulation](epianimation.gif?raw=true)


## Package installation


    Pkg.update()
    Pkg.clone("https://github.com/jangevaare/Pathogen.jl")



## Package usage

1. Create a population data frame containing covariate information for each individual in a population. If there is a spatial component to your model, this data frame should contain the location of each individual. Each row in this data frame is assumed to represent a single unique individual.

         using DataFrames
         population = DataFrame(x = x_coordinates,
                                y = y_coordinates,
                                riskfactor1 = riskfactor1,
                                riskfactor2 = riskfactor2)

2. Create the following risk functions. These risk functions are the components of event (disease state transition) rates.


        function sparks_func(parameters::Vector{Float64}, population::DataFrame, i::Int64)
          # function of risk factors associated with transmission of an infection from an
          # external disease source to a susceptible individual i
        end

        function susceptibility_func(parameters::Vector{Float64}, population::DataFrame, i::Int64)
          # function of risk factors associated with the susceptibility of a susceptible
          # individual i
        end

        function transmissibility_func(parameters::Vector{Float64}, population::DataFrame, k::Int64)
          # function of risk factors associated with transmission of an infection from an
          # infectious individual k
        end

        function infectivity_func(parameters::Vector{Float64}, population::DataFrame, i::Int64, k::Int64)
          # function of risk factors involving both a susceptible individual i and an
          # infectious individual k
        end

        function latency_func(parameters::Vector{Float64}, population::DataFrame, j::Int64)
          # function of risk factors associated with the latency of an infection in an
          # exposed individual j
        end

        function removal_func(parameters::Vector{Float64}, population::DataFrame, k::Int64)
          # function of risk factors associated with the removal of an infectious
          # individual k
        end


3. Collect these risk functions in the `RiskFunctions` type, and parameterizations in the `RiskParameters` type

        using Pathogen
        risk_funcs = RiskFunctions(sparks_func,
                                   susceptibility_func,
                                   transmissibility_func,
                                   infectivity_func,
                                   removal_func)

        risk_params = RiskParameters(sparks_params,
                                     susceptibility_params,
                                     transmissibility_params,
                                     infectivity_params,
                                     removal_params)
### Simulation
### Inference
