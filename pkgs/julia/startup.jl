using REPLComboShell

atreplinit() do repl
    REPLComboShell.setup_repl(repl, "ajanse")

    delete!(ENV, "JULIA_BINDIR")
    delete!(ENV, "JULIA_LOAD_PATH")
    delete!(ENV, "JULIA_DEPOT_PATH")
end

using InteractiveUtils
ENV["EDITOR"] = "kak"
InteractiveUtils.define_editor("kak", wait = true) do cmd, path, line
    `$cmd +$line $path`
end

