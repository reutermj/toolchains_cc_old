"""Defines the repo rules and module extension for managing C++ toolchains across different platforms."""

load("//impl:eager_declare_toolchain.bzl", "eager_declare_toolchain")
load("//impl:lazy_download_bins.bzl", "lazy_download_bins")

def _cxx_toolchains(module_ctx):
    for mod in module_ctx.modules:
        for declared_toolchain in mod.tags.declare:
            # TODO: not super happy with this special case
            # it's needed to make the default toolchain env vars start with
            # `toolchains_cc_` rather than `toolchains_cc_default_toolchain_`.
            toolchain_name = declared_toolchain.name
            if declared_toolchain.name == "toolchains_cc_default_toolchain":
                toolchain_name = "toolchains_cc"

            # we need to use a module extension + two repository rules
            # to enable lazy downloading of the toolchain binaries
            # when registering many toolchains.
            # repository rules arent allowed to call other repository rules,
            # so we have to wrap the two repository rules in a module extension.
            # `eager_declare_toolchain` declares the toolchain(...) which is eagerly evaluated
            # for every registered toolchain. This allows bazel to determime
            # which toolchain is valid for the current platform.
            # `lazy_download_bins` only downloads the binaries when the toolchain
            # is actually used in a build.
            # more context: https://github.com/reutermj/toolchains_cc/issues/1

            eager_declare_toolchain(
                name = declared_toolchain.name,
                toolchain_name = toolchain_name,
            )
            lazy_download_bins(
                name = declared_toolchain.name + "_bins",
                toolchain_name = toolchain_name,
            )

cxx_toolchains = module_extension(
    implementation = _cxx_toolchains,
    tag_classes = {
        "declare": tag_class(
            attrs = {
                "name": attr.string(
                    mandatory = True,
                    doc = "The name of the toolchain, used for registration.",
                ),
            },
        ),
    },
)
