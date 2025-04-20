{
  lib,
  lib',
}: let
  inherit (builtins) map concatMap tail;

  inherit (lib.strings) splitString;

  inherit (lib'.filesystem) concatPaths;
in let
  result = concatPaths {
    paths = ./__test;
    include = [
      ./__test/.vulpes/lagopus.nix
    ];
    exclude = [
      "^\\..*" # Exclude hidden files
      ./__test/fennec.nix
    ];
  };

  # We're not allowed to reference nix store paths,
  # so we need to extract the filenames in tests.
  # This is not necessary in real code.
  filenames = xs:
    xs
    |> map toString
    |> map (path: splitString "/__test/" path)
    |> concatMap tail;
in
  filenames result
