#!/usr/bin/env bash
# Install CASA6 build prerequisites for EL8 (RHEL 8 family) platforms.
#
# Environment variables:
#   DISTRO          - One of: alma8, rockylinux8, rh8  (default: rh8)
#   STRICT_PREREQS  - Set to "true" to fail if any best-effort packages are
#                     unavailable (default: false).  Useful when building in
#                     an entitled RHEL environment.
#
# NOTE – Temporarily skipped prerequisites:
#   The casacore development prerequisites (git, cmake, gcc-c++, gcc-gfortran,
#   gtest-devel, ccache, readline-devel, ncurses-devel, blas-devel, lapack-devel,
#   cfitsio-devel, fftw-devel, wcslib-devel, python38, python38-devel,
#   python38-numpy, flex, bison, tar, curl) and the libsakura development
#   prerequisites (eigen3-devel, fftw-devel) are temporarily NOT installed.
#   This prevents build failures on platforms where these packages are not
#   consistently available (e.g. UBI 8 / rh8).
#   Re-enable once a reliable installation strategy is in place.
#
#   The CASA-hosted protobuf/gRPC RPMs are still installed on a best-effort
#   basis from https://casa.nrao.edu/download/devel/grpc/el8-1.18/
#
# NOTE – rh8 (UBI 8) limitations:
#   Red Hat Universal Base Image 8 only exposes the BaseOS and AppStream repos
#   publicly.  Several CASA build prerequisites (e.g. flex, bison) live in the
#   CodeReady Builder / PowerTools repo, which requires a RHEL subscription and
#   is NOT available in public UBI builds.
#   For a complete, hassle-free dev environment use the alma8 or rockylinux8
#   dev images instead:
#     ghcr.io/nova-alma/casa-dev-alma8:<version>
#     ghcr.io/nova-alma/casa-dev-rockylinux8:<version>

set -euo pipefail

DISTRO="${DISTRO:-rh8}"
STRICT_PREREQS="${STRICT_PREREQS:-false}"

# Helper: install packages or URLs that may not be available in all repos.
# On failure, print a warning and either continue or exit depending on
# STRICT_PREREQS.
install_best_effort() {
    local pkgs=("$@")
    if dnf install -y "${pkgs[@]}"; then
        return 0
    fi

    echo ""
    echo "##################################################################"
    echo "WARNING: One or more best-effort packages could not be installed:"
    echo "  ${pkgs[*]}"
    echo "##################################################################"
    echo ""

    if [[ "${STRICT_PREREQS}" == "true" ]]; then
        echo "ERROR: STRICT_PREREQS=true – aborting due to missing packages."
        exit 1
    fi
}

# ── EPEL ─────────────────────────────────────────────────────────────────────
# EPEL is required for packages such as ImageMagick and xorg-x11-server-Xvfb.
# On AlmaLinux 8 and Rocky Linux 8 epel-release is available in the default
# repos.  On RHEL/UBI 8 it is absent; fall back to the upstream RPM URL.
echo "==> Enabling EPEL repository..."
if ! dnf install -y epel-release; then
    echo "==> epel-release not in repos; installing from upstream URL..."
    dnf install -y \
        "https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
fi

# ── CASA runtime prerequisites ───────────────────────────────────────────────
echo "==> Installing CASA runtime prerequisites..."

# Core packages that are expected to be available on all EL8 variants.
dnf install -y \
    mesa-libGL \
    glib2 \
    wget \
    which \
    xz \
    perl \
    git \
    ImageMagick

# Packages that are unavailable on UBI8 without RHEL entitlements:
#   libnsl          – in BaseOS on Alma/Rocky but absent from public UBI repos
#   xorg-x11-server-Xvfb – in EPEL, but EPEL may not resolve on unregistered UBI
# For rh8 (UBI8): install best-effort so the build warns rather than fails.
# For alma8/rockylinux8: install strictly (these repos carry the packages).
if [[ "${DISTRO}" == "rh8" ]]; then
    echo "==> NOTE: rh8 (UBI8) may not provide all runtime packages without"
    echo "    RHEL entitlements.  Installing libnsl and xorg-x11-server-Xvfb"
    echo "    best-effort (set STRICT_PREREQS=true to fail on missing packages)."
    echo "    For full support, use the alma8 or rockylinux8 dev images:"
    echo "      ghcr.io/nova-alma/casa-dev-alma8:<version>"
    echo "      ghcr.io/nova-alma/casa-dev-rockylinux8:<version>"
    install_best_effort libnsl xorg-x11-server-Xvfb
else
    # Alma/Rocky carry these packages; keep strict failure so regressions
    # are caught immediately.
    dnf install -y libnsl xorg-x11-server-Xvfb
fi

# ── casacore / libsakura prerequisites (TEMPORARILY SKIPPED) ────────────────
# The following package groups are temporarily not installed to avoid build
# failures where packages are unavailable (especially on UBI 8 / rh8):
#
#   casacore development:
#     git cmake gcc-c++ gcc-gfortran gtest-devel ccache readline-devel
#     ncurses-devel blas-devel lapack-devel cfitsio-devel fftw-devel
#     wcslib-devel python38 python38-devel python38-numpy flex bison tar curl
#
#   libsakura development:
#     eigen3-devel fftw-devel
#
# Re-enable once a reliable installation strategy is in place for all
# supported platforms (especially UBI 8).
echo "==> NOTE: casacore/libsakura prerequisite RPM installs are temporarily skipped."
echo "    For full CASA development prerequisites, use alma8 or rockylinux8 dev images:"
echo "      ghcr.io/nova-alma/casa-dev-alma8:<version>"
echo "      ghcr.io/nova-alma/casa-dev-rockylinux8:<version>"

# ── CASA-hosted protobuf/gRPC RPMs ──────────────────────────────────────────
# These RPMs are distributed by CASA from casa.nrao.edu and are required for
# CASA development.  Installed on a best-effort basis; if unavailable (e.g.
# network issues or URL changes), a warning is printed but the build continues
# unless STRICT_PREREQS=true.
echo "==> Installing CASA-hosted protobuf/gRPC RPMs (best-effort)..."
install_best_effort \
    https://casa.nrao.edu/download/devel/grpc/el8-1.18/protobuf-3.6.1-3.el8.x86_64.rpm \
    https://casa.nrao.edu/download/devel/grpc/el8-1.18/protobuf-compiler-3.6.1-3.el8.x86_64.rpm \
    https://casa.nrao.edu/download/devel/grpc/el8-1.18/protobuf-devel-3.6.1-3.el8.x86_64.rpm \
    https://casa.nrao.edu/download/devel/grpc/el8-1.18/grpc-1.18.0-2.el8.x86_64.rpm \
    https://casa.nrao.edu/download/devel/grpc/el8-1.18/grpc-devel-1.18.0-2.el8.x86_64.rpm \
    https://casa.nrao.edu/download/devel/grpc/el8-1.18/grpc-plugins-1.18.0-2.el8.x86_64.rpm

echo "==> Cleaning up..."
dnf clean all

echo "==> EL8 prerequisite install complete for ${DISTRO}."
if [[ "${DISTRO}" == "rh8" ]]; then
    echo ""
    echo "NOTE: This is an rh8 (UBI 8) image.  casacore/libsakura prerequisites"
    echo "are temporarily skipped.  See the README for details and alternatives."
fi
