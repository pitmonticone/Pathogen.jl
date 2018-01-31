# Set the event extents for generation of the initial event times
initial_event_extents = SEI_EventExtents(21., 1.)

# Set prior distributions
riskparameter_priors = SEI_RiskParameterPriors([Uniform(0., 0.001)],
                                               UnivariateDistribution[],
                                               UnivariateDistribution[],
                                               [Uniform(0., 2.), Uniform(4., 8.)],
                                               [Uniform(0., 0.25)])

substitutionmodel_priors = JC69Prior([Uniform(0., 2e-5)])

# Initialize MCMC
phylodynamicILM_trace = initialize_mcmc(observations,
                                        initial_event_extents,
                                        observed_sequences,
                                        riskparameter_priors,
                                        risk_funcs,
                                        substitutionmodel_priors,
                                        population)

# Transition kernel
transition_kernel = [0.0000025; 0.005; 0.01; 0.000625; 2.5e-8]

# Set the event extents for data augmentation
event_extents = SEI_EventExtents(Inf, 2.)

# Run MCMC
mcmc!(phylodynamicILM_trace,
      100,
      2,
      transition_kernel,
      1.0,
      event_extents,
      observations,
      observed_sequences,
      riskparameter_priors,
      risk_funcs,
      substitutionmodel_priors,
      population)

# Initialize MCMC
ILM_trace = initialize_mcmc(observations,
                            initial_event_extents,
                            riskparameter_priors,
                            risk_funcs,
                            population)

# Transition kernel
transition_kernel = transition_kernel[1:end-1]

# Run MCMC
mcmc!(ILM_trace,
      100,
      2,
      transition_kernel,
      1.0,
      event_extents,
      observations,
      riskparameter_priors,
      risk_funcs,
      population)
