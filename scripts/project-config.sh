#!/bin/bash

# Exit on any error
set -e

echo "Installing Jinja2..."

# Install Jinja2
pip install jinja2

echo "Jinja2 installed successfully!"

# Run the Python script
SCRIPT_NAME=".project-template/jinja_config_project.py"

if [ -f "$SCRIPT_NAME" ]; then
    echo "Running Python script: $SCRIPT_NAME"
    python3 "$SCRIPT_NAME"
else
    echo "Python script '$SCRIPT_NAME' not found!"
    exit 1
fi

git rm --cached ./scripts/project-config.sh
git rm --cached -r .project-template
mv project-config.yaml .project-template/project-config.yaml

git add . \
  && git commit -m "chore: Removing track from template files and folder" \
  && git push

echo "To remove the template files, run:"
echo "rm -rf .project-template"
echo "rm ./scripts/project-config.sh"
