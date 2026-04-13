#!/usr/bin/env bash
# Install the ALMA pipeline-enabled CASA distribution.
#
# Expected environment variables (with defaults):
#   CASA_VERSION     - Full pipeline version string (default: 6.6.6-18)
#   PLATFORM         - Target OS tag (default: el8)
#
# The ALMA pipeline package bundles CASA + pipeline tasks and is distributed
# separately from the standard NRAO CASA release.

set -euo pipefail

CASA_VERSION="${CASA_VERSION:-6.6.6-18}"
PLATFORM="${PLATFORM:-el8}"

# Derive the CASA base version and pipeline build number from the version string
# e.g. "6.6.6-18" → CASA_BASE="6.6.6", PIPELINE_BUILD="18"
CASA_BASE="${CASA_VERSION%-*}"
PIPELINE_BUILD="${CASA_VERSION##*-}"

CASA_PACKAGE="casa-${CASA_BASE}-${PIPELINE_BUILD}-py3.8.${PLATFORM}.tar.gz"
PIPELINE_PACKAGE="pipeline-${CASA_VERSION}.${PLATFORM}.tar.gz"

BASE_URL="https://almascience.eso.org/pub/software/pipeline"
DISTRO_URL="${BASE_URL}/${CASA_VERSION}/${CASA_PACKAGE}"

echo "==> Downloading ALMA pipeline CASA ${CASA_VERSION} for ${PLATFORM}..."
wget -nv "${DISTRO_URL}" -O "/tmp/${CASA_PACKAGE}"

echo "==> Installing ALMA pipeline CASA to /opt/casa..."
mkdir -p /opt/casa
tar -xzf "/tmp/${CASA_PACKAGE}" -C /opt/casa --strip-components=1
rm "/tmp/${CASA_PACKAGE}"

echo "==> Creating symlink /usr/local/bin/casa..."
ln -sf /opt/casa/bin/casa /usr/local/bin/casa

echo "==> ALMA pipeline CASA ${CASA_VERSION} installed successfully."
