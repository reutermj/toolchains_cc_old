"""Utility functions for handling toolchains_cc configurations."""

visibility("//private/...")

# Why are environment variables used to configure toolchains_cc?
# toolchains_cc should allow users to test their build with a wide range of toolchain configurations. For example,
# an open source library author may want to ensure their library builds in CI with both gcc and clang, both glibc
# and musl, and both libstdc++ and libc++ using a configuration matrix. To support this, the configuration
# options must be provided to the repo rules via the bazel cli. Due to phases, providing them via bazel_skylib
# string_flag(...) is not an option. This leaves us using --repo_env to set specific environment prefixed by the
# toolchain name to disambiguate the configurations for multiple registered toolchains.

def _get_config(rctx, var_name, default):
    var = "{}_{}".format(rctx.attr.toolchain_name, var_name)
    value = rctx.getenv(var)
    if value == None:
        return default
    return value

def _validate_config(config):
    extended_triple = "{target}:{libc_version}:{compiler}:{compiler_version}".format(
        target = config["target"],
        libc_version = config["libc_version"],
        compiler = config["compiler"],
        compiler_version = config["compiler_version"],
    )
    if extended_triple not in SUPPORT_MATRIX:
        fail("Configuration {extended_triple} is unsupported.".format(extended_triple = extended_triple))

def get_config_from_env_vars(rctx):
    """Populates the configuration dictionary from the toolchain environment variables.

    Args:
      rctx: The repository context.

    Returns:
        The configuration dictionary.
    """
    config = {
        "target": _get_config(rctx, "target", "x86_64-linux-gnu"),
        "libc_version": _get_config(rctx, "libc_version", "2.28"),
        "compiler": _get_config(rctx, "compiler", "gcc"),
        "compiler_version": _get_config(rctx, "compiler_version", "15.2.0"),
    }

    _validate_config(config)

    return config

def repro_dump(rctx, config):
    """Print configuration settings for reproducing the build.

    Args:
      rctx: The repository context.
      config: The configuration dictionary.
    """

    # buildifier: disable=print
    print("""
--------============[[  Begin toolchains_cc repro dump  ]]============--------
For reproducing this build, use the following configurations in your .bazelrc:
common --repo_env={name}_target={target}
common --repo_env={name}_compiler_version={compiler_version}
common --repo_env={name}_libc_version={libc_version}
--------============[[   End toolchains_cc repro dump   ]]============--------
""".format(
        name = rctx.attr.toolchain_name,
        target = config["target"],
        libc_version = config["libc_version"],
        compiler = config["compiler"],
        compiler_version = config["compiler_version"],
    ))

SUPPORT_MATRIX = {
    "x86_64-linux-gnu:2.28:gcc:15.2.0": True,
}
