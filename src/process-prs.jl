_package = ARGS[1]
trace_out = ARGS[2]
outfile = ARGS[3]

_package = Symbol(_package)

package = @eval (import $(_package); $(_package))
modules = Set(keys(Base.loaded_modules))

package.include("precomp-utils.jl")

open(outfile, "w") do io
    write(io, read(joinpath(@__DIR__, "precomp-utils.jl")))
    println(io)
    for p in collect(modules)
        import_str = "@import_pkg $(p.name) $(repr(p.uuid))"
        psym = Symbol(p.name)
        if !isdefined(package, psym)
            package.eval(:(const $(psym) = Base.require($(p))))
            println(io, import_str)
        else
            println("$psym already defined in package")
        end
    end
    println(io)
    for line in readlines(trace_out)
        isempty(line) && continue
        try
            include_string(package, line)
            println(io, "@" * line)
        catch e
            @warn "Could not precompile $(line)" exception=e
        end
    end
end
