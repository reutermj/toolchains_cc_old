"""Entrypoint for declaring C/C++ toolchains using toolchains_cc."""

load("//private:eager_declare_toolchain.bzl", "eager_declare_toolchain")
load("//private:lazy_download_bins.bzl", "lazy_download_bins")

# Why are we using a module extension + two repo rules?
# toolchains_cc should only download the toolchain binaries for the toolchain that is actually used. For example, a user
# might want to have a polyglot repo with both C and Python code, and when they're just building the Python code,
# toolchains_cc shouldn't block the user by performing the expensive binary downloads. If only one repo rule was used
# to both declare the toolchain and download the toolchain binaries, then it would be impossible to register the
# toolchain without also downloading the binaries. This problem is solved by using two repo rules: one to declare the
# toolchain and another to download the toolchain binaries. The first is eagerly fetched when the toolchain is
# registered, and the second is fetched only when the toolchain is actually used to compile C/C++ code. The module
# extension must be used here because a repo rule isn't allowed to invoke another repo rule.
def _cc_toolchains(module_ctx):
    for mod in module_ctx.modules:
        for declared_toolchain in mod.tags.declare:
            # this special case is needed to make the default toolchain env vars start with
            # `toolchains_cc_` rather than `toolchains_cc_default_toolchain_`.
            toolchain_name = declared_toolchain.name
            if declared_toolchain.name == "toolchains_cc_default_toolchain":
                toolchain_name = "toolchains_cc"

            eager_declare_toolchain(
                name = declared_toolchain.name,
                toolchain_name = toolchain_name,
            )
            lazy_download_bins(
                name = declared_toolchain.name + "_bins",
                toolchain_name = toolchain_name,
            )

cc_toolchains = module_extension(
    implementation = _cc_toolchains,
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
