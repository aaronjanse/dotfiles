using Pkg

Pkg.activate(".")

using PackageCompiler
using Plots, UnicodePlots, Primes, Latexify, Symbolics, Unitful, REPL

create_sysimage( [:Plots, :UnicodePlots, :Primes, :Latexify, :Symbolics, :Unitful, :REPL, :Pkg]
    , sysimage_path=ARGS[2]
    , precompile_execution_file=ARGS[1]
)
