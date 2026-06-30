ENV ?= dev

.PHONY: init plan apply destroy fmt validate docs

init:
	terraform init -backend-config="envs/$(ENV)/backend.hcl"

plan:
	terraform plan -var-file="envs/$(ENV)/terraform.tfvars"

apply:
	terraform apply -var-file="envs/$(ENV)/terraform.tfvars"

destroy:
	terraform destroy -var-file="envs/$(ENV)/terraform.tfvars"

fmt:
	terraform fmt -recursive

validate:
	terraform validate

docs:
	terraform-docs markdown table --output-file README.md --output-mode inject .
	@for module in modules/*/; do \
		terraform-docs markdown table --output-file $$module/README.md --output-mode inject $$module; \
	done
