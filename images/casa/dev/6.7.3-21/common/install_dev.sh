#!/usr/bin/env bash
# Install a CASA dev build from a pre-release tarball (.tar.xz).
#
# Tarball filename pattern:
#   casa-<X.Y.Z>-<build>-py<python>.el<os>.tar.xz
#
# Expected environment variables (with defaults):
#   CASA_VERSION     - CASA version (default: 6.7.3)
#   CASA_BUILD       - CASA build number (default: 21)
#   PYTHON_VERSION   - Python major.minor version bundled with CASA (default: 3.12)
#                      Must be major.minor only (e.g. "3.12"), not major.minor.patch.
#   PLATFORM         - Target OS tag, e.g. el8 or el9 (default: el8)
#   BASE_URL         - Base URL for downloading the tarball
#                      (default: https://casa.nrao.edu/download/distro/casa/releaseprep)

set -euo pipefail

CASA_VERSION="${CASA_VERSION:-6.7.3}"
CASA_BUILD="${CASA_BUILD:-21}"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
PLATFORM="${PLATFORM:-el8}"
BASE_URL="${BASE_URL:-https://casa.nrao.edu/download/distro/casa/releaseprep}"

CASA_PACKAGE="casa-${CASA_VERSION}-${CASA_BUILD}-py${PYTHON_VERSION}.${PLATFORM}.tar.xz"
DISTRO_URL="${BASE_URL}/${CASA_PACKAGE}"

echo "==> Downloading CASA dev ${CASA_VERSION}-${CASA_BUILD} for ${PLATFORM}..."
wget -nv "${DISTRO_URL}" -O "/tmp/${CASA_PACKAGE}"

echo "==> Installing CASA to /opt/casa..."
mkdir -p /opt/casa
tar -xJf "/tmp/${CASA_PACKAGE}" -C /opt/casa --strip-components=1
rm "/tmp/${CASA_PACKAGE}"

echo "==> Creating symlink /usr/local/bin/casa..."
ln -sf /opt/casa/bin/casa /usr/local/bin/casa

echo "==> CASA dev ${CASA_VERSION}-${CASA_BUILD} installed successfully."
