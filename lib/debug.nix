let
  inherit (builtins) trace;
in {
  exports = {
    print = x: trace x x;
  };
}
