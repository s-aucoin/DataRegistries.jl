using Documenter
using DataRegistries

makedocs(
    sitename = "DataRegistries",
    format = Documenter.HTML(),
    modules = [DataRegistries],
    remotes = nothing
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/s-aucoin/DataRegistries.jl.git",
    versions = nothing
)
