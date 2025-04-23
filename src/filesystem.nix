{
  lib,
  lib',
}: let
  inherit
    (builtins)
    match
    filter
    elem
    any
    readDir
    baseNameOf
    toString
    dirOf
    isPath
    isString
    ;

  inherit (lib'.lists) isEmpty;

  inherit (lib) toList;

  inherit (lib.path) hasPrefix;

  inherit (lib.trivial) warnIf;

  inherit (lib.attrsets) mapAttrsToList;

  inherit (lib.strings) hasSuffix splitString;

  inherit (lib.lists) unique concatMap flatten;

  inherit (lib.filesystem) pathIsRegularFile pathIsDirectory;

  fs = {inherit (lib.fileset) toList maybeMissing;};
in rec {
  exports = {
    inherit concatPaths;
  };

  /**
  Collects `.nix` files from given paths,
  optionally recursing through subdirectories and applies filters.
  Inspired by and adapted from https://github.com/yunfachi/nypkgs/blob/master/lib/umport.nix

  # Arguments

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

  # Type

  ```nix
  concatPaths :: {
    paths: Path | [Path],
    include?: Path | [Path],
    exclude?: Path | [Path|String],
    recursive?: Bool,
    filterDefault?: Bool,
  } -> [Path]
  ```

  # Example

  ```nix
  concatPaths {
    paths = [ ./src ./modules ];
    exclude = [ ./modules/deprecated "^\\..*" ];
  }
  => [ ./src/foo.nix ./modules/bar.nix ./modules/module/default.nix ]
  */
  concatPaths = {
    paths,
    include ? [],
    exclude ? [],
    recursive ? true,
    filterDefault ? true,
  }: let
    # Coerce arguments to lists
    coerce = x: unique <| toList x;
    paths' = coerce paths;
    include' = coerce include;
    exclude' = coerce exclude;

    # Helper functions
    isNixFile = path: pathIsRegularFile path && hasSuffix ".nix" (toString path);
    isDefaultNix = path: match "default.nix" (baseNameOf path) != null;
    toListMaybe = path: fs.toList <| fs.maybeMissing path;

    # Split exclude into paths and regex patterns
    excludedPaths = filter isPath exclude';
    excludedPatterns = filter isString exclude';

    # Path-based exclusion
    excludedFiles = filter pathIsRegularFile excludedPaths;
    excludedDirs = filter pathIsDirectory excludedPaths;
    pathExcluded = path:
      elem path excludedFiles
      || any (excludedDir: hasPrefix (toString excludedDir + "/") (toString path + "/")) excludedDirs;

    # Regex component matching
    componentExcluded = path: let
      components =
        path
        |> toString
        |> splitString "/"
        |> filter (s: s != "");
      matches = component: any (pattern: match pattern component != null) excludedPatterns;
    in
      any matches components;

    # Get all candidate files
    getFiles = path:
      if recursive
      then toListMaybe path
      else
        path
        |> readDir
        |> mapAttrsToList (name: _: path + "/${name}");

    candidateFiles = unique <| concatMap getFiles paths';

    # Filter files
    filteredFiles = filter (f: isNixFile f && !pathExcluded f && !componentExcluded f) candidateFiles;
    filteredInclude = filter (f: isNixFile f && !pathExcluded f) include';

    # Handle default.nix logic
    dirsWithDefaultNix =
      filteredFiles
      |> filter isDefaultNix
      |> map dirOf
      |> unique;

    finalFiles =
      unique
      <| flatten [
        (
          if filterDefault
          then filter (file: !(elem (dirOf file) dirsWithDefaultNix) || isDefaultNix file) filteredFiles
          else filteredFiles
        )
        (
          if recursive
          then let
            includes = concatMap toListMaybe filteredInclude;
          in
            warnIf (isEmpty includes && !isEmpty include') "concatPaths: No include paths found" includes
          else filteredInclude
        )
      ];
  in
    warnIf (isEmpty finalFiles) "concatPaths: No paths found" finalFiles;
}
