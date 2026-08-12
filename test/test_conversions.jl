@testset "to_toml" begin
    # Test with one object of each possible type #
    possible_types = [AbstractDict,
                        AbstractVector,
                        AbstractString,
                        Integer,
                        AbstractFloat,
                        Bool,
                        Dates.DateTime,
                        Dates.Time,
                        Dates.Date, 
                        AuthorInfo, 
                        ProjectInfo, 
                        Dataset, 
                        DataRegistry]

    @test DataRegistries.to_toml("test") == "test"
    @test DataRegistries.to_toml(123) == 123
    @test DataRegistries.to_toml(123.456) == 123.456
    @test DataRegistries.to_toml(true) == true
    @test DataRegistries.to_toml(false) == false

    testdatetime = now()
    testtoday = today()
    testtime = Time(now())
    @test DataRegistries.to_toml(testdatetime) == testdatetime
    @test DataRegistries.to_toml(testtoday) == testtoday
    @test DataRegistries.to_toml(testtime) == testtime

    test_array = ["test", 1, 2.3]
    @test DataRegistries.to_toml(test_array) == test_array

    @testset "Dict" begin
        @test DataRegistries.to_toml(Dict{AbstractString, Float64}("key" => 1.0)) == Dict{DataRegistries.TOMLTypes, DataRegistries.TOMLTypes}("key" => 1.0)
        @test DataRegistries.to_toml(Dict{AbstractString, AbstractArray}("key" => test_array)) == Dict{DataRegistries.TOMLTypes, DataRegistries.TOMLTypes}("key" => test_array)
    end

    author = AuthorInfo(Name="Test Author", Email="test@example.com", Affiliation="Test Institution", Github="test", ORCID="0000-0000")
    @test DataRegistries.to_toml(author) == Dict{DataRegistries.TOMLTypes, DataRegistries.TOMLTypes}("Name"=>"Test Author", "Email"=>"test@example.com", "Affiliation"=>"Test Institution", "Github"=>"test", "ORCID"=>"0000-0000")

    # ProjectInfo #
    # Dataset #
        # nested with another type that is converted
    # DataRegistry #
end

#=
@testset "from_toml" begin
    

end
=#