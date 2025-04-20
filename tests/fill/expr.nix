{lib'}: let
  inherit (lib'.attrs) fill;
in
  fill {enable = true;} ["a" ["a" "b"] "c"]
