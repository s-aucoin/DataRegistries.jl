# Library

All functions exported by this package are listed below.

## Library Contents
```@contents
Pages = ["library.md"]
Depth = 3
```

## Index
```@index
```


## Functions

### Registry Management
```@docs
InitializeRegistry
AddDataset!
UpdateDataset!
UpdateOrAddDataset!
RemoveDataset!
```

### Registry Queries
```@docs
FindChildren
```

### Validations
```@docs
ValidateParents
DataExists
ValidateDataset
```

### Conversions
```@docs
DataRegistries.to_toml
DataRegistries.from_toml
```

### IO
```@docs
SaveRegistry
LoadRegistry
```