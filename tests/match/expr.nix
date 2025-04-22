{lib'}: let
  inherit (lib'.matching) match;
in
  match {
    genus = "Vulpes";
    species = "Lagopus";
  } [
    [{species = "Ferrilata";} "Tibetan Fox"]
    [{species = "Lagopus";} "Arctic Fox"]
    [{species = "Vulpes";} "Red Fox"]
  ]
