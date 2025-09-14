load("//impl:config.bzl", "get_config_from_env_vars")

def _eager_declare_toolchain_impl(rctx):
    """Eagerly declare the toolchain(...) to determine which registered toolchain is valid for the current platform."""
    config = get_config_from_env_vars(rctx)

    rctx.file(
        "BUILD",
        """
load("@toolchains_cc.bzl//impl:declare_toolchain.bzl", "declare_toolchain")
declare_toolchain(
    name = "{original_name}",
    sysroot = "@@{bins_repo_name}//:{original_name}_bins.sysroot",
    all_tools = "@@{bins_repo_name}//:{original_name}_bins.all_tools",
    visibility = ["//visibility:public"],
)
""".format(
            original_name = rctx.original_name,
            bins_repo_name = rctx.name + "_bins",
        ),
    )

eager_declare_toolchain = repository_rule(
    implementation = _eager_declare_toolchain_impl,
    attrs = {
        "toolchain_name": attr.string(
            mandatory = True,
            doc = "The name of the toolchain, used for registration.",
        ),
    },
)
