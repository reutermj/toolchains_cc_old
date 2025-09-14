FROM ubuntu:latest

# This docker file allows for testing the build_gcc.yml actions workload locally.
# args:
#   * GCC_VERSION: version of gcc to use. ct-ng only supports building the latest minor revision of the specific major revision.
#                  the supported values will differ between different commits of ct-ng.
#   * LIBC: build a glibc or musl based toolchain
#   * LIBC_VERSION: version of the specified libc to use. based on the supported versions ct-ng enables building.
#   * REBUILD_ID: used to differentiate newer builds of an already supported toolchain for toolchains_cc releases.
#   * GITHUB_TOKEN: the token used to upload artifacts to the release. will skip the upload if not provided

# =================
# || Create User ||
# =================
# ct-ng cant build as root; it needs to run as a user.
# as well, github actions need sudo to install ct-ng after building and to do apt install
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y sudo gh

RUN useradd -m -s /bin/bash builder && \
    usermod -aG sudo builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER builder
WORKDIR /home/builder

# =======================
# || Environment Setup ||
# =======================
ENV CT_NG_SRC_DIR="/tmp/crosstool-ng"
ENV ARTIFACT_DIR="/tmp/toolchain/artifacts"
ENV OUTPUT_DIR="/tmp/toolchain/output"
ENV WORK_DIR="/tmp/toolchain/work"
ENV SCRIPTS_DIR="/tmp/scripts"

RUN mkdir -p $CT_NG_SRC_DIR
RUN mkdir -p $ARTIFACT_DIR
RUN mkdir -p $OUTPUT_DIR
RUN mkdir -p $WORK_DIR
RUN mkdir -p $SCRIPTS_DIR

ARG GCC_VERSION=15
ARG LIBC=gnu
ARG LIBC_VERSION=2.34
ARG REBUILD_ID=1

# =====================
# || Build Toolchain ||
# =====================
COPY step-1_install_dependencies $SCRIPTS_DIR/step-1_install_dependencies
RUN $SCRIPTS_DIR/step-1_install_dependencies

COPY step-2_build_crosstool_ng $SCRIPTS_DIR/step-2_build_crosstool_ng
RUN $SCRIPTS_DIR/step-2_build_crosstool_ng

COPY step-3_configure_toolchain $SCRIPTS_DIR/step-3_configure_toolchain
RUN $SCRIPTS_DIR/step-3_configure_toolchain

COPY step-4_build_toolchain $SCRIPTS_DIR/step-4_build_toolchain
RUN $SCRIPTS_DIR/step-4_build_toolchain

COPY step-5_package_toolchain $SCRIPTS_DIR/step-5_package_toolchain
RUN $SCRIPTS_DIR/step-5_package_toolchain

ARG GITHUB_TOKEN
COPY step-6_upload_release $SCRIPTS_DIR/step-6_upload_release
RUN $SCRIPTS_DIR/step-6_upload_release
