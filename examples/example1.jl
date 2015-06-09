using Pathogen, Gadfly

init_seq = generate_sequence(200, 0.25, 0.25, 0.25, 0.25)
init_var = rand((2,50))

pop = create_population(init_seq, init_var)

powerlaw = create_powerlaw(1., 1., 1., 1.)
latency = create_constantrate(1/3.)
recovery = create_constantrate(1/5.)
substitution = jc69((0.1,))

ratearray = create_ratearray(pop, powerlaw, substitution)
ratearray.rates
ratearray.events

@time while pop.timeline[1][end] < 10.
  onestep!(ratearray, pop, powerlaw, latency, recovery, substitution)
end

states, routes = plotdata(pop, 2.)
plot(states, x="x", y="y", color="state", Geom.point)
plot(routes, x="x", y="y", color="age", Geom.line)
