{lib, ...}: let
  inherit (builtins) match filter elem any readDir baseNameOf toString dirOf;

  inherit (lib) toList;

  inherit (lib.path) hasPrefix;

  inherit (lib.lists) unique concatMap;

  inherit (lib.strings) hasSuffix;

  inherit (lib.attrsets) mapAttrsToList;

  inherit (lib.filesystem) pathIsRegularFile pathIsDirectory;

  fs = {inherit (lib.fileset) toList;};
in {
  /**
  Collects `.nix` files from given paths,
  optionally recursing through subdirectories and applies filters.

  # Arguments

  paths
  : Path or list of paths to search for `.nix` files (automatically coerced to list).

  include
  : Extra paths to add to results (bypasses normal filtering).
  : Recursively expanded if `recursive = true`.

  exclude
  : Paths or files to exclude from results.
  : Takes precedence over `include`.

  recursive
  : Whether to search subdirectories.

  filterDefault
  : If `true`, only include `default.nix` in dirs that have one.

  # Type

  ```nix
  concatPaths :: {
    paths: Path | [Path],
    include?: Path | [Path],
    exclude?: Path | [Path],
    recursive?: Bool,
    filterDefault?: Bool,
  } -> [Path]
  ```

  # Example

  ```nix
  concatPaths {
    paths = [ ./lib ./modules ];
    exclude = [ ./modules/deprecated ];
  }
  => [ ./lib/foo.nix ./modules/bar.nix ./modules/module/default.nix ]
  */
  concatPaths = {
    paths,
    include ? [],
    exclude ? [],
    recursive ? true,
    filterDefault ? true,
  }: let
    # Coerce paths to lists
    paths' = unique <| toList paths;
    include' = unique <| toList include;
    exclude' = unique <| toList exclude;

    # Helper functions
    isNixFile = path: pathIsRegularFile path && hasSuffix ".nix" (toString path);
    isDefaultNix = path: match "default.nix" (baseNameOf path) != null;

    # Process exclusions
    excludedFiles = filter pathIsRegularFile exclude';
    excludedDirs = filter pathIsDirectory exclude';
    isExcluded = path:
      elem path excludedFiles
      || any (excludedDir: hasPrefix excludedDir path) excludedDirs;

    # Get all candidate files
    getFiles = path:
      if recursive
      then fs.toList path
      else
        mapAttrsToList
        (name: type: path + "/${name}")
        (readDir path);

    candidateFiles = unique <| concatMap getFiles paths';

    # Filter files
    filteredFiles =
      filter
      (file: isNixFile file && !isExcluded file)
      candidateFiles;
    filteredInclude =
      filter
      (file: isNixFile file && !isExcluded file)
      include';

    # Handle default.nix logic
    dirsWithDefaultNix =
      filteredFiles
      |> filter isDefaultNix
      |> map dirOf
      |> unique;
    finalFiles =
      if filterDefault
      then
        filter
        (file: !(elem (dirOf file) dirsWithDefaultNix) || isDefaultNix file)
        filteredFiles
      else filteredFiles;
  in
    finalFiles
    ++ (
      if recursive
      then concatMap fs.toList filteredInclude
      else filteredInclude
    );
}
