# Environment variables
SHELL := /bin/bash
.DEFAULT_GOAL := clean

# PYTHON
PYTHON_VERSION := 3.10

# PROJECT

# Project configuration files
PROJECT_CONFIG_FILE			= pyproject.toml
RUFF_CONFIG_FILE 			= ./config/ruff.toml
CHANGELOG_CONFIG_FILE		= ./config/git-changelog.toml
MKDOCS_CONFIG_FILE			= ./config/mkdocs.yml

# Project folders
SOURCE_DIR 					= src
DOCS_DIR 					= docs
SCRIPTS_DIR 				= scripts
TEST_DIR 					= tests
VENV_DIR  					= .venv

# TOOLS
PACKAGE_MANAGER 			= uv

## uv run
PACKAGE_MANAGER_RUN 		= ${PACKAGE_MANAGER} run

## Ruff linter
RUFF 						= ${PACKAGE_MANAGER_RUN} ruff --config $(RUFF_CONFIG_FILE)

## Pyright linter
PYRIGHT						= ${PACKAGE_MANAGER_RUN} pyright

.PHONY: check check-local clean install install-dev lint test build

check: clean lint test

check-local: clean
	@${RUFF} format ${SOURCE_DIR} ${SCRIPTS_DIR} ${TEST_DIR} ${DOCS_DIR} -v
	@${RUFF} check ${SOURCE_DIR} ${SCRIPTS_DIR} ${TEST_DIR} ${DOCS_DIR} -v --fix
	@${PRE-COMMIT-RUN-ALL-FILES}
	@make lint

.ONESHELL:
clean:
	@$(call do_print_header)
	@find . -type d -name "__pycache__" -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	@rm -rf .pytest_cache build dist *.egg-info .coverage coverage.xml
	@$(call do_print_footer)

.ONESHELL:
install:
	@$(call do_print_header)
	@echo "Configuring environment..."
	@echo "### Install Python"
	@${PACKAGE_MANAGER} python install ${PYTHON_VERSION}
	@echo "### Configure virtual environment"
	@${PACKAGE_MANAGER} venv ${VENV_DIR} --allow-existing --trusted-host localhost --color auto --python ${PYTHON_VERSION}
	@echo "### Install project dependencies"
	@echo ""
	@${PACKAGE_MANAGER} sync --link-mode=copy
	@echo ""
	@echo "...Environment configured!"
	@$(call do_print_footer)

install-dev:
	@$(call do_print_header)
	@make install
	@echo "### Install project dev dependencies"
	@echo ""
	@${PACKAGE_MANAGER_RUN} pre-commit install
	@${PACKAGE_MANAGER} sync --link-mode=copy --upgrade
	@echo "...DEV environment configured!"
	@$(call do_print_footer)

lint:
	@$(call do_print_header)
	@echo "Starting ruff check..."
	@echo ""
	@echo "SRC :: ${SOURCE_DIR}"
	@${RUFF} check ${SOURCE_DIR} ${SCRIPTS_DIR} ${TEST_DIR} ${DOCS_DIR}  -v
	@${PYRIGHT}
	@echo ""
	@echo "...ending ruff check!"
	@$(call do_print_footer)

test:
	@$(call do_print_header)
	@echo "Running unit tests..."
	@echo ""
	@PYTHONPATH=src ${PACKAGE_MANAGER_RUN} pytest -v -s --log-level=DEBUG --color=auto --code-highlight=yes --cov=${SOURCE_DIR} --cov-report=xml --cov-fail-under=80 --cov-report=term
	@echo ""
	@echo "...ending unit tests!"
	@$(call do_print_footer)

.ONESHELL:
build:
	@$(call do_print_header)
	@echo "Building project..."
	@echo ""
	@${PACKAGE_MANAGER} build
	@echo ""
	@echo "Creating latest file..."
	@cp dist/*.whl dist/python_base_project-latest.whl
	@echo ""
	@echo "Build completed successfully!"
	@$(call do_print_footer)

define do_print_header
	@echo ""
	@echo "Starting..."
	@echo "------------------------------------------------------------------"
	@echo ""
endef

define do_print_footer
	@echo ""
	@echo "... and done!"
	@echo "=================================================================="
	@echo ""
endef
