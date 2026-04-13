ARG BASE_IMAGE=ghcr.io/nova-alma/casa-base:rh9
FROM ${BASE_IMAGE}

ARG CASA_VERSION=6.7.3
ARG CASA_BUILD=17
ARG PYTHON_VERSION=3.12
ARG PLATFORM=el9

COPY common/install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh \
    && CASA_VERSION=${CASA_VERSION} \
       CASA_BUILD=${CASA_BUILD} \
       PYTHON_VERSION=${PYTHON_VERSION} \
       PLATFORM=${PLATFORM} \
       /tmp/install.sh \
    && rm /tmp/install.sh

ENV PATH="/opt/casa/bin:${PATH}"

LABEL org.opencontainers.image.source="https://github.com/NOVA-ALMA/casa-containers"
LABEL org.opencontainers.image.description="CASA general ${CASA_VERSION} on Rocky Linux 9"
LABEL org.opencontainers.image.version="${CASA_VERSION}"

CMD ["/opt/casa/bin/casa", "--nologger", "--log2term"]
