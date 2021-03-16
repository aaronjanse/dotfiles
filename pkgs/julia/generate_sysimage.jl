using Pkg

Pkg.activate(".")

using PackageCompiler
using Plots, UnicodePlots, Primes, Latexify, Symbolics, Unitful, REPL
using Distributions, ReplMaker, StringParserPEG

create_sysimage( [:Plots, :UnicodePlots, :Primes, :Latexify,
    :Symbolics, :Unitful, :REPL, :Pkg, :Distributions, :ReplMaker,
    :StringParserPEG]
    , sysimage_path=ARGS[2]
    , precompile_execution_file=ARGS[1]
)
