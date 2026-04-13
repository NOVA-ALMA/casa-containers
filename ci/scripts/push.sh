#!/usr/bin/env bash
# Push CASA Docker images to the container registry.
#
# Usage:
#   push.sh <type> <platform> [<version>] [<variant>]
#
# Examples:
#   push.sh base rh8
#   push.sh general rh8 6.7.3
#   push.sh pipeline rh8 6.6.6-18 alma
#
# Environment variables:
#   REGISTRY - Container registry (default: ghcr.io/nova-alma)

set -euo pipefail

REGISTRY="${REGISTRY:-ghcr.io/nova-alma}"
TYPE="${1:?Usage: push.sh <type> <platform> [<version>] [<variant>]}"
PLATFORM="${2:?Usage: push.sh <type> <platform> [<version>] [<variant>]}"
VERSION="${3:-}"
VARIANT="${4:-}"

case "${TYPE}" in
  base)
    IMAGE_NAME="${REGISTRY}/casa-base:${PLATFORM}"
    ;;
  general)
    [[ -z "${VERSION}" ]] && { echo "Error: version required for type=general"; exit 1; }
    IMAGE_NAME="${REGISTRY}/casa:${VERSION}-${PLATFORM}"
    ;;
  pipeline)
    [[ -z "${VERSION}" ]] && { echo "Error: version required for type=pipeline"; exit 1; }
    [[ -z "${VARIANT}" ]] && { echo "Error: variant required for type=pipeline"; exit 1; }
    IMAGE_NAME="${REGISTRY}/casa-pipeline-${VARIANT}:${VERSION}-${PLATFORM}"
    ;;
  *)
    echo "Error: unknown type '${TYPE}'. Must be base, general, or pipeline."
    exit 1
    ;;
esac

echo "==> Pushing ${IMAGE_NAME}"
docker push "${IMAGE_NAME}"
echo "==> Push complete: ${IMAGE_NAME}"
