"""Repo rule for lazily downloading the C/C++ toolchain binaries when first used."""

load(":config.bzl", "get_config_from_env_vars", "repro_dump")
load(":download_bins.bzl", "download_bins")

def _lazy_download_bins(rctx):
    config = get_config_from_env_vars(rctx)
    repro_dump(rctx, config)
    download_bins(rctx, config)

    rctx.file(
        "BUILD",
        """
load("@toolchains_cc//private:declare_tools.bzl", "declare_tools")

declare_tools(
    name = "{original_name}",
    all_files = glob(["**"]),
    target = "{target}",
    visibility = ["//visibility:public"],
)
""".lstrip().format(
            original_name = rctx.original_name,
            target = config["target"],
        ),
    )

lazy_download_bins = repository_rule(
    implementation = _lazy_download_bins,
    attrs = {
        "toolchain_name": attr.string(
            mandatory = True,
            doc = "The name of the toolchain, used for registration.",
        ),
    },
)
