#!/usr/bin/env bash
# Install the CASA dev/pre-release build 6.7.3-21 from the NRAO distribution.
#
# Expected environment variables (with defaults):
#   CASA_VERSION     - CASA version string (default: 6.7.3-21)
#   PYTHON_VERSION   - Python major.minor version bundled with CASA (default: 3.12)
#                      Must be major.minor only (e.g. "3.12"), not major.minor.patch.
#   PLATFORM         - Target OS tag, e.g. el8 or el9 (default: el8)

set -euo pipefail

CASA_VERSION="${CASA_VERSION:-6.7.3-21}"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
PLATFORM="${PLATFORM:-el8}"

# Validate that PYTHON_VERSION is in major.minor format (e.g. "3.12"), not "3.12.1"
if [[ ! "${PYTHON_VERSION}" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "Error: PYTHON_VERSION must be in major.minor format (e.g. '3.12'), got '${PYTHON_VERSION}'."
    exit 1
fi

CASA_PACKAGE="casa-${CASA_VERSION}-py${PYTHON_VERSION}.${PLATFORM}.tar.xz"
BASE_URL="https://casa.nrao.edu/download/distro/casa/releaseprep"
DISTRO_URL="${BASE_URL}/${CASA_PACKAGE}"

echo "==> Downloading CASA dev ${CASA_VERSION} for ${PLATFORM}..."
wget -nv "${DISTRO_URL}" -O "/tmp/${CASA_PACKAGE}"

echo "==> Installing CASA to /opt/casa..."
mkdir -p /opt/casa
tar -xJf "/tmp/${CASA_PACKAGE}" -C /opt/casa --strip-components=1
rm "/tmp/${CASA_PACKAGE}"

echo "==> Creating symlink /usr/local/bin/casa..."
ln -sf /opt/casa/bin/casa /usr/local/bin/casa

echo "==> CASA dev ${CASA_VERSION} installed successfully."
