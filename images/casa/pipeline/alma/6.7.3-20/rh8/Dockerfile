ARG BASE_IMAGE=ghcr.io/nova-alma/casa-base:rh8
FROM ${BASE_IMAGE}

ARG CASA_VERSION=6.7.3-20
ARG PYTHON_VERSION=3.12
ARG PLATFORM=el8

COPY common/install_pipeline.sh /tmp/install_pipeline.sh
RUN chmod +x /tmp/install_pipeline.sh \
    && CASA_VERSION=${CASA_VERSION} \
       PYTHON_VERSION=${PYTHON_VERSION} \
       PLATFORM=${PLATFORM} \
       /tmp/install_pipeline.sh \
    && rm /tmp/install_pipeline.sh

ENV PATH="/opt/casa/bin:${PATH}"

LABEL org.opencontainers.image.source="https://github.com/NOVA-ALMA/casa-containers"
LABEL org.opencontainers.image.description="ALMA pipeline CASA ${CASA_VERSION} on AlmaLinux 8"
LABEL org.opencontainers.image.version="${CASA_VERSION}"

CMD ["/opt/casa/bin/casa", "--pipeline", "--nologger", "--log2term"]
