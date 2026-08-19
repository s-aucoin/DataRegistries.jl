using DataRegistries
using Test
using Dates

@testset "DataRegistries" begin
    include("test_structures.jl")
    include("test_base_overloads.jl")
    include("test_conversions.jl")
    include("test_validations.jl")
    include("test_registrymanagement.jl")
    include("test_IO.jl")
    include("test_registryqueries.jl")
end