using Plots, UnicodePlots, Primes, Latexify, Symbolics, REPL

plot(x->x^2)
lineplot(x->x^2)

using Unitful

println(isprime(17))

@variables x
