using DataRegistries
using Test
using Dates

@testset "DataRegistries" begin
    include("test_structures.jl")
    include("test_base_overloads.jl")
    include("test_conversions.jl")
    include("test_registrymanagement.jl")
end