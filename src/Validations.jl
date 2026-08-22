# functions for validating #
export ValidateParents, DataExists, ValidateDataset


"""
    ValidateParents(registry::DataRegistry, Parents::Vector{String})

Verfy that all `Parents` exist in the `registry`.
"""
function ValidateParents(registry::DataRegistry, Parents::Vector{String})

    parent_exists = haskey.(Ref(registry.Datasets), Parents)

    if !all(parent_exists)
        error("The following parent datasets do not exist in the Registry: " *
            "$(join(Parents[.!parent_exists], ", "))")
    end

    return nothing

end


"""
    ValidateParents(registry::DataRegistry, Parent::String)

Verfy that `Parent` exists in the `registry`.
"""
function ValidateParents(registry::DataRegistry, Parent::String)
    return ValidateParents(registry, [Parent])
end


"""
    DataExists(DataPath::AbstractString)

Check if the data pointed to by `DataPath` exists on disk.
"""
function DataExists(DataPath::AbstractString)
    return isfile(DataPath)
end

"""
    DataExists(DataPath::Vector{String})

Check if the data pointed to by `DataPath` exists on disk.
"""
function DataExists(DataPath::Vector{String})
    file_exists = isfile.(DataPath)

    if !all(file_exists)
        @warn "Not all files exist on disk. Missing files: " * "$(join(DataPath[.!file_exists], ", "))"
    end

    return all(file_exists)
end



"""
    ValidateDataset(registry::DataRegistry, ID::String)

Validate `Dataset` `ID` in `registry` by checking that
- the 'Parents' exist;
- the 'Dataset' has an author;
- the `LastModified` is after the `Registered` date;
- that the `DataPath` and `SourcePath` are valid;
- the data exists on disk 
"""
function ValidateDataset(registry::DataRegistry, ID::String; allow_no_data=false)

    errors = []

    # check that the parents exist #
    try
        ValidateParents(registry, registry.Datasets[ID].Parents)
    catch e
        push!(errors, (; error = e))
    end

    # check that the dataset has an author #
    if isempty(registry.Datasets[ID].Authors)
        try
            error("Dataset '$(ID)' does not have an author.")
        catch e
            push!(errors, (; error = e))
        end
    end

    # check that the LastModified is after the Registered date #
    if !(registry.Datasets[ID].LastModified >= registry.Datasets[ID].Registered)
        try
            error("The 'LastModified' date for dataset '$ID' is before the 'Registered' date.")
        catch e
            push!(errors, (; error = e))
        end
    end


    # Check that the DataPath and SourcePath are valid #
    if !isdir(dirname(registry.Datasets[ID].SourcePath))
        try
            error("The `SourcePath` for dataset '$ID' is not a valid directory.")
        catch e
            push!(errors, (; error = e))
        end
    end

    datapath = registry.Datasets[ID].DataPath
    if datapath isa AbstractString
        if !isdir(dirname(datapath))
            try
                error("The `DataPath` for dataset '$ID' is not a valid directory.")
            catch e
                push!(errors, (; error = e))
            end
        end
    elseif datapath isa Vector{String}
        if !all(isdir.(unique(dirname.(datapath)))) 
            try
                error("The `DataPath` for dataset '$ID' is not a valid directory.")
            catch e
                push!(errors, (; error = e))
            end
        end
    end


    # check that the data exists on disk #
    if !DataExists(registry.Datasets[ID].DataPath)
        if allow_no_data
            @warn "The data for dataset '$ID' does not exist on disk."
        else
            try
                error("The data for dataset '$ID' does not exist on disk.")
            catch e
                push!(errors, (; error = e))
            end
        end
    end


    # Print summary of errors #
    if isempty(errors)
        println("Dataset '$ID' passed all validation checks.")
    else
        println("Dataset '$ID' failed $(length(errors)) of 6 validation checks.")
        println("=== ERROR DETAILS ===")
        for item in errors
            println("Error: $(item.error)")
        end

        error("Dataset '$ID' failed some validation checks. See above for details.")
    end

    return nothing
end


function ValidateRegistry()

    # check that the project has an author #

    # check for duplicate dataset IDs #

    # check for circular dependencies in the parent-child relationships #

    # Validate each dataset in the registry #
    dataset_errors = []
    for (id, _) in registry.Datasets
        try
            ValidateDataset(registry, id)
        catch e
            push!(dataset_errors, (; error = e))
        end
    end

    return nothing
end