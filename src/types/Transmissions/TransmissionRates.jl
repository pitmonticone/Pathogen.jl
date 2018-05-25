mutable struct TransmissionRates
  external::Array{Float64, 1}
  internal::Array{Float64, 2}

  function TransmissionRates(individuals::Int64)
    return new(fill(0., individuals),
               fill(0., (individuals, individuals)))
  end

  function TransmissionRates(e::Array{Float64, 1},
                             i::Array{Float64, 2})
    @boundscheck !(length(e) == size(i, 1) == size(i, 2)) && error("Argument dimensions mismatched")
    return new(e, i)
  end
end

function copy(x::TransmissionRates)
  return TransmissionRates(copy(x.external),
                           copy(x.internal))
end
