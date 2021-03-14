using Plots, UnicodePlots, Primes, Latexify, Symbolics, REPL, Pkg, Unitful

plot(x->x^2)
lineplot(x->x^2)

println(isprime(17))

@variables x
