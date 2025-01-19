.DEFAULT_GOAL := help

TF_ROOT_DIR := core/terraform

# Commands
TERRAFORM = terraform -chdir=$(TF_ROOT_DIR)
JQ = jq
VENV = venv
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip3 --disable-pip-version-check
DOCKER = docker
AWS = aws

ACCOUNT_ID = $(shell aws sts get-caller-identity | jq -r .Account )

APPLICATION_NAME := aws-load-testing

TF_PROJECT := $(shell basename $(PWD))
PLANFILE := $(TF_PROJECT).plan

# Variables
DOCKER_PLATFORM ?= linux/amd64

# Target Application
TARGET_APP ?= app1
TARGET_ENV ?= dev
export TARGET_APP TARGET_ENV

include core/config/infra.env

ifndef AWS_REGION
	AWS_REGION := eu-north-1
endif

ifndef ACCOUNT_ID
	$(shell echo "Please provide ACCOUNT_ID!") && false
endif

ifndef ECS_CLUSTER
	$(shell echo "Please provide ECS_CLUSTER!") && false
endif

ifndef TF_STATE_S3_BUCKET
	$(shell echo "Please provide TF_STATE_S3_BUCKET!") && false
endif

ECR_URL := $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
DOCKER_IMAGE ?= $(ECR_URL)/$(APPLICATION_NAME)
TF_STATE_S3_KEY ?= $(AWS_REGION)/$(TF_PROJECT).tfstate

PYTHON_JINJA2 := import os;import sys; import jinja2; sys.stdout.write(jinja2.Template(sys.stdin.read()).render(env=os.environ))

# Targets
$(VENV):
	@python3 -m venv $(VENV)
	@$(PIP) install r requirements.txt

.PHONY: set-env
set-env: $(VENV)
	@mkdir -p build && rm -f build/$(TARGET_APP).$(TARGET_ENV).json
	@$(PYTHON) -c '$(PYTHON_JINJA2)' < configs/${TARGET_APP}/${TARGET_ENV}/env.json.j2 > build/$(TARGET_APP).$(TARGET_ENV).json

## pre-commit: Runs pre-commit hooks manually
.PHONY: pre-commit
pre-commit:
	@pre-commit run --all-files

## tf.init: Initialize terraform state backend and providers
.PHONY: tf.init
tf.init:
	@rm -f $(TF_ROOT_DIR)/.terraform/terraform.tfstate
	@$(TERRAFORM) init -upgrade \
		-backend-config="bucket=${TF_STATE_S3_BUCKET}" \
		-backend-config="key=$(TF_STATE_S3_KEY)"

## tf.plan: Runs a terraform plan
.PHONY: tf.plan
tf.plan: tf.init
	$(call blue,"# Running terraform plan...")
	@rm -f "$(PLANFILE)"
	@$(TERRAFORM) plan \
		-input=false \
		-var-file=vars/infra.tfvars \
		-refresh=true $(PLAN_ARGS) \
		-out="$(PLANFILE)"

## tf.apply: Applies a planned state.
.PHONY: tf.apply
tf.apply:
	$(call blue,"# Running terraform apply...")
	@if [ ! -r "${TF_ROOT_DIR}/$(PLANFILE)" ]; then echo "You need to plan first!" ; exit 14; fi
	@$(TERRAFORM) apply -input=true -refresh=true "$(PLANFILE)"

## tf.destroy: Destroy resources created by terraform.
.PHONY: tf.destroy
tf.destroy:
	$(call blue,"# Running terraform destroy...")
	@if [ ! -r "${TF_ROOT_DIR}/$(PLANFILE)" ]; then echo "You need to plan first!" ; exit 14; fi
	@$(TERRAFORM) destroy \
		-var-file=vars/infra.tfvars

tf.import:
	@$(TERRAFORM) import \
		-var-file=vars/infra.tfvars \
		$(TO) $(ID)

## docker.build: Build the docker image in service
.PHONY: docker.build
docker.build:
	$(call blue,"# Running docker build...")
	@docker build \
		--platform $(DOCKER_PLATFORM) \
		--build-context app=core/docker core/docker \
		-t $(DOCKER_IMAGE) \
		-f core/docker/Dockerfile

## docker.login: Login to ECR
.PHONY: docker.login
docker.login:
	@$(AWS) ecr get-login-password --region $(AWS_REGION) | \
		docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

## docker.push: Push an image to ECR
.PHONY: docker.push
docker.push:
	$(call blue,"# Running docker push...")
	@$(DOCKER) push $(DOCKER_IMAGE)

## artifacts.copy: Copy K6 scripts to the Artifact bucket
.PHONY: artifacts.copy
artifacts.copy:
	@$(AWS) s3 sync configs/$(TARGET_APP)/$(TARGET_ENV)/ s3://$(ARTIFACTS_BUCKET)/$(TARGET_APP)/$(TARGET_ENV)/ --exclude configs/env.json.j2

## assets.copy: Copy assets to the k6 reports web bucket
.PHONY: assets.copy
assets.copy:
	@$(PYTHON) -c '$(PYTHON_JINJA2)' < core/assets/index.html.j2 > core/assets/index.html
	@$(AWS) s3 sync core/assets s3://$(REPORTS_BUCKET) --exclude 'index.html.j2'

## load.run: Run the load testing
.PHONY: load.run
load.run: set-env
	$(call blue,"# Running load testing...")
	$(eval TASK_OVERRIDES := $(shell cat build/$(TARGET_APP).$(TARGET_ENV).json|sed -e 's/^ *//' | tr -d '\n'))
	@$(AWS) ecs run-task \
		--cluster $(ECS_CLUSTER) \
		--task-definition aws-load-testing \
		--overrides '$(TASK_OVERRIDES)' \
		--launch-type FARGATE \
		--network-configuration 'awsvpcConfiguration={subnets=[$(SUBNETS)]}' \
		--tags "[{\"key\":\"APPLICATION\",\"value\":\"$(TARGET_APP)\"},{\"key\":\"ENVIRONMENT\",\"value\":\"$(TARGET_ENV)\"}]" \
		--region=$(AWS_REGION) | $(JQ) -r .tasks[].taskArn

## help: prints this help message
.PHONY: help
help: Makefile
	@echo
	$(call blue, " Choose a command run:")
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

# -- Helper Functions --
define blue
	@tput setaf 4
	@echo $1
	@tput sgr0
endef
