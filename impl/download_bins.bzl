visibility("//impl/...")

def download_bins(rctx, config):
    release_name = "gcc-{toolchain_version}-{target}-{libc_version}".format(
        toolchain_version = config["toolchain_version"],
        target = config["target"],
        libc_version = config["libc_version"],
    )
    release_date = RELEASE_TO_DATE[release_name]

    base_url = "{base_url}/{release_name}-{release_date}".format(
        base_url = DOWNLOAD_BASE_URL,
        release_name = release_name,
        release_date = release_date,
    )

    for bin in ["gcc", "libgcc", "libstdcxx"]:
        tarball = "{bin}-{toolchain_version}-{target}-{libc_version}-{release_date}.tar.xz".format(
            bin = bin,
            toolchain_version = config["toolchain_version"],
            target = config["target"],
            libc_version = config["libc_version"],
            release_date = release_date,
        )

        rctx.download_and_extract(
            url = "{}/{}".format(base_url, tarball),
            sha256 = TARBALL_TO_SHA256[tarball],
        )
    
    tarball = "sysroot-{target}-{libc_version}-{release_date}.tar.xz".format(
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
    "gcc-15.2.0-x86_64-linux-gnu-2.28": "2025-09-15",
}

TARBALL_TO_SHA256 = {
    "gcc-15.2.0-x86_64-linux-gnu-2.28-2025-09-15.tar.xz": "7459b775d9a808d3d9c33e8c66efa56301be8025c1d453ac1a8b4a3c75efb5ae",
    "libgcc-15.2.0-x86_64-linux-gnu-2.28-2025-09-15.tar.xz": "a0ddbfb03e2660eb0f624855089c61ae7438f921535362b2a4f80f7e504457e8",
    "libstdcxx-15.2.0-x86_64-linux-gnu-2.28-2025-09-15.tar.xz": "93c75ddc9ddff6dcaa80b94cea0835b15fe7008dd4b71e5a2b08f6f5d83bd7ea",
    "sysroot-x86_64-linux-gnu-2.28-2025-09-15.tar.xz": "c4f16c7b585b3d97abc2dc6158cea06a4f39b0ed070307e5f6129c8662043d6e",
}
