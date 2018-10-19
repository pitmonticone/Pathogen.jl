function generate(::Type{Transmission},
                  tr::TransmissionRates,
                  event::Event{T}) where T <: EpidemicModel
  id = event.individual
  if _new_transmission(event)
    external_or_internal = Weights([tr.external[id]; sum(tr.internal[:,id])])
    if sum(external_or_internal) == 0.0
      @error "All transmission rates = 0.0, No transmission can be generated"
      return NoTransmission()
      # return ExogenousTransmission(id)
    elseif sample([true; false], external_or_internal)
      @debug "Exogenous tranmission generated"
      return ExogenousTransmission(id)
    else
      source = sample(1:tr.individuals, Weights(tr.internal[:, id]))
      @debug "Endogenous transmission generated (source id = $source)"
      return EndogenousTransmission(id, source)
    end
  else
    @debug "No transmission generated"
    return NoTransmission()
  end
end
