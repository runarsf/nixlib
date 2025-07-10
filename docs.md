




























## `lib.fmatch` {#function-library-lib.fmatch}

Pattern match based on functional predicates.

### Arguments

x
: The value to match against.

cases
: A list of pairs, where each pair consists of a predicate function and a result value.

### Type

```nix
fmatch :: (a -> bool) -> [(a -> bool, b)] -> b
```

### Example

```nix
fmatch "hello" (with builtins; [
  [ isString "string" ]
  [ isList "list" ]
])
=> [ "string" ]
```



## `lib.fill` {#function-library-lib.fill}

Set the value of each attribute given a list of paths.

### Arguments

value
: The value to set.

xs
: A list of paths to set the value for.
: The paths can be strings or lists of strings.

### Example

```nix
fill { enable = true; } [ "a" [ "a" "b" ] ]
=> {
  a = {
    b = { enable = true; };
    enable = true;
  };
}
```

## `lib.hasAttrPath` {#function-library-lib.hasAttrPath}

Checks if the given attribute path exists in the attribute set.















## `lib.concatPaths` {#function-library-lib.concatPaths}

Collects `.nix` files from given paths,
optionally recursing through subdirectories and applies filters.
Inspired by and adapted from https://github.com/yunfachi/nypkgs/blob/master/lib/umport.nix

### Arguments

paths
: Path or list of paths to search for `.nix` files (automatically coerced to list).

include
: Extra paths to add to results (bypasses normal filtering).
: Recursively expanded if `recursive = true`.

exclude
: Paths or files to exclude from results.
: Can be a list of paths or extended POSIX regular expressions.
: Regexes are matched against each component of the path.
: Explicitly excluded paths take precedence over `include`, but regexes do not.

recursive
: Whether to search subdirectories.

filterDefault
: If `true`, only include `default.nix` in dirs that have one.

### Type

```nix
concatPaths :: {
  paths: Path | [Path],
  include?: Path | [Path],
  exclude?: Path | [Path|String],
  recursive?: Bool,
  filterDefault?: Bool,
} -> [Path]
```

### Example

```nix
concatPaths {
  paths = [ ./src ./modules ];
  exclude = [ ./modules/deprecated "^\\..*" ];
}
=> [ ./src/foo.nix ./modules/bar.nix ./modules/module/default.nix ]








