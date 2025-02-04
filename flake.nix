{
  description = "Terraform Registry Module Template Devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Go toolchain
            go
            go-tools
            golangci-lint

            # Terraform and related
            terraform
            terraform-ls
            tflint

            # YAML tools
            yamllint
            yamlfmt

            # Shell scripting
            shellcheck

            # Pre-commit
            pre-commit
          ];

          shellHook = ''
            echo "🚀 Devshell for Terraform Registry Module Template 🛠️"
            echo "Loaded tools: Go, Terraform, YAML, Shellcheck, Pre-commit"

            # Setup pre-commit if not already initialized
            if [ ! -f .pre-commit-config.yaml ]; then
              pre-commit sample-config > .pre-commit-config.yaml
            fi

            pre-commit install
          '';
        };

        # Optional: Pre-commit hooks configuration
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              yamllint.enable = true;
              shellcheck.enable = true;
              # Add more hooks as needed
            };
          };
        };

        # Default shell
        defaultPackage = self.devShells.${system}.default;
      }
    );
}
