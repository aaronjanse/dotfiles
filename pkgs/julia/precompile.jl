using Plots, UnicodePlots, Primes, Latexify, Symbolics, REPL, Pkg, Unitful
using Distributions

scatter(rand(1:10, (10, 2)))

plot(x->x^2)
lineplot(x->x^2)

println(isprime(17))

using HypothesisTests

confint(BinomialTest(10, 15))

using SymbolicUtils

@variables x

D = Differential(x)
simplify(expand_derivatives(D(x*3+sqrt(7x))))

@syms x::Real y::Real z::Complex
simplify(sin(x)^2 + cos(x)^2)
