![Python Version](https://img.shields.io/badge/python-3.10_|_3.11_-blue?logo=python)

# Python Base Project

A professional foundation for Python projects with integrated linters, formatters, and development utilities.

## Overview

This project serves as a template repository for new Python projects, providing a standardized foundation with best practices for code quality, testing, and development workflows.

## Features

- Pre-configured linting and formatting
- Testing infrastructure
- GitHub Actions workflows for CI/CD
- Standardized project structure
- Development utilities and helpers

## Project Configuration

- **Python Version**: 3.11 (compatible with 3.10+)
- **Package Management**: [UV](https://docs.astral.sh/uv/)
- **Project Name**: python_base_project
- **Description**: A shared foundation for linters, formatters, and general utilities in Python projects

## Development Tools

### Linters & Formatters

- [Ruff](https://docs.astral.sh/ruff/) - Fast Python linter and formatter
- [Pyright](https://github.com/microsoft/pyright) - Static type checker for Python

### Testing

- [PyTest](https://docs.pytest.org/en/stable/) - Testing framework with coverage reporting

## Getting Started

### Using This Template

1. Click the "Use this template" button on the GitHub repository
2. Name your new repository and create it
3. Clone your new repository locally
4. Install dependencies using the Makefile

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/your-project.git
cd your-project

# Install dependencies and configure development environment
make local-dev-config
```

### Using the Makefile

This project includes a comprehensive Makefile to streamline development tasks. Here are the key commands:

#### Development Setup

```bash
# Configure development environment (installs Python, dependencies, and sets up pre-commit hooks)
make local-dev-config

# Install dependencies only
make install
```

#### Code Quality

```bash
# Format code using Ruff
make format

# Run linters (Ruff and Pyright)
make lint

# Run tests with coverage
make test

# Run format, lint, and test in sequence
make check

# Clean project artifacts
make clean

# Build the project and create version and latest files
make build
```

#### Documentation

```bash
# Generate documentation for GitHub Pages
make generate-docs

# Generate documentation locally for testing
make generate-docs-local
```

#### Project Management

```bash
# Generate changelog from git history
make changelog-generate

# Preview changelog without writing to file
make changelog-preview
```

#### Release Management

```bash
# Create a release with a patch version bump (e.g., 1.0.0 → 1.0.1)
make release-patch

# Create a release with a minor version bump (e.g., 1.0.0 → 1.1.0)
make release-minor

# Create a release with a major version bump (e.g., 1.0.0 → 2.0.0)
make release-major
```

For a complete list of available commands, run:

```bash
make help
```

## Development Workflow

This project uses a streamlined development workflow:

1. **Feature Development**: Develop features in separate branches. The Branch Validation workflow automatically validates all pushes to non-main branches.

2. **Pull Request & Auto-merge**: Create a pull request to merge your feature into main. The validate-and-merge workflow will:
   - Automatically validate the changes (linting, testing)
   - Auto-merge the PR if it:
     - Passes all validation checks
     - Has the `ready-to-merge` label (and doesn't have the `work-in-progress` label)
     - Has at least one approval
   
3. **Manual Release**: After changes are merged to main, a release is manually triggered.

## Release Process

### How to Release

To create a new release:

1. Ensure all desired changes have been merged into the main branch
2. Go to the GitHub repository's "Actions" tab
3. Select the "Manual Release" workflow
4. Click "Run workflow"
5. Select the desired version bump type:
   - **major**: For breaking changes (e.g., 1.0.0 → 2.0.0)
   - **minor**: For new features (e.g., 1.0.0 → 1.1.0)
   - **patch**: For bug fixes (e.g., 1.0.0 → 1.0.1)
6. Optionally, select "Build and upload wheel files to S3" if you want to:
   - Build the project after the release process
   - Upload the wheel files to the configured S3 bucket
7. Click "Run workflow" to start the release process

The release process will:
- Run tests to ensure the code is in a releasable state
- Bump the version according to the selected type
- Create a git tag for the new version
- Generate the changelog
- Push the changes and tags to GitHub
- Optionally build and upload wheel files to S3 (if selected)

This two-step process ensures that version tags are properly created and that the changelog correctly categorizes changes under the appropriate version instead of keeping them under "Unreleased".