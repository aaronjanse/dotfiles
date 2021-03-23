# from Julia standard library


function open_fake_pty()
    O_RDWR = Base.Filesystem.JL_O_RDWR
    O_NOCTTY = Base.Filesystem.JL_O_NOCTTY

    fdm = ccall(:posix_openpt, Cint, (Cint,), O_RDWR | O_NOCTTY)
    rc = ccall(:grantpt, Cint, (Cint,), fdm)
    rc = ccall(:unlockpt, Cint, (Cint,), fdm)

    fds = ccall(:open, Cint, (Ptr{UInt8}, Cint),
        ccall(:ptsname, Ptr{UInt8}, (Cint,), fdm), O_RDWR | O_NOCTTY)

    pts = RawFD(fds)
    ptm = Base.TTY(RawFD(fdm))
    return pts, ptm
end
function with_fake_pty(f)
    pts, ptm = open_fake_pty()
    try
        f(pts, ptm)
    finally
        close(ptm)
    end
    nothing
end

CTRL_C = '\x03'
UP_ARROW = "\e[A"
DOWN_ARROW = "\e[B"
repl_script = """
1+1
ls | wc -l
$UP_ARROW$DOWN_ARROW$CTRL_C
ls \t\t$CTRL_C
"""

pts, ptm = open_fake_pty()
blackhole = "/dev/null"
if true
    cmdargs = ```--color=yes
                -e 'import REPL; REPL.Terminals.is_precompiling[] = true'
                ```
else
    cmdargs = `-e nothing`
end

p = run(```julia -O0 --trace-compile=trace.jl
            --cpu-target=native --startup-file=yes --color=yes
            -e 'import REPL; REPL.Terminals.is_precompiling[] = true'
            -i```,
            pts, pts, pts; wait=false)
debug_output = devnull # or stdout
Base.close_stdio(pts)
# Prepare a background process to copy output from process until `pts` is closed
output_copy = Base.BufferStream()
tee = @async try
    while !eof(ptm)
        l = readavailable(ptm)
        write(debug_output, l)
        write(output_copy, l)
    end
catch ex
    if !(ex isa Base.IOError && ex.code == Base.UV_EIO)
        rethrow() # ignore EIO on ptm after pts dies
    end
finally
    close(output_copy)
    close(ptm)
end
# wait for the definitive prompt before start writing to the TTY
readuntil(output_copy, ">")
sleep(0.1)
readavailable(output_copy)
# Input our script
if true
    precompile_lines = split(repl_script::String, '\n'; keepempty=false)
    local curr
    for l in precompile_lines
        sleep(0.5)
        bytesavailable(output_copy) > 0 && readavailable(output_copy)
        write(ptm, l, "\n")
        readuntil(output_copy, "\n")
        readuntil(output_copy, "\n")
        readuntil(output_copy, "> ")
    end
    println()
end
write(ptm, "exit()\n")
wait(tee)
success(p) || Base.pipeline_error(p)
close(ptm)
