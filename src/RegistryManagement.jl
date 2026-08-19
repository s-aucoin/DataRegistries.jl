import REPL
using REPL.TerminalMenus

export InitializeRegistry, AddDataset!, UpdateDataset!, UpdateOrAddDataset!, RemoveDataset!


"""
    InitializeRegistry(; Title::String = DrWatson.projectname(),
                         ID::String,
                         Authors::Dict{String, AuthorInfo} = authorlist,
                         Description::String = "")

Initialize a DataRegistry object with project metadata, but no datasets.
"""
function InitializeRegistry(; ID::T,
                              Title::T = "Example Project",
                              Authors::Dict{T, AuthorInfo} = Dict{String, AuthorInfo}("Author" => AuthorInfo(Name="Author")),
                              Description::T = "") where {T <: AbstractString}

    Info = ProjectInfo(; ID, Title, Authors, Description)

    return DataRegistry(; Info)
end

"""
    AddDataset!(registry::DataRegistry, dataset::Dataset)

Add `dataset` to a `registry`.
Checks that the ID doesn't already exist, and that all the parent datasets exist.
"""
function AddDataset!(registry::DataRegistry, dataset::Dataset)

    # Check that ID is unique
    if haskey(registry.Datasets, dataset.ID)
        error("Dataset with ID '$(dataset.ID)' already exists in the Registry.")
    end

    # Check that parent datasets exist
    ValidateParents(registry, dataset.Parents)

    # Add dataset
    dataset.Registered = now()
    registry.Datasets[dataset.ID] = dataset

    println("Dataset '$(dataset.ID)' added to registry.")
    return nothing
end


"""
    UpdateDataset!(registry, ID; kwargs...)

Update fields of existing Dataset `ID` in `registry`.
Only fields provided as keyword arguments are modified.
Checks that the dataset exists, and that all provided fields are valid.
The dataset's LastModified timestamp is updated automatically.
"""
function UpdateDataset!(registry::DataRegistry, ID::String; kwargs...)

    # Check that dataset exists
    if !haskey(registry.Datasets, ID)
        error("Dataset with ID '$ID' does not exist in registry.")
    end

    dataset = registry.Datasets[ID]

    # Check that all fields exist
    invalid_fields = Set((:ID, :Registered)) # fields that are not allowed to be modified
    valid_fields = setdiff(Set(fieldnames(Dataset)), invalid_fields) # fields that are allowed to be modified

    for (key, value) in kwargs
        if !(key in valid_fields)
            if key == :ID
                error("Dataset ID cannot be modified.")
            elseif key == :Registered
                error("Dataset registration time cannot be modified.")
            else
                error("Dataset has no field '$key'. " * "Valid fields are: $(join(valid_fields, ", "))")
            end
        else
            setfield!(dataset, key, value) # update field
        end
    end

    # Validate parents if changed
    if :Parents in keys(kwargs)
        ValidateParents(registry, dataset.Parents)
    end

    # Update modification timestamp
    dataset.LastModified = now()

    println("Dataset '$(dataset.ID)' updated in the registry.")
    return nothing
end



"""
    UpdateOrAddDataset!(registry, ID; kwargs...)

Update existing, or add new `Dataset` `ID` to `registry`.
"""
function UpdateOrAddDataset!(registry::DataRegistry, ID::String; kwargs...)

    if haskey(registry.Datasets, ID)
        println("Dataset '$(ID)' already exists, updating...")
        UpdateDataset!(registry, ID; kwargs...)
    else
        println("Dataset '$(ID)' does not exist, creating it instead.")
        dataset = Dataset(; ID, kwargs...)
        AddDataset!(registry, dataset)
    end
    return nothing
end



"""
    RemoveDataset!(registry, ID)

Remove `Dataset` `ID` from `registry`.
Checks that the dataset exists.
Asks for confirmation if the dataset is a parent of any other datasets.
"""
function RemoveDataset!(registry::DataRegistry, ID; confirm=true, allow_orphans=true)

    # Check that dataset exists
    if !haskey(registry.Datasets, ID)
        error("Dataset '$ID' does not exist in registry.")
    end

    # Check that this dataset doesn't have children that would be orphaned #
    children = FindChildren(registry, ID)
    if !isempty(children)
        if allow_orphans
            @warn "Dataset '$ID' is a parent of datasets: $(join(children, ", ")). Deleting it will orphan these datasets and may cause problems."
            
            if confirm
                menu = RadioMenu(["Yes", "No"], charset=:ascii)
                choice = request("Continue?", menu)

                if choice == 2
                    println("Dataset '$ID' not deleted.")
                    return nothing
                end
            end
        else
            error("Dataset '$ID' is a parent of datasets: $(join(children, ", ")). Deleting it would orphan these datasets. Set `allow_orphans=true` to override this check.")
        end
    end

    # Delete dataset
    delete!(registry.Datasets, ID)
    println("Dataset '$(ID)' deleted from the registry.")

    return nothing
end