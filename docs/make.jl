using Documenter, DWDataReader

makedocs(;
    modules = [DWDataReader],
    format = Documenter.HTML(prettyurls = false),
    pages = [
        "Home" => "index.md",
    ],
    repo = "https://github.com/fleimgruber/DWDataReader.jl/blob/{commit}{path}#{line}",
    sitename = "DWDataReader.jl",
    authors = "Fabian Leimgruber",
)

deploydocs(; repo = "github.com/fleimgruber/DWDataReader.jl", devbranch = "main")
