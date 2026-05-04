FROM ubuntu:24.04

# Install CASA runtime dependencies and tools needed for micromamba
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        fontconfig \
        fonts-liberation \
        libfreetype6 \
        libgl1 \
        libglu1-mesa \
        libsm6 \
        libxext6 \
        libxrender1 \
        python3 \
        python3-pip \
        wget \
        xvfb \
    && curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C /usr/local bin/micromamba \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV MAMBA_ROOT_PREFIX=/opt/conda

RUN useradd -m -s /bin/bash pipeline

USER pipeline
WORKDIR /home/pipeline

# Create CASA data directory as a mount point for the measures data volume.
RUN mkdir -p /home/pipeline/.casa/data

ENV PATH=/opt/conda/envs/pipeline/bin:$PATH \
    CONDA_PREFIX=/opt/conda/envs/pipeline \
    CONDA_DEFAULT_ENV=pipeline

LABEL org.opencontainers.image.source="https://github.com/NOVA-ALMA/casa-containers"
LABEL org.opencontainers.image.description="Base Ubuntu 24.04 image for CASA containers"
