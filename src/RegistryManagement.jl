"""
    InitializeRegistry(; Title::String = DrWatson.projectname(),
                         ID::String,
                         Authors::Dict{String, AuthorInfo} = authorlist,
                         Description::String = "")

Create an empty DatasetRegistry object.
"""
function InitializeRegistry(; Title::String = DrWatson.projectname(),
                                ID::String,
                                Authors::Dict{String, AuthorInfo} = authorlist,
                                Description::String = "")

    info = ProjectMetadata(
        Title,
        Authors,
        now(),
        Description,
        ID)

    return DatasetRegistry(
        info,
        Dict{String, Dataset}())
end

"""
    AddDataset!(registry, dataset)

Add a Dataset to a DatasetRegistry.

Checks:
- Dataset ID does not already exist
- All parent dataset IDs exist in the registry

Updates:
- Adds dataset to `registry.Datasets`
- Sets the registration timestamp
"""
function AddDataset!(registry::DatasetRegistry, dataset::Dataset)

    # Check that ID is unique
    if haskey(registry.Datasets, dataset.ID)
        error("Dataset with ID '$(dataset.ID)' already exists in registry.")
    end

    # Check that parent datasets exist
    missing_parents = [p for p in dataset.Parents if !haskey(registry.Datasets, p)]

    if !isempty(missing_parents)
        error("Cannot add dataset '$(dataset.ID)'. " *
            "The following parent datasets do not exist: " *
            "$(join(missing_parents, ", "))")
    end

    # Add dataset
    dataset.Registered = now()
    registry.Datasets[dataset.ID] = dataset

    println("Dataset '$(dataset.ID)' added to registry.")
end


"""
    UpdateDataset!(registry, ID; kwargs...)

Update fields of an existing Dataset in a DatasetRegistry.

Only fields provided as keyword arguments are modified.
The dataset's LastModified timestamp is updated automatically.

Example:
    UpdateDataset!(
        registry,
        "temperature_L1";
        Parents=["temperature_raw"],
        Description="Updated description"
    )
"""
function UpdateDataset!(registry::DatasetRegistry, ID::String; kwargs...)

    # Check that dataset exists
    if !haskey(registry.Datasets, ID)
        error("Dataset with ID '$ID' does not exist in registry.")
    end

    dataset = registry.Datasets[ID]

    # Check that all fields exist
    valid_fields = Set(fieldnames(Dataset))

    for key in keys(kwargs)
        if !(key in valid_fields)
            error("Dataset has no field '$key'. " * "Valid fields are: $(join(valid_fields, ", "))")
        end
    end

    # Update fields
    for (key, value) in kwargs

        # Do not allow changing the ID
        if key == :ID
            error("Dataset ID cannot be modified. Use RemoveDataset! and AddDataset! instead.")
        end

        # Do not allow changing the registration time
        if key == :Registered
            error("Dataset registration time cannot be modified. Use RemoveDataset! and AddDataset! instead.")
        end

        setfield!(dataset, key, value)
    end


    # Validate parents if changed
    if :Parents in keys(kwargs)

        missing_parents = [p for p in dataset.Parents if !haskey(registry.Datasets, p)]

        if !isempty(missing_parents)
            error("Cannot update dataset '$ID'. " * "The following parent datasets do not exist: " * "$(join(missing_parents, ", "))")
        end
    end


    # Update modification timestamp
    dataset.LastModified = now()

println("Dataset '$(dataset.ID)' updated in the registry.")
end



"""
    UpdateOrCreateDataset!(registry, ID; kwargs...)

Update an existing Dataset in a DatasetRegistry, or create a new Dataset if
it does not exist.

If the dataset already exists, only the supplied fields are modified.
If it does not exist, a new Dataset is created using the supplied fields
and default values for unspecified fields.
"""
function UpdateOrCreateDataset!(registry::DatasetRegistry, ID::String; kwargs...)

    if haskey(registry.Datasets, ID)
        println("Dataset '$(ID)' already exists, updating...")
        UpdateDataset!(registry, ID; kwargs...)
    else
        println("Dataset '$(ID)' does not exist, creating it instead.")
        dataset = Dataset(ID; kwargs...)
        AddDataset!(registry, dataset)
    end
end