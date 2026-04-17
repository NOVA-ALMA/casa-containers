FROM almalinux:8

RUN dnf install -y \
        wget \
        which \
        xorg-x11-server-Xvfb \
        mesa-libGL \
        mesa-libGLU \
        libXext \
        libXrender \
        libSM \
        fontconfig \
        freetype \
        liberation-fonts \
        python3 \
        python3-pip \
    && dnf clean all

LABEL org.opencontainers.image.source="https://github.com/NOVA-ALMA/casa-containers"
LABEL org.opencontainers.image.description="Base AlmaLinux 8 image for CASA containers"
