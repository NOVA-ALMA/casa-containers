#!/usr/bin/env bash
# Build a CASA Docker image.
#
# Usage:
#   build.sh <type> <platform> [<version>] [<variant>]
#
# Examples:
#   build.sh base rh8
#   build.sh general rh8 6.7.3
#   build.sh pipeline rh8 6.6.6-18 alma
#
# Environment variables:
#   REGISTRY   - Container registry (default: ghcr.io/nova-alma)
#   PUSH       - If set to "true", push the image after building

set -euo pipefail

REGISTRY="${REGISTRY:-ghcr.io/nova-alma}"
TYPE="${1:?Usage: build.sh <type> <platform> [<version>] [<variant>]}"
PLATFORM="${2:?Usage: build.sh <type> <platform> [<version>] [<variant>]}"
VERSION="${3:-}"
VARIANT="${4:-}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGES_DIR="${REPO_ROOT}/images/casa"

case "${TYPE}" in
  base)
    CONTEXT="${IMAGES_DIR}/base/${PLATFORM}"
    IMAGE_NAME="${REGISTRY}/casa-base:${PLATFORM}"
    BUILD_ARGS=""
    ;;
  general)
    [[ -z "${VERSION}" ]] && { echo "Error: version required for type=general"; exit 1; }
    CONTEXT="${IMAGES_DIR}/general/${VERSION}"
    DOCKERFILE="${CONTEXT}/${PLATFORM}/Dockerfile"
    IMAGE_NAME="${REGISTRY}/casa:${VERSION}-${PLATFORM}"
    BUILD_ARGS="--build-arg CASA_VERSION=${VERSION}"
    ;;
  pipeline)
    [[ -z "${VERSION}" ]] && { echo "Error: version required for type=pipeline"; exit 1; }
    [[ -z "${VARIANT}" ]] && { echo "Error: variant required for type=pipeline"; exit 1; }
    CONTEXT="${IMAGES_DIR}/pipeline/${VARIANT}/${VERSION}"
    DOCKERFILE="${CONTEXT}/${PLATFORM}/Dockerfile"
    IMAGE_NAME="${REGISTRY}/casa-pipeline-${VARIANT}:${VERSION}-${PLATFORM}"
    BUILD_ARGS="--build-arg CASA_VERSION=${VERSION}"
    ;;
  *)
    echo "Error: unknown type '${TYPE}'. Must be base, general, or pipeline."
    exit 1
    ;;
esac

DOCKERFILE="${DOCKERFILE:-${CONTEXT}/Dockerfile}"

echo "==> Building ${IMAGE_NAME}"
echo "    Context:    ${CONTEXT}"
echo "    Dockerfile: ${DOCKERFILE}"

docker build \
  --file "${DOCKERFILE}" \
  ${BUILD_ARGS} \
  --tag "${IMAGE_NAME}" \
  "${CONTEXT}"

echo "==> Build complete: ${IMAGE_NAME}"

if [[ "${PUSH:-false}" == "true" ]]; then
  echo "==> Pushing ${IMAGE_NAME}"
  docker push "${IMAGE_NAME}"
fi
