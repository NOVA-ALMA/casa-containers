ARG BASE_IMAGE=ghcr.io/nova-alma/casa-base:rh9
FROM ${BASE_IMAGE}

ARG CASA_VERSION=6.7.3
ARG CASA_BUILD=21
ARG PYTHON_VERSION=3.12
ARG PLATFORM=el9

# Enable EPEL on EL9 and install CASA runtime prerequisites.
# The base image already provides wget, which, xorg-x11-server-Xvfb,
# mesa-libGL, so only the remaining packages are added here.
# On RHEL/UBI 9 epel-release may not be in the default repos; fall back to
# the upstream RPM URL when needed.
RUN dnf install -y epel-release || \
        dnf install -y \
            "https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm"

RUN dnf install -y \
        mesa-libGL \
        glib2 \
        libnsl \
        xorg-x11-server-Xvfb \
        wget \
        which \
        xz \
        perl \
        git \
        ImageMagick \
    && dnf clean all

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
LABEL org.opencontainers.image.description="CASA dev ${CASA_VERSION}-${CASA_BUILD} on Rocky Linux 9"
LABEL org.opencontainers.image.version="${CASA_VERSION}-${CASA_BUILD}"

CMD ["/opt/casa/bin/casa", "--nologger", "--log2term"]
