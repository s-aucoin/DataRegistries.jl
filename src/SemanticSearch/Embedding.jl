using Transformers
using Transformers.TextEncoders
using Transformers.HuggingFace
using Statistics

export LocalBERT

struct LocalBERT{E, M}
    encoder::E
    model::M
end

function LocalBERT()
    encoder, model = hgf"sentence-transformers/all-MiniLM-L6-v2" #hgf"bert-base-uncased"
    return LocalBERT(encoder, model)
end

function (e::LocalBERT)(text::AbstractString)
    sample = encode(e.encoder, String(text))
    hidden = e.model(sample).hidden_state

    # Expected layout: hidden dimension × token × batch.
    #n = size(hidden, 2)

    # Number of actual tokens, excluding padding.
    n = Int(first(sample.attention_mask.len))

    n > 2 || throw(ArgumentError("Text is too short to embed"))

    # Mean-pool all valid tokens, including special tokens.
    token_embeddings = @view hidden[:, 1:n, 1]

    return vec(mean(token_embeddings; dims=2))
end