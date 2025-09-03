FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        lsb-release \
        software-properties-common \
        build-essential \
        ninja-build \
        cmake \
        sudo && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 21 all && \
    rm llvm.sh

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-21 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-21 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-21 100 && \
    update-alternatives --set clang /usr/bin/clang-21 && \
    update-alternatives --set clang++ /usr/bin/clang++-21 && \
    update-alternatives --set clangd /usr/bin/clangd-21

RUN clang --version && clang++ --version && clangd --version
