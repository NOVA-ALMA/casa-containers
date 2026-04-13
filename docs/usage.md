# Usage

This repository provides Docker and Apptainer/Singularity container images for
[CASA](https://casa.nrao.edu/) (Common Astronomy Software Applications), built
and published to the GitHub Container Registry at `ghcr.io/nova-alma`.

## Available Images

| Image | Description |
|---|---|
| `ghcr.io/nova-alma/casa-base:<platform>` | Minimal base OS layer |
| `ghcr.io/nova-alma/casa:<version>-<platform>` | General CASA (manual processing) |
| `ghcr.io/nova-alma/casa-pipeline-alma:<version>-<platform>` | ALMA pipeline-enabled CASA |

**Platforms:** `rh8` (Rocky Linux 8), `rh9` (Rocky Linux 9)

## Pulling an Image

```bash
# General CASA 6.7.3 on Rocky Linux 8 – Docker
docker pull ghcr.io/nova-alma/casa:6.7.3-rh8

# General CASA 6.7.3 on Rocky Linux 8 – Apptainer
apptainer pull oras://ghcr.io/nova-alma/casa:6.7.3-rh8
```

## Running CASA (Docker)

```bash
docker run --rm -it \
  -e DISPLAY="${DISPLAY}" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "${PWD}:/data" \
  ghcr.io/nova-alma/casa:6.7.3-rh8
```

## Running CASA (Apptainer)

```bash
apptainer run casa-6.7.3-rh8.sif
```

## Building Locally

Use the CI scripts:

```bash
# Build a base image
bash ci/scripts/build.sh base rh8

# Build a general CASA image
bash ci/scripts/build.sh general rh8 6.7.3

# Build an ALMA pipeline image
bash ci/scripts/build.sh pipeline rh8 6.6.6-18 alma

# Build an Apptainer image
bash ci/scripts/build-apptainer.sh general rh8 6.7.3
```

## Version Matrix

See [`metadata/versions.yaml`](../metadata/versions.yaml) for the complete
list of supported versions, and [`metadata/images.yaml`](../metadata/images.yaml)
for registry and image naming details.
