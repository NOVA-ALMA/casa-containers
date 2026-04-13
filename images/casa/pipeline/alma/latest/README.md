# CASA ALMA Pipeline – Latest

This directory is a convenience pointer to the most recent stable ALMA pipeline
CASA release tracked in this repository.

**Current latest version:** 6.6.6-18

To build the latest pipeline image, use the versioned directory directly:

```bash
# Docker
cd ../6.6.6-18
docker build -f rh8/Dockerfile -t ghcr.io/nova-alma/casa-pipeline-alma:latest-rh8 .

# Apptainer
apptainer build casa-pipeline-alma-latest-rh8.sif rh8/apptainer.def
```

Or use the CI script:

```bash
ci/scripts/build.sh pipeline rh8 6.6.6-18 alma
```

The canonical latest version is defined in [`metadata/versions.yaml`](../../../../../metadata/versions.yaml).
