{lib'}: let
  inherit (lib'.merge) deepMerge;
in
  deepMerge [
    {
      family = "Canidae";
      genus = "Vulpes";
      species = "Lagopus";
    }
    {
      genus = "Vulpes";
      species = "Ferrilata";
    }
  ]
