#!/usr/bin/env bash
# Install runtime prerequisites for CASA dev builds on EL8-family systems
# (AlmaLinux 8, Rocky Linux 8, RHEL/UBI 8).
#
# EPEL is required for several packages (e.g. ImageMagick, xorg-x11-server-Xvfb).
# On AlmaLinux 8 and Rocky Linux 8 the epel-release RPM is available directly
# from the default package repositories.  On RHEL/UBI 8 that package is absent;
# we fall back to installing it via its upstream URL so the build does not fail.

set -euo pipefail

echo "==> Enabling EPEL repository..."
if ! dnf install -y epel-release; then
    echo "==> epel-release not found in repos; installing from upstream URL..."
    dnf install -y \
        "https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
fi

echo "==> Installing CASA runtime prerequisites..."
dnf install -y \
    mesa-libGL \
    glib2 \
    libnsl \
    xorg-x11-server-Xvfb \
    wget \
    which \
    xz \
    perl \
    git \
    ImageMagick

dnf clean all

echo "==> Prerequisites installed successfully."
