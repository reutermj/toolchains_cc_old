"""Function for downloading specific toolchain binaries."""

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

    base_url = "{base_url}/{release_name}-{release_date}".format(
        base_url = DOWNLOAD_BASE_URL,
        release_name = release_name,
        release_date = release_date,
    )

    tarball = "{target}-{libc_version}-gcc-{compiler_version}-{release_date}.tar.xz".format(
        compiler_version = config["compiler_version"],
        target = config["target"],
        libc_version = config["libc_version"],
        release_date = release_date,
    )

    rctx.download_and_extract(
        url = "{}/{}".format(base_url, tarball),
        sha256 = TARBALL_TO_SHA256[tarball],
    )

DOWNLOAD_BASE_URL = "https://github.com/reutermj/toolchains_cc/releases/download"

RELEASE_TO_DATE = {
    "x86_64-linux-gnu-2.28-gcc-15.2.0": "20250916",
}

TARBALL_TO_SHA256 = {
    "x86_64-linux-gnu-2.28-gcc-15.2.0-20250916.tar.xz": "7459b775d9a808d3d9c33e8c66efa56301be8025c1d453ac1a8b4a3c75efb5ae",
}
