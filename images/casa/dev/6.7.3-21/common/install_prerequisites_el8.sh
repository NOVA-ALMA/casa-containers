#!/usr/bin/env bash
# Install CASA6 build prerequisites for EL8 (RHEL 8 family) platforms.
#
# Covers the full "Install the software prerequisites" list from the CASA6
# Bitbucket documentation for RHEL-equivalent platforms.
#
# Environment variables:
#   DISTRO          - One of: alma8, rockylinux8, rh8  (default: rh8)
#   ENABLE_OPENMPI  - Set to "true" to install OpenMPI (default: true)
#   STRICT_PREREQS  - Set to "true" to fail if any best-effort packages are
#                     unavailable (default: false).  Useful when building in
#                     an entitled RHEL environment.
#
# NOTE – rh8 (UBI 8) limitations:
#   Red Hat Universal Base Image 8 only exposes the BaseOS and AppStream repos
#   publicly.  Several CASA build prerequisites (e.g. flex, bison) live in the
#   CodeReady Builder / PowerTools repo, which requires a RHEL subscription and
#   is NOT available in public UBI builds.  Those packages are installed on a
#   best-effort basis and will emit a warning rather than a hard failure unless
#   STRICT_PREREQS=true.
#   For a complete, hassle-free dev environment use the alma8 or rockylinux8
#   dev images instead:
#     ghcr.io/nova-alma/casa-dev-alma8:<version>
#     ghcr.io/nova-alma/casa-dev-rockylinux8:<version>

set -euo pipefail

DISTRO="${DISTRO:-rh8}"
ENABLE_OPENMPI="${ENABLE_OPENMPI:-true}"
STRICT_PREREQS="${STRICT_PREREQS:-false}"

# Helper: install packages that may not be available in all repos.
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
    echo ""
    if [[ "${DISTRO}" == "rh8" ]]; then
        echo "  This is expected on UBI 8 (rh8): packages such as flex and"
        echo "  bison are only available from the CodeReady Builder repo,"
        echo "  which requires a RHEL subscription not present in public UBI."
        echo ""
        echo "  For a complete CASA build-prerequisite environment use:"
        echo "    ghcr.io/nova-alma/casa-dev-alma8:<version>"
        echo "    ghcr.io/nova-alma/casa-dev-rockylinux8:<version>"
        echo ""
        echo "  If you have RHEL entitlements, re-run with STRICT_PREREQS=true"
        echo "  after enabling the CodeReady Builder repo so any missing"
        echo "  package causes a hard build failure."
    fi
    echo "##################################################################"
    echo ""

    if [[ "${STRICT_PREREQS}" == "true" ]]; then
        echo "ERROR: STRICT_PREREQS=true – aborting due to missing packages."
        exit 1
    fi
}

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

# ── Core toolchain ──────────────────────────────────────────────────────────
# These packages are available in the UBI 8 BaseOS/AppStream repos and are
# installed unconditionally on all EL8 platforms.
echo "==> Installing core build toolchain (compilers, cmake, pkg-config, curl, tar)..."
dnf install -y \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    cmake \
    make \
    pkgconf-pkg-config \
    curl \
    tar \
    which \
    wget

# ── Best-effort toolchain ────────────────────────────────────────────────────
# flex and bison live in CodeReady Builder on RHEL 8 (not exposed by UBI).
# On alma8/rockylinux8 (EPEL+PowerTools) they are available without issue.
echo "==> Installing best-effort toolchain packages (flex, bison)..."
install_best_effort flex bison

# ── Library development headers ─────────────────────────────────────────────
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
install_best_effort wcslib-devel

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

echo "==> CASA6 build prerequisites install complete for ${DISTRO}."
if [[ "${DISTRO}" == "rh8" ]]; then
    echo ""
    echo "NOTE: This is an rh8 (UBI 8) image.  Some build prerequisites"
    echo "(e.g. flex, bison) may not have been installed due to UBI repo"
    echo "restrictions.  See the README for details and alternatives."
fi
