# CASA Base Images

This directory contains Dockerfiles for the base container images used by
CASA container builds. Each subdirectory corresponds to a *platform* (base OS
flavour) and produces an image tagged `ghcr.io/nova-alma/casa-base:<platform>`.

## Supported platforms

| Platform       | Base image                                         | Notes                                          |
|----------------|----------------------------------------------------|------------------------------------------------|
| `rh8`          | `registry.access.redhat.com/ubi8/ubi-minimal`      | True Red Hat UBI 8 – redistributable (see below) |
| `alma8`        | `almalinux:8`                                      | AlmaLinux 8 – RHEL-compatible community distro  |
| `rockylinux8`  | `rockylinux:8`                                     | Rocky Linux 8 – RHEL-compatible community distro |
| `rh9`          | `rockylinux:9`                                     | Rocky Linux 9 (disabled in CI by default)       |

## Which UBI base image to use for distributing CASA containers?

Red Hat provides three flavours of UBI 8:

| Image              | Package manager | Size       | Best for                                   |
|--------------------|-----------------|------------|--------------------------------------------|
| `ubi8/ubi`         | `dnf`           | ~215 MB    | General-purpose builds; easiest to work with |
| `ubi8/ubi-minimal` | `microdnf`      | ~105 MB    | **Recommended** – redistributable + still has a package manager |
| `ubi8/ubi-micro`   | none            | ~35 MB     | Smallest runtime; requires multi-stage build; no shell/package manager |

**Recommendation: `ubi8/ubi-minimal`** is used for the `rh8` platform.

*Rationale:*
- It is fully **redistributable** under the [Red Hat UBI EULA](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image),
  so CASA containers based on it can be freely shared without a RHEL subscription.
- It ships with `microdnf`, allowing packages (X11 libs, Python, fonts …) to be
  installed during the build without switching to a separate build stage.
- It is roughly half the size of the full `ubi8/ubi` image, keeping final image
  sizes reasonable.

If you need the smallest possible *runtime* image, consider a multi-stage build:
install all dependencies in a `ubi8/ubi-minimal` build stage, then `COPY` the
required files into a `ubi8/ubi-micro` final stage.  This is **not** done by
default here because CASA workflows often require shells and runtime tools that
are absent from `ubi8/ubi-micro`.

## Building locally

Make sure Docker (or Podman) is installed and running, then run `ci/scripts/build.sh`
from the repository root:

```bash
# Build the Red Hat UBI 8 Minimal base image
bash ci/scripts/build.sh base rh8

# Build the AlmaLinux 8 base image
bash ci/scripts/build.sh base alma8

# Build the Rocky Linux 8 base image
bash ci/scripts/build.sh base rockylinux8
```

Each command produces a locally tagged image
`ghcr.io/nova-alma/casa-base:<platform>`.  Override the registry with the
`REGISTRY` environment variable if needed:

```bash
REGISTRY=my.registry.example/nova-alma bash ci/scripts/build.sh base alma8
```

To also push after building, set `PUSH=true`:

```bash
PUSH=true bash ci/scripts/build.sh base rh8
```

## Adding a new platform

1. Create a new subdirectory under `images/casa/base/<platform>/`.
2. Add a `Dockerfile` (or `Containerfile`) that starts with the desired base
   image and installs the common CASA runtime dependencies.
3. Add an entry to the `"include"` array in `ci/build-matrix.json`:
   ```json
   {"type": "base", "platform": "<platform>"}
   ```
4. Update this README table to document the new platform.
