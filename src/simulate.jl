"""
An array which stores information for simulation purposes
"""
type Rates
  rates::Array{Array{Float64}, 1}
  mask::Array{Array{Bool}, 1}

  function Rates(individuals::Int64)
    rates = Array{Float64}[]
    mask = Array{Bool}[]

    # External exposure rates
    push!(rates, fill(0., individuals))
    push!(mask, fill(false, individuals))

    # Internal exposure rates
    push!(rates, fill(0., (individuals, individuals)))
    push!(mask, fill(false, (individuals, individuals)))

    # Infection rates
    push!(rates, fill(0., individuals))
    push!(mask, fill(false, individuals))

    # Removal rates
    push!(rates, fill(0., individuals))
    push!(mask, fill(false, individuals))

    return new(rates, mask)
  end
end


"""
Create an initialize rate array
"""
function initialize_rates(population::DataFrame,
                          risk_funcs::RiskFunctions,
                          risk_params::RiskParameters)
  individuals = size(population, 2)
  rates = Rates(individuals)
  for i = 1:individuals
    # External exposure
    rates.rates[1][i] = risk_funcs.sparks(risk_params.sparks, population, i)

    # Internal exposure
    for k = 1:individuals
      if i !== k
        rates.rates[2][k, i] = risk_funcs.susceptibility([risk_params.susceptibility], population, i) *
                               risk_funcs.transmissibility([risk_params.transmissibility], population, k) *
                               risk_funcs.infectivity([risk_params.infectivity], population, i, k)
      end
    end
  end

  # Infection onset
  for j = 1:individuals
    rates.rates[3][j] = risk_funcs.latency(risk_params.latency, population, j)
  end

  # Removal
  for k = 1:individuals
    rates.rates[4][k] = risk_funcs.removal(risk_params.removal, population, k)
  end

  # Mask
  rates.mask[1][:] = true

  return rates
end


import Base.getindex


function getindex(x::Rates, i, j)
  return x.mask[i][j] * x.rates[i][j]
end


function getindex(x::Rates, i)
  return x.mask[i] .* x.rates[i]
end


"""
A function to generate an event time and event type from a rate array
"""
function generate_event(rates::Rates,
                        time=0.::Float64)
  totals = [sum(rates[1]);
            sum(rates[2]);
            sum(rates[3]);
            sum(rates[4])]
  total = sum(totals)
  if total < Inf

    # Generate event time
    time += rand(Exponential(1/total))

    # Generate event type and index
    event_type = findfirst(rand(Multinomial(1, totals/total)))
    event_index = findfirst(rand(Multinomial(1, rates[event_type][:]/totals[event_type])))
  else
    event_type = findfirst(totals .== Inf)
    event_index = findfirst(rates[event_type][:] .== Inf)
  end
  return time, (event_type, event_index)
end


"""
A function to update a rate array base on an event which has occurred
"""
function update_rates!(rates::Rates,
                       event::Tuple{Int64, Int64},
                       population::DataFrame,
                       risk_funcs::RiskFunctions,
                       risk_params::RiskParameters)
  # External exposure
  if event[1] == 1
    individual = event[2]
    rates.mask[1][individual] = false
    rates[1][:, individual] = false
    rates.mask[3][event[2]] = true

  # Internal exposure
  elseif event[1] == 2
    individual = ind2sub(size(rates[2]), event[2])
    rates.mask[1][individual] = false
    rates.mask[2][:, individual] = false
    rates.mask[3][event[2]] = true

  # Onset of infection
  elseif event[1] == 3
    individual = event[2]
    rates.mask[3][individual] = false
    rates.mask[4][individual] = true
    rates.mask[2][individual, :] = rates.mask[1]

  # Removal
  elseif event[1] == 4
    individual = event[2]
    rates[4][individual] = false
    rates.mask[2][individual, :] = false
  end

  return rates
end