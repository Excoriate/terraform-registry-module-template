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

        # Version configuration for easy updates
        terraformVersion = "1.11.2";
        opentofuVersion = "1.9.0";

        # Convert version string to Nix package name format (e.g., 1.8.0 -> 1_8_0)
        tfVersionFormatted = builtins.replaceStrings [ "." ] [ "_" ] terraformVersion;

        # Create attribute name for the terraform package
        tfAttrName = "terraform_${tfVersionFormatted}";

        # Custom terraform package with desired version
        # Use hasAttr to check if the specific version exists in nixpkgs
        terraform-pkg = if pkgs.lib.hasAttr tfAttrName pkgs then pkgs.${tfAttrName} else pkgs.terraform; # Fallback to default if specified version not available

        # Custom opentofu package with desired version
        opentofu-pkg = pkgs.opentofu;

        # Consolidated tools list
        devTools = with pkgs; [
          # Go toolchain
          go
          go-tools
          golangci-lint

          # Terraform and related
          terraform-pkg
          terraform-ls
          tflint
          opentofu-pkg
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
            echo "Terraform version: $(${terraform-pkg}/bin/terraform version)"
            echo "OpenTofu version: $(${opentofu-pkg}/bin/tofu version)"
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
                entry = "${terraform-pkg}/bin/terraform fmt -check -recursive";
                files = "\\.(tf|tfvars)$";
              };
              tofu-fmt = {
                enable = true;
                entry = "${opentofu-pkg}/bin/tofu fmt -check -recursive";
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
