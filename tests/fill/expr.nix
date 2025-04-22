{lib'}: let
  inherit (lib'.attrs) fill;
in
  fill {enable = true;} ["foo" ["foo" "bar"] "baz"]
