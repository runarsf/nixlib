# nixlib

## [Documentation][docs]

See [docs.md][docs] for the full documentation, and [tests][tests] for usage examples.

Documentation is automatically generated using [`nixdoc`][nixdoc] by running `nix run .#nixdoc`.

## [Tests][tests]

This project uses [`namaka`][namaka] for snapshot testing.
You can run the tests using `namaka check`, and review pending snapshots using `namaka review`.


[tests]: ./tests
[docs]: ./docs.md
[namaka]: https://github.com/nix-community/namaka
[nixdoc]: https://github.com/nix-community/nixdoc
