#!/usr/bin/env bash
# Install CASA 6.6.5 from the NRAO distribution.
#
# Expected environment variables (with defaults):
#   CASA_VERSION     - CASA version (default: 6.6.5)
#   CASA_BUILD       - CASA build number (default: 4)
#   PYTHON_VERSION   - Python major.minor version bundled with CASA (default: 3.8)
#                      Must be major.minor only (e.g. "3.8"), not major.minor.patch.
#   PLATFORM         - Target OS tag, e.g. el8 or el9 (default: el8)

set -euo pipefail

CASA_VERSION="${CASA_VERSION:-6.6.5}"
CASA_BUILD="${CASA_BUILD:-4}"
PYTHON_VERSION="${PYTHON_VERSION:-3.8}"
PLATFORM="${PLATFORM:-el8}"

CASA_PACKAGE="casa-${CASA_VERSION}-${CASA_BUILD}-py${PYTHON_VERSION}.${PLATFORM}.tar.gz"
BASE_URL="https://casa.nrao.edu/download/distro/casa/release"

case "${PLATFORM}" in
  el8) DISTRO_URL="${BASE_URL}/rhel8/${CASA_PACKAGE}" ;;
  el9) DISTRO_URL="${BASE_URL}/rhel9/${CASA_PACKAGE}" ;;
  *)
    echo "Error: unsupported platform '${PLATFORM}'. Must be el8 or el9."
    exit 1
    ;;
esac

echo "==> Downloading CASA ${CASA_VERSION}-${CASA_BUILD} for ${PLATFORM}..."
wget -nv "${DISTRO_URL}" -O "/tmp/${CASA_PACKAGE}"

echo "==> Installing CASA to /opt/casa..."
mkdir -p /opt/casa
tar -xzf "/tmp/${CASA_PACKAGE}" -C /opt/casa --strip-components=1
rm "/tmp/${CASA_PACKAGE}"

echo "==> Creating symlink /usr/local/bin/casa..."
ln -sf /opt/casa/bin/casa /usr/local/bin/casa

echo "==> CASA ${CASA_VERSION}-${CASA_BUILD} installed successfully."
