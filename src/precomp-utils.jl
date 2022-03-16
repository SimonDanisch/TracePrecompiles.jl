using Base: UUID, PkgId, require

macro import_pkg(name, uuid)
    qname = QuoteNode(name)
    return esc(quote
        if !isdefined(@__MODULE__, $(qname))
            const $(name) = require(PkgId($uuid, $(string(name))))
        end
    end)
end

macro precompile(args)
    ccall(:jl_generating_output, Cint, ()) == 1 || return
    warn_str = "Could not precompile: $(string(args))"
    return quote
        try
            precompile($(args))
        catch e
            @debug $(warn_str) exception=e
        end
    end
end
