@testset "ValidateParents" begin

    test_id = "test_dataset"
    dataset = Dataset(ID=test_id)

    registry = InitializeRegistry(ID="test_registry")
    registry.Datasets[test_id] = dataset

    # check that it passes if the Parent exists #
    parents = [test_id]
    @test isnothing(ValidateParents(registry, parents))

    # Check the error for parents not existing #
    parents = ["does_not_exist"]
    @test_throws ErrorException ValidateParents(registry, parents) 

end


@testset "DataExists" begin

    mktempdir() do tmpdir
        # Single-file dataset
        single_file = joinpath(tmpdir, "single.nc")
        touch(single_file)

        @test DataExists(single_file)

        # Multi-file dataset
        multi_dir = joinpath(tmpdir, "multi")
        mkpath(multi_dir)
        multi_pth = joinpath.(Ref(multi_dir), ["file1.nc", "file2.nc"])
        touch.(multi_pth)

        @test DataExists(multi_pth)

        # test warning if files don't exist #
        multi_path_2 = joinpath.(Ref(multi_dir), ["file1.nc", "file2.nc", "file3.nc", "file4.nc"])
        file_exists = isfile.(multi_path_2)
        @test_warn "Not all files exist on disk. Missing files: " * "$(join(multi_path_2[.!file_exists], ", "))" DataExists(multi_path_2)
    end

end