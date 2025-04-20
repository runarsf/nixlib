{lib}: let
  inherit
    (builtins)
    elemAt
    throw
    head
    tail
    ;

  inherit (lib.attrsets) matchAttrs;

  inherit (lib.lists) findFirst;
in {
  exports = rec {
    # https://discourse.nixos.org/t/does-nix-lang-have-structural-pattern-matching/29522/3
    match = let
      if_let = v: p:
        if matchAttrs p v
        then v
        else null;
    in
      v: l: elemAt (findFirst (x: (if_let v (elemAt x 0)) != null) null l) 1;

    /**
    Pattern match based on functional predicates.

    # Arguments

    x
    : The value to match against.

    cases
    : A list of pairs, where each pair consists of a predicate function and a result value.

    # Type

    ```nix
    fmatch :: (a -> bool) -> [(a -> bool, b)] -> b
    ```

    # Example

    ```nix
    match "hello" (with builtins; [
      [ isList "string" ]
      [ isString "list" ]
    ])
    => [ "string" ]
    ```
    */
    fmatch = x: cases:
      if cases == []
      then throw "No cases matched"
      else let
        predicate = head (head cases);
        result = elemAt (head cases) 1;
      in
        if predicate x
        then result
        else fmatch x (tail cases);
  };
}
