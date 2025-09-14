visibility("//impl/...")

def _get_config(rctx, var_name, default, supported_values):
    var = "{}_{}".format(rctx.attr.toolchain_name, var_name)
    value = rctx.getenv(var)
    if value == None:
        value = default
    if value not in supported_values:
        fail("Unsupported target: {}={}".format(var, value))
    return value

def get_config_from_env_vars(rctx):
    return {
        "target": _get_config(rctx, "target", "x86_64-linux-gnu", SUPPORTED_TARGETS),
        "toolchain_version": _get_config(rctx, "toolchain_version", "15.2.0", SUPPORTED_TOOLCHAIN_VERSIONS),
        "libc_version": _get_config(rctx, "libc_version", "2.28", SUPPORTED_LIBC_VERSIONS),
    }

def repro_dump(rctx, config):
    # buildifier: disable=print
    print("""
--------============[[  Begin toolchains_cc repro dump  ]]============--------
For reproducing this build, use the following configurations in your .bazelrc:
common --repo_env={name}_target={target}
common --repo_env={name}_toolchain_version={toolchain_version}
common --repo_env={name}_libc_version={libc_version}
--------============[[   End toolchains_cc repro dump   ]]============--------
""".format(
        name = rctx.attr.toolchain_name,
        target = config["target"],
        toolchain_version = config["toolchain_version"],
        libc_version = config["libc_version"],
    ))

SUPPORTED_CXX_STD_LIBS = [
    "libstdc++",
]

SUPPORTED_TARGETS = [
    "x86_64-linux-gnu",
    "x86_64-linux-musl",
]

SUPPORTED_TOOLCHAIN_VERSIONS = [
    "15.2.0",
]

SUPPORTED_LIBC_VERSIONS = [
    "2.28",
    "2.31",
    "2.34",
    "2.36",
    "2.38",
    "2.39",
    "2.40",
]
