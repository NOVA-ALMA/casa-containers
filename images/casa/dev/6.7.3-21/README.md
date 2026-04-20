# CASA Dev Images – 6.7.3-21 (EL8)

Development container images for CASA **6.7.3 build 21** targeting EL8
(Enterprise Linux 8) platforms.  These images are intentionally larger than
the runtime images: they bundle the full upstream CASA6 build-prerequisite
toolchain so that developers can both run pre-release CASA builds *and* compile
CASA/casacore/libsakura from source inside a consistent environment.

## Available platforms

| Platform tag | Base image | Notes |
|---|---|---|
| `alma8` | `almalinux:8` | AlmaLinux 8 |
| `rockylinux8` | `rockylinux:8` | Rocky Linux 8 |
| `rh8` | `registry.access.redhat.com/ubi8/ubi` | True RHEL 8 (UBI 8 standard) |

### Why UBI 8 standard for `rh8`?

Red Hat Universal Base Image 8 (UBI 8) is the only freely redistributable
RHEL 8 base.  The **standard** variant (`ubi8/ubi`) is chosen over
`ubi8/ubi-minimal` because:
- It ships `dnf` (full package manager), which is required to install the
  large set of `*-devel` packages needed for the CASA6 build.
- It avoids the `microdnf` limitations of the minimal image (fewer
  installable packages, less stable dependency resolution for complex stacks).

Runtime images can use `ubi8/ubi-minimal` for a smaller footprint; dev images
prioritise completeness.

## Image tags

```
ghcr.io/nova-alma/casa-dev-alma8:6.7.3-21
ghcr.io/nova-alma/casa-dev-rockylinux8:6.7.3-21
ghcr.io/nova-alma/casa-dev-rh8:6.7.3-21
```

## Installed build prerequisites

The following packages are installed in all EL8 dev images, matching the
[CASA6 "Install the software prerequisites"](https://open-bitbucket.nrao.edu/projects/CASA/repos/casa6/browse)
section for RHEL-equivalent platforms:

### Build toolchain

| Prerequisite | RPM package(s) | rh8 (UBI 8) availability |
|---|---|---|
| C++ compiler (gcc ≥ 4.9) | `gcc`, `gcc-c++` | ✅ Available |
| Fortran compiler | `gcc-gfortran` | ✅ Available |
| cmake | `cmake` | ✅ Available |
| flex | `flex` | ⚠️ Best-effort (CRB required on UBI) |
| bison | `bison` | ⚠️ Best-effort (CRB required on UBI) |
| pkg-config | `pkgconf-pkg-config` | ✅ Available |
| curl | `curl` | ✅ Available |
| tar | `tar` | ✅ Available |

### Library development headers

| Prerequisite | RPM package(s) | Source repo |
|---|---|---|
| readline | `readline-devel` | BaseOS / AppStream |
| ncurses | `ncurses-devel` | BaseOS |
| blas | `blas-devel` | AppStream |
| lapack | `lapack-devel` | AppStream |
| fftw3 | `fftw-devel` | AppStream |
| libxml | `libxml2-devel` | BaseOS |
| libxslt | `libxslt-devel` | AppStream |
| gsl | `gsl-devel` | AppStream |
| sqlite | `sqlite-devel` | AppStream |
| protobuf + protoc | `protobuf-devel`, `protobuf-compiler` | AppStream |
| wcslib | `wcslib-devel` | **EPEL 8** |

### Python

| Prerequisite | Installed via |
|---|---|
| python3.8 | `python38`, `python38-devel`, `python38-pip` (AppStream) |
| numpy | `pip install numpy` |

Python 3.8 is the recommended build-Python for EL8 as per the CASA6 docs
(supported versions: 3.8 and 3.10).  Python 3.12 is bundled inside the
pre-built CASA tarball and does not conflict.

### gRPC

`grpc-devel` is **not available** in any EL8 repository (base, AppStream,
EPEL, or PowerTools/CRB).  As a best-effort convenience the Python bindings
are installed:

```
pip install grpcio grpcio-tools
```

For a full C++ gRPC installation (required to compile CASA from source),
build gRPC from source using cmake.  See:
https://grpc.io/docs/languages/cpp/quickstart/

### Optional: OpenMPI

OpenMPI is installed by default (`openmpi`, `openmpi-devel` from AppStream).
To skip MPI, pass `--build-arg ENABLE_OPENMPI=false` at build time.

When OpenMPI is installed, `/etc/profile.d/openmpi.sh` adds the MPI binaries
and libraries to `PATH` / `LD_LIBRARY_PATH` for login shells:

```
/usr/lib64/openmpi/bin  (mpicc, mpif90, mpirun, …)
/usr/lib64/openmpi/lib
```

### GPU build prerequisites (optional, not installed by default)

For the in-progress GPU build:
- C++ compiler gcc 9+ (gcc 8 is the EL8 default; install `gcc-toolset-9` or
  later via Software Collections if gcc 9+ is required)
- CUDA + cuFFT (requires NVIDIA CUDA repo)
- ATLAS (`atlas-devel`)
- Kokkos (`libkokkosscore` – build from source)

These are **not** installed in the standard dev images.  Build a custom layer
on top if GPU support is needed.

## Repository enablement

| Platform | Extra repos enabled |
|---|---|
| `alma8` | EPEL 8 (`epel-release`) |
| `rockylinux8` | EPEL 8 (`epel-release`) |
| `rh8` | EPEL 8 (from `dl.fedoraproject.org`) |

## rh8 dev image limitations (UBI 8)

The `rh8` dev image is based on **Red Hat Universal Base Image 8 (UBI 8)**,
which is the only freely redistributable RHEL 8 base.  UBI 8 only exposes
the **BaseOS** and **AppStream** repositories publicly.  Several CASA build
prerequisites—notably `flex` and `bison`—live in the
**CodeReady Builder (CRB)** repository, which requires an active RHEL
subscription and is **not** available in public UBI builds.

### What this means in practice

| Package | Available on UBI 8 (public)? | Available on Alma/Rocky 8? |
|---|---|---|
| gcc, cmake, pkg-config, curl | ✅ Yes | ✅ Yes |
| flex, bison | ⚠️ **No** (CRB/entitlement required) | ✅ Yes |
| wcslib-devel | ⚠️ Best-effort via EPEL | ✅ Yes (EPEL) |

When `./ci/scripts/build.sh dev rh8 6.7.3-21` encounters a missing package it
will print a clear warning and **continue** (non-fatal) rather than aborting
the build.  The resulting image may be incomplete for CASA source builds.

### Recommended alternatives for full development builds

For a complete CASA-from-source environment, use the **alma8** or
**rockylinux8** dev images:

```bash
# Pull the AlmaLinux 8 dev image
docker pull ghcr.io/nova-alma/casa-dev-alma8:6.7.3-21

# Pull the Rocky Linux 8 dev image
docker pull ghcr.io/nova-alma/casa-dev-rockylinux8:6.7.3-21
```

These images enable EPEL 8 and have all CASA6 build prerequisites (including
`flex`, `bison`, and `wcslib-devel`) installed without any subscription.

### When rh8 (UBI 8) is the right choice

The `rh8` image is the **redistributable** RHEL 8 base.  Use it when:
- You need a runtime container that can run on entitled RHEL 8 systems.
- You are building CASA in an **entitled RHEL environment** (add
  `--subscription-manager` or mount entitlements, then set
  `STRICT_PREREQS=true` to get hard failures on any missing package).
- You want a redistributable image that customers/users can run without an
  AlmaLinux or Rocky Linux base.

For pure development/compilation work without RHEL entitlements, always prefer
`alma8` or `rockylinux8`.

### STRICT_PREREQS mode

To treat missing best-effort packages as hard failures (useful in entitled
RHEL CI pipelines), pass `STRICT_PREREQS=true` at build time:

```bash
docker build \
  --build-arg DISTRO=rh8 \
  --build-arg STRICT_PREREQS=true \
  -f images/casa/dev/6.7.3-21/rh8/Dockerfile \
  images/casa/dev/6.7.3-21
```

## Note: dev vs runtime images

> Dev images intentionally include the **full build-prerequisite toolchain**
> (compilers, CMake, `*-devel` headers, Python dev files, etc.).  Runtime
> images (`casa-base:*`) remain minimal – they carry only the X11/GL/font
> dependencies needed to run CASA GUIs or headless jobs.  Keep runtime images
> lean; use dev images when you need to compile code.
