using LinearAlgebra
using Serialization

export BuildSemanticIndex, SaveSemanticIndex, LoadSemanticIndex

function unit_embedding(v)
    x = Float32.(vec(v))
    n = norm(x)

    isfinite(n) && n > 0 ||
        throw(ArgumentError("Embedding must have a finite, nonzero norm"))

    return x ./ n
end


function BuildSemanticIndex(datasets::Dict{String, Dataset}; embedder=DataRegistries.LocalBERT())
    entries = collect(pairs(datasets))

    isempty(entries) && throw(ArgumentError("Cannot index an empty registry"))

    ids = collect(keys(datasets))

    texts = [DatasetText(last(entries[i])) for i in eachindex(entries)]

    vectors = hcat(
        (DataRegistries.unit_embedding(embedder(text)) for text in texts)...
    )

    return DataRegistries.SemanticIndex(ids, texts, vectors)
end


function SaveSemanticIndex(index::SemanticIndex; path::AbstractString = "search_index/semantic_index.bin")
    mkpath(dirname(abspath(path)))
    serialize(path, index)
    return path
end


function LoadSemanticIndex(path::AbstractString)
    isfile(path) || throw(ArgumentError("Semantic index not found: $path"))

    index = deserialize(path)

    index isa SemanticIndex || throw(ArgumentError("File does not contain a SemanticIndex"))

    return index
end