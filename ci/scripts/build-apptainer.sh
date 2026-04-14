#!/usr/bin/env bash
# Build a CASA Apptainer/Singularity image from a .def file.
#
# Usage:
#   build-apptainer.sh <type> <platform> [<version>] [<variant>]
#
# Examples:
#   build-apptainer.sh general rh8 6.7.3
#   build-apptainer.sh pipeline rh8 6.6.6-18 alma
#
# Environment variables:
#   OUTPUT_DIR - Directory to write .sif files (default: ./sif)

set -euo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-./sif}"

TYPE="${1:?Usage: build-apptainer.sh <type> <platform> [<version>] [<variant>]}"
PLATFORM="${2:?Usage: build-apptainer.sh <type> <platform> [<version>] [<variant>]}"
VERSION="${3:-}"
VARIANT="${4:-}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGES_DIR="${REPO_ROOT}/images/casa"

case "${TYPE}" in
  general)
    [[ -z "${VERSION}" ]] && { echo "Error: version required for type=general"; exit 1; }
    DEF_FILE="${IMAGES_DIR}/general/${VERSION}/${PLATFORM}/apptainer.def"
    SIF_NAME="casa-${VERSION}-${PLATFORM}.sif"
    ;;
  pipeline)
    [[ -z "${VERSION}" ]] && { echo "Error: version required for type=pipeline"; exit 1; }
    [[ -z "${VARIANT}" ]] && { echo "Error: variant required for type=pipeline"; exit 1; }
    DEF_FILE="${IMAGES_DIR}/pipeline/${VARIANT}/${VERSION}/${PLATFORM}/apptainer.def"
    SIF_NAME="casa-pipeline-${VARIANT}-${VERSION}-${PLATFORM}.sif"
    ;;
  *)
    echo "Error: unknown type '${TYPE}'. Must be general or pipeline."
    exit 1
    ;;
esac

if [[ ! -f "${DEF_FILE}" ]]; then
  echo "Error: definition file not found: ${DEF_FILE}"
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
OUTPUT_SIF="${OUTPUT_DIR}/${SIF_NAME}"

echo "==> Building Apptainer image: ${SIF_NAME}"
echo "    Definition: ${DEF_FILE}"
echo "    Output:     ${OUTPUT_SIF}"

apptainer build "${OUTPUT_SIF}" "${DEF_FILE}"

echo "==> Apptainer build complete: ${OUTPUT_SIF}"
