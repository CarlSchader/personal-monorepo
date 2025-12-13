# nix-config

Personal Nix flake configuration for macOS and NixOS machines.

## Machines

| Machine | Platform | Users |
|---------|----------|-------|
| `Carls-MacBook-Pro-2` | aarch64-darwin | carlschader |
| `Carls-MacBook-Air-2` | aarch64-darwin | carl |
| `Carls-MacBook-Pro` | aarch64-darwin | carlschader, saronic |
| `Carls-MacBook-Air` | aarch64-darwin | carl.schader |
| `ml-pc` | x86_64-linux | carl, saronic, connor |

## Structure

```
nix/
├── common/                 # Platform-specific package lists
├── darwin-configurations/  # macOS machine configs
├── nixos-configurations/   # NixOS machine configs (ml-pc)
├── nixos-modules/          # Reusable modules (services, users)
└── lib/                    # Home-manager config, SSH keys
```

## Usage

**macOS (Darwin)**
```sh
darwin-rebuild switch --flake .#<machine-name>
```

**NixOS**
```sh
nixos-rebuild switch --flake .#ml-pc
```

## License

MIT
