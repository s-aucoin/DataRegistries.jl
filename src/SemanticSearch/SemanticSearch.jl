export DatasetText, SemanticSearch

struct SemanticIndex
    ids::Vector{String}
    texts::Vector{String}
    vectors::Matrix{Float32}  # embedding dimension × dataset count
end


function DatasetText(dataset::Dataset; included_fields=[:ID, :Title, :Description, :Authors, :ProcessingLevel, :Parents, :Registered, :LastModified, :Metadata])
    lines = []

    for field in included_fields
        value = getfield(dataset, field)

        value === nothing && continue

        if field == :Authors
            push!(lines, "$(field): ")
            for (n, (author, info)) in enumerate(collect(pairs(value)))
                push!(lines, "  $n. $(author):")
                for (key, value) in collect(pairs(info))
                    push!(lines, "      $(key): $(value)")
                end
            end

        elseif field == :Metadata
            push!(lines, "$(field): ")
            for (key, value) in collect(pairs(value))
                push!(lines, "  $(key): $(value)")
            end

        else
            push!(lines, "$(field): $(value)")
        end
    end

    return join(lines, "\n")
end


function SemanticSearch(index::DataRegistries.SemanticIndex, query::AbstractString; k::Integer = 10, embedder=DataRegistries.LocalBERT())
    k > 0 || throw(ArgumentError("k must be positive"))

    q = DataRegistries.unit_embedding(embedder(query))

    length(q) == size(index.vectors, 1) || throw(DimensionMismatch("Query and index embedding dimensions differ"))

    scores = vec(index.vectors' * q)
    n = min(k, length(index.ids))
    order = sortperm(scores; rev = true)[1:n]

    return [(id = index.ids[i], score = Float64(scores[i])) for i in order]
end


###########################
include("Embedding.jl")
include("SemanticIndex.jl")