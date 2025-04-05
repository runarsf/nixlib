{ ... }:
let
  inherit (builtins) trace;
in
{
  print = x: trace x x;
}
