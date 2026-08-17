# functions for validating #

function ValidateParents(registry::DataRegistry, Parents::Vector{String})

    parent_exists = haskey.(Ref(registry.Datasets), Parents)

    if !all(parent_exists)
        error("The following parent datasets do not exist in the Registry: " *
            "$(join(Parents[.!parent_exists], ", "))")
    end

    return nothing

end