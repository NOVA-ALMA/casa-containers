# Use the full Red Hat UBI 8 standard image (not minimal) for dev images so
# that dnf and a complete package set are available for installing the large
# CASA6 build-prerequisite list.
ARG BASE_IMAGE=registry.access.redhat.com/ubi8/ubi
FROM ${BASE_IMAGE}

ARG CASA_VERSION=6.7.3
ARG CASA_BUILD=21
ARG PYTHON_VERSION=3.8
ARG PLATFORM=el8
ARG DISTRO=rh8
ARG ENABLE_OPENMPI=true
# STRICT_PREREQS: set to "true" to fail if best-effort packages (e.g. flex,
# bison) cannot be installed.  Requires RHEL entitlements / CRB repo access.
# Default is "false" so public UBI 8 CI builds succeed with warnings.
ARG STRICT_PREREQS=false

# Install CASA6 build prerequisites (compilers, CMake, lib *-devel, Python, etc.)
COPY common/install_prerequisites_el8.sh /tmp/install_prerequisites_el8.sh
RUN chmod +x /tmp/install_prerequisites_el8.sh \
    && DISTRO=${DISTRO} \
       ENABLE_OPENMPI=${ENABLE_OPENMPI} \
       STRICT_PREREQS=${STRICT_PREREQS} \
       /tmp/install_prerequisites_el8.sh \
    && rm /tmp/install_prerequisites_el8.sh

# Install CASA dev build from pre-release tarball
COPY common/install_dev.sh /tmp/install_dev.sh
RUN chmod +x /tmp/install_dev.sh \
    && CASA_VERSION=${CASA_VERSION} \
       CASA_BUILD=${CASA_BUILD} \
       PYTHON_VERSION=${PYTHON_VERSION} \
       PLATFORM=${PLATFORM} \
       /tmp/install_dev.sh \
    && rm /tmp/install_dev.sh

ENV PATH="/opt/casa/bin:${PATH}"

LABEL org.opencontainers.image.source="https://github.com/NOVA-ALMA/casa-containers"
LABEL org.opencontainers.image.description="CASA dev ${CASA_VERSION}-${CASA_BUILD} on Red Hat UBI 8 (includes full CASA6 build prerequisites)"
LABEL org.opencontainers.image.version="${CASA_VERSION}-${CASA_BUILD}"

CMD ["/opt/casa/bin/casa", "--nologger", "--log2term"]
