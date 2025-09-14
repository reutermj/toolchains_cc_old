load(":config.bzl", "get_config_from_env_vars", "repro_dump")
load(":download_bins.bzl", "download_bins")

def _lazy_download_bins_impl(rctx):
    """Lazily downloads only the toolchain binaries for the configured platform."""
    config = get_config_from_env_vars(rctx)
    repro_dump(rctx, config)
    download_bins(rctx, config)

    rctx.file(
        "BUILD",
        """
load("@toolchains_cc//impl:declare_tools.bzl", "declare_tools")
declare_tools(
    name = "{original_name}",
    all_files = glob(["**"]),
    visibility = ["//visibility:public"],
)
""".format(
            original_name = rctx.original_name,
        ),
    )

lazy_download_bins = repository_rule(
    implementation = _lazy_download_bins_impl,
    attrs = {
        "toolchain_name": attr.string(
            mandatory = True,
            doc = "The name of the toolchain, used for registration.",
        ),
    },
)
