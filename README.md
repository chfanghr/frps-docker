# frps-docker

The idea is to run [frp](https://github.com/fatedier/frp) services as docker containers on the cloud. There are two main benefits:

- You don't need to manage a VPS; just deploy and forget.
- The cost is *so* low compared to a VPS cause you won't need that much computational power.

## Quick Start

- Clone this repo.
- Edit the `token` field in `config.nix`, which should be a valid UUID.
- Run `nix build .#frpsImage`.
  - Make sure that you have the [nix package manager](https://nixos.org) installed.
  - And also, [enable nix flake](https://nixos.wiki/wiki/Flakes).
- Your image should be located at `./result`. You can test it out locally as you please.
  - To load it into `podman`, run `podman load < result`.
- Deploy and enjoy. The port mapping should be taken care of automatically.
