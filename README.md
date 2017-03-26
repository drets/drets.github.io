drets.github.io
=================

Sources branch for drets.github.io.

Build instructions
------------------

The build scripts assume two different repositories within one parent
directory are used for the `master` and `sources` branch:

    drets.github.io
        drets.github.io/master
            drets.github.io/master/.git
        drets.github.io/sources
            drets.github.io/sources/.git

The site is generated using [Hakyll](http://jaspervdj.be/hakyll/).

Build commands and scripts (all should be ran from the `sources` root
directory):

    # Enter nix-shell
    nix-shell

    # Installs Haskell dependencies.
    stack build

    # Compiles the Hakyll executable and copies it to the sources root.
    ./build-hs.sh

    # Compiles the Hakyll executable and rebuilds the site from scratch.
    # Use it after changes in the executable.
    ./full-build.sh

    # After compiling the Hakyll executable, builds the site incrementally.
    # See the Hakyll documentation for other commands.
    drets-github-io build

    # Transfers the built site to the master root using rsync.
    # Afterwards, you should commit the updates at the master clone.
    ./synchronise.sh

    # Rebuilds the site, transfers it to the master root, commits the changes
    # there and publishes to GitHub.
    # Uses a https://hackage.haskell.org/package/turtle script
    # defined in `Scripts.hs`.
    drets-github-io deploy

Repository layout
-----------------

The initial repository layout can be achieved as follows:

    mkdir -p drets.github.io
    git clone git@github.com:drets/drets.github.io.git master
    git clone git@github.com:drets/drets.github.io.git sources
    cd sources/
    git checkout sources
    git branch -d master
    cd ..

Tips
-----
• to enable reddit button put `reddit: enabled` to template
