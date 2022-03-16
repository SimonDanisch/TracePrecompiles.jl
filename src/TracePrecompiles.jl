module TracePrecompiles

function run_julia(cmd)
    current_proj = unsafe_string(Base.JLOptions().project)
    run(`$(Base.julia_cmd()) --project=$(current_proj) --startup-file=no $(cmd)`)
end

function trace_compiles(package, trace_file, outputfile)
    tdir = mktempdir(; cleanup=true)
    trace_out = joinpath(tdir, "precompiles.jl")
    run_julia(`--trace-compile=$(trace_out) $trace_file`)
    prs = joinpath(@__DIR__, "process-prs.jl")
    run_julia(` $prs $(package) $(trace_out) $(outputfile)`)
end

end
