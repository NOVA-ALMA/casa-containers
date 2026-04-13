# CASA General – Latest

This directory is a convenience pointer to the most recent stable CASA general
release tracked in this repository.

**Current latest version:** 6.7.3

To build the latest image, use the versioned directory directly:

```bash
# Docker
cd ../6.7.3
docker build -f rh8/Dockerfile -t ghcr.io/nova-alma/casa:latest-rh8 .

# Apptainer
apptainer build casa-latest-rh8.sif rh8/apptainer.def
```

Or use the CI script:

```bash
ci/scripts/build.sh general rh8 6.7.3
```

The canonical latest version is defined in [`metadata/versions.yaml`](../../../../metadata/versions.yaml).
