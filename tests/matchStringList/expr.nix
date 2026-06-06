{lib'}: let
  inherit (lib'.matching) matchStringList;
in
  matchStringList ["Lagopus" "Ferrilata"] [
    ["Ferrilata" "Tibetan Fox"]
    ["Lagopus" "Arctic Fox"]
    ["Vulpes" "Red Fox"]
  ]
