# Default variables
ENV ?= dev

# Root directories for different Terraform components
MODULE ?= default
VARS ?= ""
TEST_DIR ?= tests
TERRATEST_DIR_UNIT ?= unit
TERRATEST_DIR_INTEGRATION ?= integration
TEST_TYPE ?= unit
TERRAFORM_MODULES_DIR	?= modules
TERRAFORM_RECIPES_DIR ?= examples
RECIPE ?= basic

# Tools, and scripts.
SCRIPTS_FOLDER ?= scripts
GO=go
MODULE_ROOT_DIR = $(TERRAFORM_MODULES_DIR)/$(MODULE)

.PHONY: default clean prune check-workdir tf-init

clean:
	@echo "Cleaning directories..."
	@if [ -d "$(MODULE_ROOT_DIR)" ]; then \
		find . -type d -name ".terraform" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
		echo "Cleaned .terraform directories."; \
	else \
		echo "$(MODULE_ROOT_DIR) directory not found, skipping cleanup of .terraform directories."; \
	fi
	@if [ -d "$(MODULE_ROOT_DIR)" ]; then \
		find . -type d -name ".terragrunt-cache" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
		echo "Cleaned .terragrunt-cache directories."; \
	else \
		echo "$(MODULE_ROOT_DIR) directory not found, skipping cleanup of .terragrunt-cache directories."; \
	fi
	@if [ -d "$(MODULE_ROOT_DIR)" ]; then \
		find . -type f -name "terraform.tfstate" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
		echo "Removed terraform.tfstate files."; \
	else \
		echo "$(MODULE_ROOT_DIR) directory not found, skipping removal of terraform.tfstate files."; \
	fi
	@if [ -d "$(MODULE_ROOT_DIR)" ]; then \
		find . -type f -name "terraform.tfstate.backup" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
		echo "Removed terraform.tfstate.backup files."; \
	else \
		echo "$(MODULE_ROOT_DIR) directory not found, skipping removal of terraform.tfstate.backup files."; \
	fi
	@if [ -d "$(MODULE_ROOT_DIR)" ]; then \
		find . -type f -name "terraform.tfplan" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
		echo "Removed terraform.tfplan files."; \
	else \
		echo "$(MODULE_ROOT_DIR) directory not found, skipping removal of terraform.tfplan files."; \
	fi

prune: clean
	@git clean -f -xd --exclude-list

#####################
# Common targets #
#####################
pc-init:
	@pre-commit install --hook-type pre-commit
	@pre-commit install --hook-type pre-push
	@pre-commit install --hook-type commit-msg
	@pre-commit autoupdate

pc-run:
	@pre-commit run --show-diff-on-failure \
		--all-files \
		--color always

#####################
# Terraform targets #
#####################
tf-clean-all: clean
	@echo "Cleaning all terraform directories..."
	@for dir in $(TERRAFORM_MODULES_DIR)/*; do \
		if [ -d "$$dir" ]; then \
			find $$dir -type d -name ".terraform" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
			echo "Cleaned .terraform directories."; \
		else \
			echo "$$dir directory not found, skipping cleanup of .terraform directories."; \
		fi; \
		if [ -d "$$dir" ]; then \
			find $$dir -type d -name ".terragrunt-cache" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
			echo "Cleaned .terragrunt-cache directories."; \
		else \
			echo "$$dir directory not found, skipping cleanup of .terragrunt-cache directories."; \
		fi; \
		if [ -d "$$dir" ]; then \
			find $$dir -type f -name "terraform.tfstate" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
			echo "Removed terraform.tfstate files."; \
		else \
			echo "$$dir directory not found, skipping removal of terraform.tfstate files."; \
		fi; \
		if [ -d "$$dir" ]; then \
			find $$dir -type f -name "terraform.tfstate.backup" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
			echo "Removed terraform.tfstate.backup files."; \
		else \
			echo "$$dir directory not found, skipping removal of terraform.tfstate.backup files."; \
		fi; \
		if [ -d "$$dir" ]; then \
			find $$dir -type f -name "terraform.tfplan" -exec echo "Removing {}" \; -exec rm -rf '{}' \;; \
			echo "Removed terraform.tfplan files."; \
		else \
			echo "$$dir directory not found, skipping removal of terraform.tfplan files."; \
		fi; \
	done

tf-init: clean
	@cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform init

tf-validate: clean tf-init
	@cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform validate

tf-fmt-check: clean
	@cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform fmt -check=true -diff=true -write=false

tf-fmt: clean
	@cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform fmt -check=false -diff=true -write=true

tf-docs: clean
	@cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform-docs -c .terraform-docs.yml md . > README.md

tf-lint: clean tf-init
	@cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && tflint -v && tflint --init && tflint

tf-ci: clean tf-init tf-validate tf-fmt-check tf-lint tf-docs

tf-plan: clean tf-init
	@if [ -z "$(VARS)" ]; then \
		echo "No vars file provided, skipping terraform plan with vars."; \
		cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform plan; \
	else \
		cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform plan -var-file=$(VARS); \
	fi

tf-apply: tf-plan
	@if [ -z "$(VARS)" ]; then \
		echo "No vars file provided, skipping terraform apply with vars."; \
		cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform apply -auto-approve; \
	else \
		cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform apply -auto-approve -var-file=$(VARS); \
	fi

tf-destroy: tf-init
	@if [ -z "$(VARS)" ]; then \
		echo "No vars file provided, skipping terraform destroy with vars."; \
		cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform destroy -auto-approve; \
	else \
		cd $(TERRAFORM_MODULES_DIR)/$(MODULE) && terraform destroy -auto-approve -var-file=$(VARS); \
	fi

recipe-init: clean
	@echo "Initialize the terraform module"
	@cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init

recipe-plan: recipe-init
	@echo "In the terraform module, execute a terraform plan"
	@if [ -z "$(VARS)" ]; then \
		echo "No vars file provided, skipping terraform plan with vars."; \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform plan; \
	else \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform plan -var-file=config/$(VARS); \
	fi

recipe-apply:
	@echo "In the terraform module, execute a terraform apply"
	@if [ -z "$(VARS)" ]; then \
		echo "No vars file provided, skipping terraform apply with vars."; \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init && terraform apply -auto-approve; \
	else \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init && terraform apply -auto-approve -var-file=config/$(VARS); \
	fi

recipe-destroy:
	@echo "In the terraform module, execute a terraform destroy"
	@if [ -z "$(VARS)" ]; then \
		echo "No vars file provided, skipping terraform destroy with vars."; \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init && terraform destroy -auto-approve; \
	else \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init && terraform destroy -auto-approve -var-file=config/$(VARS); \
	fi

recipe-lifecycle: recipe-init
	@echo "In the terraform module, execute a terraform lifecycle"
	@if [ -z "$(VARS)" ]; then \
		echo "No vars file provided, skipping terraform lifecycle with vars."; \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init && terraform plan && terraform apply -auto-approve && terraform destroy -auto-approve; \
	else \
		cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init && terraform plan -var-file=config/$(VARS) && terraform apply -auto-approve -var-file=config/$(VARS) && terraform destroy -auto-approve -var-file=config/$(VARS); \
	fi

recipe-ci: clean
	@echo "Run CI tasks for the terraform modules as part of the 'test-data' directory"
	@cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform init && terraform validate && terraform fmt -check=true -diff=true -write=false && terraform-docs -c .terraform-docs.yml md . > README.md && tflint -v && tflint --init && tflint

recipe-lint: clean
	@echo "Run linting tasks for the terraform modules as part of the 'test-data' directory"
	@cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && tflint -v && tflint --init && tflint

recipe-docs: clean
	@echo "Generate terraform docs"
	@cd $(TERRAFORM_RECIPES_DIR)/$(MODULE)/$(RECIPE) && terraform-docs -c .terraform-docs.yml md . > README.md

#####################
# Go targets #
#####################
.PHONY: go-tidy
go-tidy:
	@echo "===========> Tidy go.mod in $(TEST_DIR)/$(MODULE)/$(TEST_TYPE)"
	@cd $(TEST_DIR)/$(MODULE)/$(TEST_TYPE) && $(GO) mod tidy

## fmt: Run go fmt against code.
.PHONY: go-fmt
go-fmt:
	@echo "===========> Run go fmt against code in $(TEST_DIR)/$(MODULE)/$(TEST_TYPE)"
	@cd $(TEST_DIR)/$(MODULE)/$(TEST_TYPE) && $(GO) fmt -x ./...

## vet: Run go vet against code.
.PHONY: go-vet
go-vet:
	@echo "===========> Run go vet against code in $(TEST_DIR)/$(MODULE)/$(TEST_TYPE)"
	@cd $(TEST_DIR)/$(MODULE)/$(TEST_TYPE) && $(GO) vet ./...

## lint: Run go lint against code.
.PHONY: go-lint
go-lint:
	@echo "===========> Run go lint against code in $(TEST_DIR)/$(MODULE)/$(TEST_TYPE)"
	@cd $(TEST_DIR)/$(MODULE)/$(TEST_TYPE) && golangci-lint run -v --config ../../../.golangci.yml
#	@golangci-lint run -v --config .golangci.yml

## style: Code style -> fmt,vet,lint
.PHONY: go-style
go-style: go-fmt go-vet go-lint

## test: Run unit test
.PHONY: go-test
go-test:
	@echo "===========> Run unit test in $(TEST_DIR)/$(MODULE)/$(TEST_TYPE)"
	@cd $(TEST_DIR)/$(MODULE)/$(TEST_TYPE) && $(GO) test -v ./ --timeout 30m
