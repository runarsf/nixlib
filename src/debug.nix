let
  inherit (builtins) trace;
in rec {
  exports = {
    inherit print;
  };

  print = x: trace x x;
}
