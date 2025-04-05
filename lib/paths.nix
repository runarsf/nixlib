{ lib, ... }:
let
  inherit (builtins)
    filter
    map
    match
    toString
    readDir
    elem
    dirOf
    baseNameOf
    ;

  inherit (lib.path) hasPrefix;
in
{
  # Concatinates all file paths in a given directory into one list.
  # Optionally, recursing through subdirectories.
  # If it detects a default.nix, only that file will be considered.
  concatPaths =
    {
      path ? null,
      paths ? [ ],
      include ? [ ],
      exclude ? [ ],
      recursive ? true,
      filterDefault ? true,
    }:
    with lib;
    with fileset;
    let
      excludedFiles = filter (path: pathIsRegularFile path) exclude;
      excludedDirs = filter (path: pathIsDirectory path) exclude;
      isExcluded =
        path:
        if elem path excludedFiles then
          true
        else
          (filter (excludedDir: hasPrefix excludedDir path) excludedDirs) != [ ];

      myFiles = unique (
        (filter (file: pathIsRegularFile file && hasSuffix ".nix" (toString file) && !isExcluded file) (
          concatMap (
            _path:
            if recursive then
              toList _path
            else
              mapAttrsToList (
                name: type: _path + (if type == "directory" then "/${name}/default.nix" else "/${name}")
              ) (readDir _path)
          ) (unique (if path == null then paths else [ path ] ++ paths))
        ))
        ++ (if recursive then concatMap (path: toList path) (unique include) else unique include)
      );

      dirOfFile = map (file: dirOf file) myFiles;

      # TODO Support disabling this bit (the one that only imports default.nix if it exists)
      dirsWithDefaultNix = filter (dir: elem dir dirOfFile) (
        map (file: dirOf file) (filter (file: match "default.nix" (baseNameOf file) != null) myFiles)
      );

      filteredFiles = filter (
        file: elem (dirOf file) dirsWithDefaultNix == false || match "default.nix" (baseNameOf file) != null
      ) myFiles;
    in
    if filterDefault then filteredFiles else myFiles;
}
