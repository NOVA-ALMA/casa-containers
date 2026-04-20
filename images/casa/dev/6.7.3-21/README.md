# CASA Dev Images – 6.7.3-21 (EL8)

Development container images for CASA **6.7.3 build 21** targeting EL8
(Enterprise Linux 8) platforms.

> **⚠️ Temporary change:** The casacore and libsakura development prerequisite
> packages are **temporarily skipped** in these images to avoid build failures
> (especially on UBI 8 / rh8 where many packages are unavailable without RHEL
> entitlements).  Only the CASA-hosted protobuf/gRPC RPMs are installed.
> See [Temporarily Skipped Prerequisites](#temporarily-skipped-prerequisites) below.

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

### Temporarily skipped prerequisites

The following package groups are **temporarily not installed** to avoid build
failures on platforms where these packages are unavailable (especially UBI 8):

**casacore development:**
```
git cmake gcc-c++ gcc-gfortran gtest-devel ccache
readline-devel ncurses-devel blas-devel lapack-devel cfitsio-devel
fftw-devel wcslib-devel python38 python38-devel python38-numpy
flex bison tar curl
```

**libsakura development:**
```
eigen3-devel fftw-devel
```

These will be re-enabled once a reliable installation strategy is in place
for all supported platforms.  For full CASA-from-source development
prerequisites, use the **alma8** or **rockylinux8** dev images.

### CASA-hosted protobuf/gRPC RPMs

The following RPMs are distributed by CASA from `casa.nrao.edu` and are
installed on a **best-effort** basis.  If they are unavailable (e.g. due to
network issues or URL changes), a warning is printed but the build continues
unless `STRICT_PREREQS=true`.

| Package | URL |
|---|---|
| `protobuf-3.6.1` | `https://casa.nrao.edu/download/devel/grpc/el8-1.18/protobuf-3.6.1-3.el8.x86_64.rpm` |
| `protobuf-compiler-3.6.1` | `https://casa.nrao.edu/download/devel/grpc/el8-1.18/protobuf-compiler-3.6.1-3.el8.x86_64.rpm` |
| `protobuf-devel-3.6.1` | `https://casa.nrao.edu/download/devel/grpc/el8-1.18/protobuf-devel-3.6.1-3.el8.x86_64.rpm` |
| `grpc-1.18.0` | `https://casa.nrao.edu/download/devel/grpc/el8-1.18/grpc-1.18.0-2.el8.x86_64.rpm` |
| `grpc-devel-1.18.0` | `https://casa.nrao.edu/download/devel/grpc/el8-1.18/grpc-devel-1.18.0-2.el8.x86_64.rpm` |
| `grpc-plugins-1.18.0` | `https://casa.nrao.edu/download/devel/grpc/el8-1.18/grpc-plugins-1.18.0-2.el8.x86_64.rpm` |

## rh8 dev image limitations (UBI 8)

The `rh8` dev image is based on **Red Hat Universal Base Image 8 (UBI 8)**,
which is the only freely redistributable RHEL 8 base.  UBI 8 only exposes
the **BaseOS** and **AppStream** repositories publicly.  Several CASA build
prerequisites—notably `flex`, `bison`, and many `-devel` packages—live in the
**CodeReady Builder (CRB)** repository or EPEL, which require an active RHEL
subscription and are **not** available in public UBI builds.

Because casacore/libsakura prerequisites are **temporarily skipped** in these
images, `./ci/scripts/build.sh dev rh8 6.7.3-21` succeeds on UBI 8.  Only
the CASA-hosted protobuf/gRPC RPMs are attempted (best-effort).

### Recommended alternatives for full development builds

For a complete CASA-from-source environment, use the **alma8** or
**rockylinux8** dev images:

```bash
# Pull the AlmaLinux 8 dev image
docker pull ghcr.io/nova-alma/casa-dev-alma8:6.7.3-21

# Pull the Rocky Linux 8 dev image
docker pull ghcr.io/nova-alma/casa-dev-rockylinux8:6.7.3-21
```

These images have access to EPEL 8 and all CASA6 build prerequisites without
any subscription requirement.

### When rh8 (UBI 8) is the right choice

The `rh8` image is the **redistributable** RHEL 8 base.  Use it when:
- You need a runtime container that can run on entitled RHEL 8 systems.
- You are building CASA in an **entitled RHEL environment** (set
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

> Dev images provide a base environment for CASA development.  **Currently**,
> the casacore and libsakura build prerequisites are temporarily skipped; only the
> CASA-hosted protobuf/gRPC RPMs are installed.  Runtime images (`casa-base:*`)
> remain minimal – they carry only the X11/GL/font dependencies needed to run
> CASA GUIs or headless jobs.  Keep runtime images lean; use dev images when
> you need to compile code.
