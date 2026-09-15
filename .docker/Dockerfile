FROM lscr.io/linuxserver/webtop:ubuntu-xfce

#======================#
# Prepare Installation #
#======================#

ENV DEBIAN_FRONTEND=noninteractive

# Update APT only once
RUN apt-get update

# Install generic tools
RUN apt-get install -y \
    build-essential \
    curl \
    git

#================#
# Install VSCode #
#================#

# Install VSCode Server
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz && \
    tar -xf vscode_cli.tar.gz -C /opt && \
    rm vscode_cli.tar.gz

# Prepare VSCode Server directories
RUN mkdir -p /.vscode

# Add VSCode Server as a service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/code-server /etc/s6-overlay/s6-rc.d/user/contents.d && \
    echo "longrun" > /etc/s6-overlay/s6-rc.d/code-server/type && \
    echo '#!/bin/bash' > /etc/s6-overlay/s6-rc.d/code-server/run && \
    echo 'exec /opt/code serve-web --port 8000 --host 0.0.0.0 --server-data-dir /.vscode --default-folder=/opt/VisibleSim/applicationsSrc --accept-server-license-terms --without-connection-token' >> /etc/s6-overlay/s6-rc.d/code-server/run && \
    chmod +x /etc/s6-overlay/s6-rc.d/code-server/run && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/code-server

#====================#
# Install VisibleSim #
#====================#

WORKDIR /opt
RUN git clone --verbose --progress https://github.com/ProgrammableMatterProject/VisibleSim
WORKDIR /opt/VisibleSim

# Required dependencies for VisibleSim
RUN apt-get install -y \
    build-essential \
    freeglut3-dev \
    libglew-dev \
    sbcl \
    libmuparser-dev

# Optional dependencies for VisibleSim
RUN apt-get install -y \
    doxygen \
    ffmpeg \
    libsfml-dev

COPY VisibleSim/Makefile /opt/VisibleSim/Makefile
COPY VisibleSim/simulatorCore/src/Makefile /opt/VisibleSim/simulatorCore/src/Makefile

RUN make

COPY VisibleSim/.applicationsSrc/Makefile /opt/VisibleSim/.applicationsSrc/Makefile

#=================#
# Install Scripts #
#=================#

RUN mkdir -p /opt/scripts
ENV PATH="${PATH}:/opt/scripts"

COPY scripts/run.sh /opt/scripts/run
RUN chmod +x /opt/scripts/run

#======================#
# Cleanup Installation #
#======================#

# Cleanup APT cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
