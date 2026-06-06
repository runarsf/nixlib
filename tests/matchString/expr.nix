{lib'}: let
  inherit (lib'.matching) matchString;
in
  matchString "Ferrilata" [
    ["Ferrilata" "Tibetan Fox"]
    ["Lagopus" "Arctic Fox"]
    ["Vulpes" "Red Fox"]
  ]
