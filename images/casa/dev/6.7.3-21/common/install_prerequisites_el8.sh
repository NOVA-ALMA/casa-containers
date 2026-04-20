#!/usr/bin/env bash
# Install CASA6 build prerequisites for EL8 (RHEL 8 family) platforms.
#
# Covers the full "Install the software prerequisites" list from the CASA6
# Bitbucket documentation for RHEL-equivalent platforms.
#
# Environment variables:
#   DISTRO         - One of: alma8, rockylinux8, rh8  (default: rh8)
#   ENABLE_OPENMPI - Set to "true" to install OpenMPI (default: true)

set -euo pipefail

DISTRO="${DISTRO:-rh8}"
ENABLE_OPENMPI="${ENABLE_OPENMPI:-true}"

echo "==> Configuring extra repositories for ${DISTRO}..."

case "${DISTRO}" in
  alma8|rockylinux8)
    # EPEL provides wcslib-devel and other supplemental packages.
    dnf install -y epel-release
    ;;
  rh8)
    # On Red Hat UBI 8 there is no EPEL RPM in the UBI repos; install from
    # the Fedora project URL instead.  Failure is non-fatal: the build will
    # continue and wcslib-devel will emit a warning if unavailable.
    dnf install -y \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
      || echo "WARNING: EPEL install failed; wcslib-devel may not be available."
    ;;
  *)
    echo "WARNING: Unknown DISTRO='${DISTRO}'; skipping extra repo setup."
    ;;
esac

echo "==> Installing build toolchain (cmake, compilers, flex/bison, pkg-config, curl, tar)..."
dnf install -y \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    cmake \
    make \
    flex \
    bison \
    pkgconf-pkg-config \
    curl \
    tar \
    which \
    wget

echo "==> Installing library development headers..."
dnf install -y \
    readline-devel \
    ncurses-devel \
    blas-devel \
    lapack-devel \
    fftw-devel \
    libxml2-devel \
    libxslt-devel \
    gsl-devel \
    sqlite-devel \
    protobuf-devel \
    protobuf-compiler

echo "==> Installing wcslib-devel (EPEL)..."
dnf install -y wcslib-devel \
  || echo "WARNING: wcslib-devel not available in configured repos; \
build wcslib from source (https://www.atnf.csiro.au/people/mcalabre/WCS/) if required."

echo "==> Installing Python 3.8 and numpy..."
dnf install -y python38 python38-devel python38-pip
python3.8 -m pip install --no-cache-dir --upgrade pip
python3.8 -m pip install --no-cache-dir numpy

# gRPC C++ library is not packaged for EL8 in any standard repository.
# Install the Python gRPC bindings (grpcio + protobuf plugin) as a best-effort
# convenience.  For full C++ gRPC support (needed to compile CASA from source),
# build gRPC from source: https://grpc.io/docs/languages/cpp/quickstart/
echo "==> Installing gRPC Python bindings (best-effort; C++ gRPC must be built from source)..."
python3.8 -m pip install --no-cache-dir grpcio grpcio-tools \
  || echo "WARNING: gRPC Python bindings install failed."

if [[ "${ENABLE_OPENMPI}" == "true" ]]; then
    echo "==> Installing OpenMPI (optional)..."
    dnf install -y openmpi openmpi-devel
    # Make mpicc/mpif90/mpirun available in login shells.
    echo 'export PATH=/usr/lib64/openmpi/bin:${PATH}' \
        > /etc/profile.d/openmpi.sh
    echo 'export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:${LD_LIBRARY_PATH:-}' \
        >> /etc/profile.d/openmpi.sh
fi

echo "==> Cleaning up..."
dnf clean all

echo "==> CASA6 build prerequisites installed successfully for ${DISTRO}."
