{lib}: let
  inherit (lib) fix;
in {
  /**
  Raises the `base` to the power of `power`.


  Considering the small input size and the lack of a built-in power function [2],
  this naive power implementation should satisfy reasonable performance
  requirements.

  Due to the lack of a modulo and bitwise AND operator, it is questionable whether
  the recursive exponentiation by squaring [1] implementation would even be
  faster.

  [1]: https://en.wikipedia.org/wiki/Exponentiation_by_squaring
  [2]: https://github.com/NixOS/nix/issues/10387

  # Type

  pow :: Number -> Number -> Number

  # Arguments

  base
  : The base number to be raised.

  power
  : The exponent to raise `base` to.

  # Examples

  pow 2 5
  => 32
  */
  pow = fix (
    self: base: power:
      if power != 0
      then base * (self base (power - 1))
      else 1
  );
}
