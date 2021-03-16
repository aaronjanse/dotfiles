using StringParserPEG, ReplMaker
import REPL.LineEdit

shell_grammer = Grammar(raw"""
    start => +((argument & space) {(r,v,f,l,c)->c[1]}) {"start"} 

    argument => +(double_quote | single_quote | word | interpolation) {"argument"}

    interpolation => ('@' & '(' & julia & ')') {"interpol"}
    julia => *(julia_non_parens | julia_parens)
    julia_non_parens => r([^()]+)r
    julia_parens => ('(' & julia & ')')

    double_quote => ('"' & *(word | r(')r | ' ') & '"')
    single_quote => (r(')r & *(word | '"' | ' ') & r(')r)
    word => +(char | escaped_symbol) {"text"}
    escaped_symbol => '\' & r(.)r
    char => r([^ "'\\\@]+)r
    space => r([ \t\n\r]*)r
""")


toresult(node,children,::MatchRule{:default}) = node.value
toresult(node,children,::MatchRule{:pass}) = children[1]
toresult(node,children,::MatchRule{:start}) = join(vcat(children...), " ")
function toresult(node,children,::MatchRule{:interpol})
    out = eval(Meta.parse(children[3]))
    if isa(out, String)
        Base.shell_escape(out)
    else
        out
    end
end
function toresult(node,children,::MatchRule{:argument})
    if all(map(x->isa(x, String), children))
        join(children, "")
    else
        args = Any[""]
        for child in children
            if isa(child, String) || isa(child, Char)
                if isa(args[end], String)
                    args[end] *= "$child"
                else
                    append!(args, ["$child"])
                end
            else
                append!(args, [map(x->Base.shell_escape("$x"), child)])
            end
        end
        args = map(x->if isa(x, String) Any[x] else x end, args)
        combos = Iterators.product(args...)
        combos = map(x->join(x, ""), combos)
        reshape(combos, (:,))
    end
end

function parse_to_expr(s)
    args = split(s, ' ')
    if !isnothing(Sys.which(args[1]))
        ast = parse(shell_grammer, s)[1]
        cmd = transform(toresult,ast)
        run(Base.cmd_gen(("fish", "-c", cmd)));
        print()
    elseif args[1] == "cd"
        cd(args[2])
    else
        Meta.parse(s)
    end
end

@eval using Plots, UnicodePlots, Symbolics, Latexify, Unitful, SymbolicUtils
@eval histogram = Plots.histogram
@eval linehistogram = UnicodePlots.histogram
@eval SymbolicUtils.show_simplified[] = true
@eval @syms x::Real y::Real z::Complex
@eval Base.getindex(f::Function, x...) = (y...) -> f(x..., y...)
@eval cross(r, n) = reshape(collect(Base.product(repeat([r], n)...)), 1, :)
@eval macro sh_cmd(s_str)
    s_expr = Meta.parse(string('"', escape_string(s_str), '"'))
    return split(String(read(Base.cmd_gen(("sh", "-c", s_expr)))), '\n')
end

atreplinit() do repl
    if !isdefined(repl, :interface)
        repl.interface = REPL.setup_interface(repl)
    end

    
    function get_prompt()
        path = replace(pwd(), homedir() => "~")
        "$path> "
    end

    function parse_to_expr(s)
        args = split(s, ' ')
        if !isnothing(Sys.which(args[1]))
            ast = parse(shell_grammer, s)[1]
            cmd = transform(toresult,ast)
            cmd = Base.cmd_gen(("fish", "-c", cmd))
            run(ignorestatus(cmd));
            print()
        elseif args[1] == "cd"
            cd(expanduser(args[2]));
            julsh.prompt = get_prompt();
            nothing
        else
            Meta.parse(s)
        end
    end

    julsh = initrepl(
        parse_to_expr, start_key='>', mode_name="Expr_mode",
        prompt_text=get_prompt(), prompt_color=:magenta,
        startup_text = false)

    main_mode = Base.active_repl.interface.modes[1]
    help_mode = Base.active_repl.interface.modes[3]
    pkg_mode = Base.active_repl.interface.modes[end]

    help_mode.on_done = function (s, buf, ok::Bool)
        if !ok
            return LineEdit.transition(s, :abort)
        end
        repl = Base.active_repl
        line = String(take!(buf)::Vector{UInt8})
        f = line->REPL.helpmode(REPL.outstream(repl), line)
        ast = Base.invokelatest(f, line)
        response = REPL.eval_with_backend(ast, REPL.backend(repl))
        REPL.print_response(repl, response, true, REPL.hascolor(repl))
        println()
        return LineEdit.transition(s, julsh)
    end

    julsh.keymap_dict = LineEdit.keymap_merge(main_mode.keymap_dict, Dict{Any, Any}(
        '\b' => function (s, args...)
            LineEdit.edit_backspace(s)
        end,
        ']' => function (s, args...)
            # println("aa", isempty(s), position(LineEdit.buffer(s)))
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                buf = copy(LineEdit.buffer(s))
                LineEdit.transition(s, pkg_mode) do
                    LineEdit.state(s, pkg_mode).input_buffer = buf
                end
            else
                LineEdit.edit_insert(s, ']')
            end
        end,
        '?' => function (s, args...)
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                buf = copy(LineEdit.buffer(s))
                LineEdit.transition(s, help_mode) do
                    LineEdit.state(s, help_mode).input_buffer = buf
                end
            else
                LineEdit.edit_insert(s, '?')
            end
        end,
        "\x03" => function (s, args...)
            print(LineEdit.terminal(s), "^C\n\n")
            LineEdit.transition(s, julsh)
            LineEdit.transition(s, :reset)
            LineEdit.refresh_line(s)
        end,
    ))

    help_mode.keymap_dict = LineEdit.keymap_merge(help_mode.keymap_dict, Dict{Any, Any}(
        '\b' => function (s, args...)
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                buf = copy(LineEdit.buffer(s))
                LineEdit.transition(s, julsh) do
                    LineEdit.state(s, julsh).input_buffer = buf
                end
            else
                LineEdit.edit_backspace(s)
            end
        end,
        "\x03" => function (s, args...)
            print(LineEdit.terminal(s), "^C\n\n")
            LineEdit.transition(s, julsh)
            LineEdit.transition(s, :reset)
            LineEdit.refresh_line(s)
        end,
    ))

    pkg_mode.keymap_dict = LineEdit.keymap_merge(pkg_mode.keymap_dict, Dict{Any, Any}(
        '\b' => function (s, args...)
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                buf = copy(LineEdit.buffer(s))
                LineEdit.transition(s, julsh) do
                    LineEdit.state(s, julsh).input_buffer = buf
                end
            else
                LineEdit.edit_backspace(s)
            end
        end,
        "\x03" => function (s, args...)
            print(LineEdit.terminal(s), "^C\n\n")
            LineEdit.transition(s, julsh)
            LineEdit.transition(s, :reset)
            LineEdit.refresh_line(s)
        end,
    ))
    
    repl.interface.modes[1] = julsh
end
