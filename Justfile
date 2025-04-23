# Justfile for managing NixOS builds
#
# Usage:
# - Run `just build-laptop` to rebuild NixOS using the `doma` flake.
# - Run `just` to list available commands.

default:
    @just --list

[doc('Run nixos-rebuild on the laptop')]
build-laptop:
    # Rebuild NixOS configuration for the laptop
    sudo nixos-rebuild switch --flake .#doma
