module DWDataReader

    include("file.jl")

    function read(source, kwargs...)
        DWDataReader.File(source; kwargs...)
    end

end
