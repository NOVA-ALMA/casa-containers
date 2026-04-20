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
#   build.sh dev rh8 6.7.3-21
#   build.sh dev rh9 6.7.3-21
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
  dev)
    [[ -z "${VERSION}" ]] && { echo "Error: version required for type=dev"; exit 1; }
    # VERSION format: <X.Y.Z>-<build>, e.g. 6.7.3-21
    # Tag convention: ghcr.io/nova-alma/casa-dev-<platform>:<X.Y.Z>-<build>
    CASA_VERSION="${VERSION%-*}"
    CASA_BUILD="${VERSION##*-}"
    CONTEXT="${IMAGES_DIR}/dev/${CASA_VERSION}-${CASA_BUILD}"
    DOCKERFILE="${CONTEXT}/${PLATFORM}/Dockerfile"
    IMAGE_NAME="${REGISTRY}/casa-dev-${PLATFORM}:${CASA_VERSION}-${CASA_BUILD}"
    BUILD_ARGS="--build-arg CASA_VERSION=${CASA_VERSION} --build-arg CASA_BUILD=${CASA_BUILD}"
    ;;
  *)
    echo "Error: unknown type '${TYPE}'. Must be base, general, pipeline, or dev."
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
