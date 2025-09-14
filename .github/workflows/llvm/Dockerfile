# needs to be musl based to statically link
# when attempting glibc, it failed to link because clang uses some symbols that are only available when dynamic linking glibc
FROM alpine:latest

# Install crosstool-ng dependencies
RUN apk update && \
    apk add \
        bash \
        git \
        coreutils \
        diffutils \
        sudo \
        musl-dev \
        gcc \
        g++ \
        binutils-dev \
        make \
        cmake \
        samurai \
        python3 \
        py3-setuptools \
        libffi-dev \
        openssl-dev \
        ncurses-dev \
        libedit-dev \
        libxml2-dev
        # zlib-dev \
        # zlib-static

# Create user 
RUN adduser -D -s /bin/bash builder && \
    adduser builder wheel
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER builder
WORKDIR /home/builder

ARG llvm_version=21.1.1
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_version}/llvm-project-${llvm_version}.src.tar.xz && \
    mkdir llvm && \
    tar --strip-components=1 -xvf llvm-project-${llvm_version}.src.tar.xz -C llvm

# -DLLVM_ENABLE_ZLIB=OFF shouldnt be necessary but alpine doesnt build libzlib.a with fpic leading to failures when linking it into .sos
RUN cd llvm && \
    cmake -G Ninja -S llvm -B build \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DLIBCLANG_BUILD_STATIC=ON \
      -DLLVM_BUILD_STATIC=ON \
      -DLLVM_LINK_LLVM_DYLIB=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DLLVM_ENABLE_ZLIB=OFF \
      -DCMAKE_EXE_LINKER_FLAGS="-static" \
      -DCMAKE_BUILD_TYPE=Release && \
    ninja -C build
