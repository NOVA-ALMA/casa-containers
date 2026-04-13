# ALMA Pipeline

This page documents the ALMA pipeline-enabled CASA images provided by this
repository.

## Overview

The ALMA pipeline images bundle a specific version of CASA together with the
ALMA data reduction pipeline tasks.  The version string encodes both the CASA
base version and the pipeline build number:

```
<casa-version>-<pipeline-build>   →   e.g. 6.6.6-18
```

## Supported Versions

| Pipeline version | CASA base | Platform | Image |
|---|---|---|---|
| 6.6.6-18 | 6.6.6 | rh8 | `ghcr.io/nova-alma/casa-pipeline-alma:6.6.6-18-rh8` |

> **Note:** Only Rocky Linux 8 (`rh8`) is supported for ALMA pipeline images,
> matching the official ALMA computing environment.

## Pulling the Image

```bash
# Docker
docker pull ghcr.io/nova-alma/casa-pipeline-alma:6.6.6-18-rh8

# Apptainer
apptainer pull oras://ghcr.io/nova-alma/casa-pipeline-alma:6.6.6-18-rh8
```

## Running the ALMA Pipeline

```bash
# Docker
docker run --rm -it \
  -v "${PWD}:/data" \
  ghcr.io/nova-alma/casa-pipeline-alma:6.6.6-18-rh8 \
  /opt/casa/bin/casa --pipeline --nologger --log2term

# Apptainer
apptainer run casa-pipeline-alma-6.6.6-18-rh8.sif --pipeline
```

## Building Locally

```bash
bash ci/scripts/build.sh pipeline rh8 6.6.6-18 alma
bash ci/scripts/build-apptainer.sh pipeline rh8 6.6.6-18 alma
```

## VLA Pipeline

VLA pipeline support is planned for a future release.  See
`images/casa/pipeline/vla/` for the reserved directory.
