#!/bin/sh

# Set the base URL for the release
BASE_URL=https://casa.nrao.edu/download/distro/casa/releaseprep

# Update CASA_PACKAGE to end with .tar.xz
CASA_PACKAGE="casa-6.7.3-20-py3.12.el8.tar.xz"

# Construct DISTRO_URL
DISTRO_URL="${BASE_URL}/${CASA_PACKAGE}"

# Download the package
wget ${DISTRO_URL}

# Extract the package
# Use tar to extract the downloaded archive
if [ -f "${CASA_PACKAGE}" ]; then
    tar -xJf ${CASA_PACKAGE} -C /opt/casa
else
    echo "Package was not found!"
    exit 1
fi

# Symlink /usr/local/bin/casa
ln -s /opt/casa/casa /usr/local/bin/casa
