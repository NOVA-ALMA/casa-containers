FROM rockylinux:9

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
        google-noto-fonts-common \
        python3 \
        python3-pip \
    && dnf clean all

LABEL org.opencontainers.image.source="https://github.com/NOVA-ALMA/casa-containers"
LABEL org.opencontainers.image.description="Base Rocky Linux 9 image for CASA containers"
