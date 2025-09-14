"""Functions for downloading specific toolchain binaries."""

visibility("//private/...")

def download_bins(rctx, config):
    """Download and extract toolchain binaries and sysroot.

    Args:
      rctx: The lazy_download_bins repository context.
      config: The configuration dictionary.
    """
    release_name = "{target}-{libc_version}-gcc-{compiler_version}".format(
        compiler_version = config["compiler_version"],
        target = config["target"],
        libc_version = config["libc_version"],
    )
    release_date = RELEASE_TO_DATE[release_name]

    release_url = "{base_url}/{release_name}-{release_date}".format(
        base_url = DOWNLOAD_BASE_URL,
        release_name = release_name,
        release_date = release_date,
    )

    tarball_name = "{target}-{libc_version}-gcc-{compiler_version}-{release_date}.tar.xz".format(
        compiler_version = config["compiler_version"],
        target = config["target"],
        libc_version = config["libc_version"],
        release_date = release_date,
    )

    rctx.download_and_extract(
        url = "{release_url}/{tarball_name}".format(
            release_url = release_url,
            tarball_name = tarball_name,
        ),
        sha256 = TARBALL_TO_SHA256[tarball_name],
    )

DOWNLOAD_BASE_URL = "https://github.com/reutermj/toolchains_cc/releases/download"

RELEASE_TO_DATE = {
    "x86_64-linux-gnu-2.28-gcc-15.2.0": "20250917",
}

TARBALL_TO_SHA256 = {
    "x86_64-linux-gnu-2.28-gcc-15.2.0-20250917.tar.xz": "50799a4eab3ddff75f19604eef3e6890aab3423987ce32a2372eb9f18a218694",
}
