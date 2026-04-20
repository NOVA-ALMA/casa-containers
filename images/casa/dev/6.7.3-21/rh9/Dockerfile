FROM registry.access.redhat.com/ubi9/ubi

ARG CASA_VERSION=6.7.3-21
ARG PYTHON_VERSION=3.12
ARG PLATFORM=el9

# Enable EPEL on EL9.  On RHEL/UBI 9 epel-release may not be in the default
# repos, so fall back to the upstream URL when the direct install fails.
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
       PYTHON_VERSION=${PYTHON_VERSION} \
       PLATFORM=${PLATFORM} \
       /tmp/install_dev.sh \
    && rm /tmp/install_dev.sh

ENV PATH="/opt/casa/bin:${PATH}"

LABEL org.opencontainers.image.source="https://github.com/NOVA-ALMA/casa-containers"
LABEL org.opencontainers.image.description="CASA dev ${CASA_VERSION} on RHEL/UBI 9"
LABEL org.opencontainers.image.version="${CASA_VERSION}"

CMD ["/opt/casa/bin/casa", "--nologger", "--log2term"]
