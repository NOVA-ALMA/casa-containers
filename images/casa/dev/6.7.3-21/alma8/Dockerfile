ARG BASE_IMAGE=almalinux:8
FROM ${BASE_IMAGE}

ARG CASA_VERSION=6.7.3
ARG CASA_BUILD=21
ARG PYTHON_VERSION=3.8
ARG PLATFORM=el8
ARG DISTRO=alma8
ARG ENABLE_OPENMPI=true

# Install CASA6 build prerequisites (compilers, CMake, lib *-devel, Python, etc.)
COPY common/install_prerequisites_el8.sh /tmp/install_prerequisites_el8.sh
RUN chmod +x /tmp/install_prerequisites_el8.sh \
    && DISTRO=${DISTRO} \
       ENABLE_OPENMPI=${ENABLE_OPENMPI} \
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
LABEL org.opencontainers.image.description="CASA dev ${CASA_VERSION}-${CASA_BUILD} on AlmaLinux 8 (includes full CASA6 build prerequisites)"
LABEL org.opencontainers.image.version="${CASA_VERSION}-${CASA_BUILD}"

CMD ["/opt/casa/bin/casa", "--nologger", "--log2term"]
