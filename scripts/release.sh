#!/usr/bin/env bash
set -euo pipefail

# Autonomous release script
# Usage: scripts/release.sh [major|minor|patch]
# - Computes current version (using uv), bumps semver, updates pyproject.toml
# - Commits the change, generates changelog, tags and pushes

BUMP_TYPE="${1:-}"
if [[ -z "${BUMP_TYPE}" ]]; then
  echo "Usage: $0 [major|minor|patch]" >&2
  exit 1
fi
if [[ "${BUMP_TYPE}" != "major" && "${BUMP_TYPE}" != "minor" && "${BUMP_TYPE}" != "patch" ]]; then
  echo "Invalid bump type: ${BUMP_TYPE}. Use one of: major, minor, patch" >&2
  exit 1
fi

PROJECT_CONFIG_FILE="pyproject.toml"
PACKAGE_MANAGER="uv"

if ! command -v "${PACKAGE_MANAGER}" >/dev/null 2>&1; then
  echo "${PACKAGE_MANAGER} is not installed or not in PATH. Aborting release." >&2
  exit 1
fi

echo ""
echo "Bumping ${BUMP_TYPE} version..."
# Get current version using uv, per project convention
CURRENT_VERSION="$(${PACKAGE_MANAGER} version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" || true
if [[ -z "${CURRENT_VERSION}" ]]; then
  echo "Could not find current version in ${PROJECT_CONFIG_FILE}. Aborting release." >&2
  exit 1
fi

echo "Current version: ${CURRENT_VERSION}"
IFS='.' read -r MAJOR MINOR PATCH <<< "${CURRENT_VERSION}"

if [[ "${BUMP_TYPE}" == "major" ]]; then
  NEW_RELEASE_VERSION="$((MAJOR + 1)).0.0"
elif [[ "${BUMP_TYPE}" == "minor" ]]; then
  NEW_RELEASE_VERSION="${MAJOR}.$((MINOR + 1)).0"
else
  NEW_RELEASE_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
fi

echo "New version: ${NEW_RELEASE_VERSION}"
# Update the version in pyproject.toml preserving indentation/spacing
sed -i.bak -E "s/^([[:space:]]*version[[:space:]]*=[[:space:]]*\")[0-9]+\.[0-9]+\.[0-9]+(\")/\1${NEW_RELEASE_VERSION}\2/" "${PROJECT_CONFIG_FILE}" || {
  echo "Version bump write failed! Aborting release." >&2
  exit 1
}
rm -f "${PROJECT_CONFIG_FILE}.bak"
echo "Updated ${PROJECT_CONFIG_FILE} with new version ${NEW_RELEASE_VERSION}"

echo "Creating temporary commit for version bump..."
 git add "${PROJECT_CONFIG_FILE}" || { echo "Git add failed! Aborting release." >&2; exit 1; }
 git commit --no-verify -m "build(release): bump version to ${NEW_RELEASE_VERSION}" || { echo "Git commit failed! Aborting release." >&2; exit 1; }

echo "Generating changelog with version ${NEW_RELEASE_VERSION}..."
${PACKAGE_MANAGER} run git-changelog --style conventional --output CHANGELOG.md -B "${NEW_RELEASE_VERSION}" || { echo "Changelog generation failed! Aborting release." >&2; exit 1; }

echo "Committing changelog..."
 git add CHANGELOG.md || { echo "Git add failed! Aborting release." >&2; exit 1; }
 git commit --amend --no-verify -m "build(release): bump version to ${NEW_RELEASE_VERSION} and generate changelog" || { echo "Git commit failed! Aborting release." >&2; exit 1; }

echo "Creating version tag..."
 git tag -f "v${NEW_RELEASE_VERSION}" || { echo "Git tag failed! Aborting release." >&2; exit 1; }
 git tag -f latest || { echo "Git tag latest failed! Aborting release." >&2; exit 1; }

echo "Pushing changes and tags..."
 git push origin main || { echo "Git push failed! Aborting release." >&2; exit 1; }

echo "Pushing tags..."
 git push origin "v${NEW_RELEASE_VERSION}" --force || { echo "Git push version tag failed! Aborting release." >&2; exit 1; }
 git push origin latest --force || { echo "Git push latest tag failed! Aborting release." >&2; exit 1; }

echo ""
echo "...ending release!"
