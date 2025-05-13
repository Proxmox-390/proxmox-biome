# Biome for Proxmox Projects

## Overview

This is a relatively simple Debian package of the [biome](https://biomejs.dev)
format and lint tool chain for web projects.

It's build using vendored sources for supply chain control, and effectively is
a stop-gap until the package in Debian gets ready [0]. We plan to help on
contributing some missing rust crate dependencies.

Once a native Debian package becomes available we can switch over to it,
keeping only the small wrapper script and our desired config.

0: https://salsa.debian.org/debian/biome/-/blob/debian/latest/debian/TODO

## Proxmox Wrapper and Configuration

Besides the `biome` executable we also ship a small `proxmox-biome` wrapper
script in that mostly adds a option to always use a `biome.json` config that is
also shipped in this package. Both reside in the `src/` folder.
This config implements the Proxmox JavaScript style guide as closely as
possible. We accept some trade-offs in desired and resulting style, that stems
from biomes own opinionated implementation that does not have much fine-grained
options for the format style, but rather only exposes control to big style
decisions like indentation level/style.
This is a pragmatic decision to prefer having a good and fast formatter and
linter combination over the relatively hard to maintain linter we previously
used (eslint) an non-existent formatter.

## Vendoring Dependencies

We have all dependencies assembled using `cargo vendor` and checked into git.
To reduce size we filter out all artefacts for Windows support, which is saving
over 200 MiB of disk space. That's why you should always use the Makefile's
`update` target to update the vendored crates, as it applies the correct
filters and automatically creates a git commit.

## Disclaimer for External Use

If you want to use this packaging then feel free to do so under the rights
*and* limits of the licenses and copyrights this package, and mainly the biome
project is using.

But, you should know that we give no stability guarantees whatsoever and might
drop this package at any time, be it to switch to a native Debian package or be
it due to replacing it altogether with something completely else, or having no
need for JS linting and formatting due to having no JS code anymore (one can
only dream).

## Copyright and Licenses

- For the biome source code:
  Copyright (c) 2023-present Biome Developers and Contributors
- For all rust crates inside the `vendor/` repository please check the
  respective `Cargo.toml` and/or LICENSE or COPYRIGHT files in each crates
  folder.
- The `debian/` folder contains the packaging definitions and the `src/` folder
  contains the wrapper and our config, see the `debian/copyright` file for
  details.
