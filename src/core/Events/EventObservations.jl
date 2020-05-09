struct EventObservations{S <: DiseaseStateSequence, M <: ILM}
  infection::Vector{Float64}
  removal::Union{Nothing, Vector{Float64}}
  seq::Union{Nothing, Vector{Union{Nothing, GeneticSeq}}}

  function EventObservations{S, M}(i::V,
                                   r::V) where {
                                   V <: Vector{Float64},
                                   S <: Union{SEIR, SIR},
                                   M <: TNILM}
    if length(i) != length(r)
      throw(ErrorException("Length of infection and removal times must be equal"))
    end
    return new{S, M}(i, r, nothing)
  end

  function EventObservations{S, M}(i::V) where {
                                   V <: Vector{Float64},
                                   S <: Union{SEI, SI},
                                   M <: TNILM}
    return new{S, M}(i, nothing, nothing)
  end


  function EventObservations{S, M}(i::V,
                                   r::V,
                                   seq::VG) where {
                                   V <: Vector{Float64},
                                   G <: GeneticSeq,
                                   VG <: Vector{Union{Nothing, G}},
                                   S <: Union{SEIR, SIR},
                                   M <: PhyloILM}
    if length(unique([length(i); length(r); length(seq)])) != 1
      throw(ErrorException("Length of infection times, removal times, and genetic sequence vectors must be equal"))
    end
    return new{S, M}(i, r, seq)
  end

  function EventObservations{S, M}(i::V,
                                   s::VG) where {
                                   V <: Vector{Float64},
                                   G <: GeneticSeq,
                                   VG <: Vector{Union{Nothing, G}},
                                   S <: Union{SEI, SI},
                                   M <: PhyloILM}
    if length(i) != length(s)
      throw(ErrorException("Length of infection time and genetic sequence vectors must be equal"))
    end
    return new{S, M}(i, nothing, s)
  end
end

function EventObservations{S, M}(i::Array{Float64, 2}) where {
                                 S <: Union{SEI, SI},
                                 M <: TNILM}
  if size(i, 2) != 1
    throw(ErrorException("Invalid Array dimensions for observations of a $S model"))
  end
  return EventObservations{S, M}(i[:,1])
end

function EventObservations{S, M}(ir::Array{Float64, 2}) where {
                                 S <: Union{SEIR, SIR},
                                 M <: TNILM}
  if size(ir, 2) != 2
    throw(ErrorException("Invalid Array dimensions for observations of a $S model"))
  end
  return EventObservations{S, M}(ir[:, 1], ir[:, 2])
end

function EventObservations{S, M}(i::Array{Float64, 2},
                                 s::VG) where {
                                 G <: GeneticSeq,
                                 VG <: Vector{Union{Nothing, G}},
                                 S <: Union{SEI, SI},
                                 M <: PhyloILM}
  if size(i, 2) != 1
    throw(ErrorException("Invalid Array dimensions for observations of a $S model"))
  end
  return EventObservations{S, M}(i[:,1], s)
end

function EventObservations{S, M}(ir::Array{Float64, 2},
                                 s::VG) where {
                                 G <: GeneticSeq,
                                 VG <: Vector{Union{Nothing, G}},
                                 S <: Union{SEIR, SIR},
                                 M <: PhyloILM}
  if size(ir, 2) != 2
    throw(ErrorException("Invalid Array dimensions for observations of a $S model"))
  end
  return EventObservations{S, M}(ir[:, 1], ir[:, 2], s)
end

function individuals(x::EventObservations{S, M}) where {
                     S <: DiseaseStateSequence,
                     M <: ILM}
  return length(x.infection)
end

function Base.show(io::IO,
                   x::EventObservations{S, M}) where {
                   S <: DiseaseStateSequence,
                   M <: ILM}
  return print(io, "$S $M observations (n=$(individuals(x)))")
end

function Base.getindex(x::EventObservations{S, M},
                       new_state::DiseaseState) where {
                       S <: DiseaseStateSequence,
                       M <: ILM}
  if new_state == State_I
    return x.infection
  elseif (new_state == State_R) && (State_R ∈ T)
    return x.removal
  else
    error("Unrecognized indexing disease state")
  end
end

function Base.getindex(x::EventObservations{S, M},
                       states::DiseaseStates) where {
                       S <: DiseaseStateSequence,
                       M <: ILM}
  y = x[states[1]]
  for i = 2:length(states)
    y = hcat(y, x[states[i]])
  end
  return y
end

function Base.convert(::Type{Array{Float64, 2}}, x::EventObservations{S, M}) where {
                      S <: DiseaseStateSequence,
                      M <: ILM}
  states = State_R ∉ T ? [State_I] : [State_I, State_R]
  return x[states]
end

function Base.convert(::Type{Vector{Float64}}, x::EventObservations{S, M}) where {
                      S <: DiseaseStateSequence,
                      M <: ILM}
  states = State_R ∉ T ? [State_I] : [State_I, State_R]
  return x[states][:]
end

function Base.minimum(x::EventObservations{S, M}) where {
                      S <: DiseaseStateSequence,
                      M <: ILM}
  y = convert(Array{Float64, 2}, x)
  return minimum(y[.!isnan.(y)])
end

function Base.maximum(x::EventObservations{S, M}) where {
                      S <: DiseaseStateSequence,
                      M <: ILM}
  y = convert(Array{Float64, 2}, x)
  return maximum(y[.!isnan.(y)])
end