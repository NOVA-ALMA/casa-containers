ARG BASE_IMAGE=ghcr.io/nova-alma/casa-base:rh8
FROM ${BASE_IMAGE}

ARG CASA_VERSION=6.7.3
ARG CASA_BUILD=21
ARG PYTHON_VERSION=3.12
ARG PLATFORM=el8

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
LABEL org.opencontainers.image.description="CASA dev ${CASA_VERSION}-${CASA_BUILD} on Rocky Linux 8"
LABEL org.opencontainers.image.version="${CASA_VERSION}-${CASA_BUILD}"

CMD ["/opt/casa/bin/casa", "--nologger", "--log2term"]
