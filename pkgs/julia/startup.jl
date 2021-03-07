import REPL
import REPL.LineEdit
import Base

function launch_shell()
    run(`stty sane`);
    print("\r");
    run(ignorestatus(`zsh`));
    run(`stty sane`);
    print("\e[2A");
end

foobar_keymap = Dict{Any,Any}(
    '>' => function (s,args...)
        if isempty(s)
            launch_shell()
            return :done
        else
            LineEdit.edit_insert(s,'>')
        end
    end
)

function customize_keys(repl)
    repl.interface = REPL.setup_interface(repl; extra_repl_keymap = foobar_keymap)

    @eval using Plots, UnicodePlots, Symbolics, Latexify, Unitful
    @eval @variables x
    @eval Base.getindex(f::Function, x...) = (y...) -> f(x..., y...)
    @eval cross(r, n) = reshape(collect(Base.product(repeat([r], n)...)), 1, :)

    # launch_shell()
    # print('\n')
end

atreplinit(customize_keys)
