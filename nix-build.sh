#!/run/current-system/sw/bin/bash

set -e

NIX_EXPERIMENTAL_ENABLE='--extra-experimental-features nix-command --extra-experimental-features flakes'
NIX_ACTIVE_PROFILE=/nix/var/nix/profiles/system

#printf "\nGit diff...\n"
#git diff

printf "\nShowing meld...\n"
meld {/etc/nixos,.}/configuration.nix
meld {/etc/nixos,.}/hardware-configuration.nix

cp configuration.nix /etc/nixos/configuration.nix
cp hardware-configuration.nix /etc/nixos/hardware-configuration.nix

rm -rf result
nixos-rebuild build

nix $NIX_EXPERIMENTAL_ENABLE \
  store diff-closures \
  $NIX_ACTIVE_PROFILE ./result


printf "\nContinue? [Y/n]: "
read -n 1 -r
if [[ $REPLY =~ ^[Y]$ ]]
then
  nixos-rebuild switch
fi
