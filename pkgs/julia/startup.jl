using REPLComboShell

atreplinit() do repl
    REPLComboShell.setup_repl(repl)
end

using InteractiveUtils

ENV["EDITOR"] = "kak"
InteractiveUtils.define_editor("kak", wait = true) do cmd, path, line
    `$cmd +$line $path`
end

