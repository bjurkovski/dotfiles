# dotfiles

## One-off Setup
* Follow the [Nix Download Instructions](https://nixos.org/download/) if you haven't already installed it
* You may want to add `experimental-features = nix-command flakes` to your `~/.config/nix/nix.conf`

## Running locally
* In case you checked out this repo locally, you can run `nix develop` to start the shell

## Running remotely
* You can also start this dev shell without checking it out by running `nix develop github:bjurkovski/dotfiles`
  * **Note:** use `nix flake metadata github:bjurkovski/dotfiles --refresh` when you want to fetch a new version / invalidate your cache
