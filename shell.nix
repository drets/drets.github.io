with import <nixpkgs> { };

haskell.lib.buildStackProject {
  name = "drets.github.io";
  ghc = haskell.packages.ghc7103.ghc;
  buildInputs = [
    git # To enable git packages in stack.yaml
    cabal-install # For stack solver
    zlib
  ];
}
