using Pkg

Pkg.activate(".")

using PackageCompiler

import Pluto, REPL, PEG, Plots, UnicodePlots, REPLComboShell
import InteractiveUtils

create_sysimage([
        :Pluto, :REPL, :PEG, :Plots, :UnicodePlots, :REPLComboShell,
        :InteractiveUtils
    ], sysimage_path=ARGS[2], precompile_statements_file=ARGS[1],
)
