{
  description = "Terraform Registry Module Template Devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowUnfreePredicate =
              pkg:
              builtins.elem (pkgs.lib.getName pkg) [
                "terraform"
                "opentofu"
              ];
          };
        };

        # Consolidated tools list
        devTools = with pkgs; [
          # Go toolchain
          go
          go-tools
          golangci-lint

          # Terraform and related
          terraform
          terraform-ls
          tflint
          opentofu
          terraform-docs

          # Development and utility tools
          just
          git
          bash

          # YAML tools
          yamllint
          yamlfmt

          # Shell scripting
          shellcheck

          # Pre-commit and direnv
          pre-commit
          direnv
        ];
      in
      {
        # Development shell configuration
        devShells.default = pkgs.mkShell {
          buildInputs = devTools;

          shellHook = ''
            echo "🚀 Devshell for Terraform Registry Module Template 🛠️"
            echo "Go version: $(go version)"
            echo "Terraform version: $(terraform version)"
            echo "OpenTofu version: $(tofu version)"
          '';
        };

        # Pre-commit hooks configuration
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            # IMPORTANT: This configuration is SEPARATE from .pre-commit-config.yaml
            # These are Nix-specific pre-commit checks that run during `nix flake check`
            hooks = {
              # Basic file checks
              trailing-whitespace.enable = true;
              end-of-file-fixer.enable = true;
              check-yaml.enable = true;
              check-added-large-files.enable = true;
              check-merge-conflict.enable = true;

              # Go-specific hooks
              go-fmt = {
                enable = true;
                entry = "${pkgs.go}/bin/gofmt -l -w";
                files = "\\.go$";
              };
              # Terraform and OpenTofu hooks
              terraform-fmt = {
                enable = true;
                entry = "${pkgs.terraform}/bin/terraform fmt -check -recursive";
                files = "\\.(tf|tfvars)$";
              };
              tofu-fmt = {
                enable = true;
                entry = "${pkgs.opentofu}/bin/tofu fmt -check -recursive";
                files = "\\.(tf|tfvars)$";
              };

              # YAML and shell checks
              yamllint.enable = true;
              shellcheck.enable = true;
            };
          };
        };
      }
    );
}
