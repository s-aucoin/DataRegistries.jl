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
    encoder, model = hgf"bert-base-uncased"
    return LocalBERT(encoder, model)
end

function (e::LocalBERT)(text::AbstractString)
    sample = encode(e.encoder, String(text))
    hidden = e.model(sample).hidden_state

    # Expected layout: hidden dimension × token × batch.
    n = size(hidden, 2)

    n > 2 || throw(ArgumentError("Text is too short to embed"))

    # Mean-pool the token vectors, excluding boundary tokens.
    return vec(mean(hidden[:, 2:(n - 1), 1]; dims = 2))
end