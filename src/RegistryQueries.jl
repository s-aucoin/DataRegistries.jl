# This file is for defining functions to access information about the registry and datasets #

export FindChildren


"""
    FindChildren(registry, ID)

Find all `Datasets` in `registry` that have `ID` as a parent.
"""
function FindChildren(registry::DataRegistry, ID::String)

    # Check that ID exists in the registry
    if !haskey(registry.Datasets, ID)
        error("Dataset '$ID' does not exist in registry.")
    end

    children = String[]
    for (id, dataset) in registry.Datasets
        if ID in dataset.Parents
            push!(children, id)
        end
    end

    return children
end