"""Macro for declaring the toolchain metadata inside the eager_declare_toolchain repo rule."""

load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:toolchain.bzl", "cc_toolchain")

def declare_toolchain(name, visibility, sysroot, all_tools):
    native.toolchain(
        name = name,
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        toolchain = ":{}_cc_toolchain".format(name),
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
        visibility = visibility,
    )

    cc_toolchain(
        name = "{}_cc_toolchain".format(name),
        args = [
            ":{}_no_canonical_prefixes".format(name),
            ":{}_sysroot".format(name),
        ],
        enabled_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
        known_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
        tool_map = all_tools,
        visibility = ["//visibility:private"],
    )

    # Bazel does not like absolute paths.
    # Clang will use absolute paths when reporting the include path for its headers causing bazel to error out.
    # This changes clang to prefer relative paths.
    # Symptom:
    # ERROR: C:/users/mark/desktop/new_toolchain/BUILD:1:10: Compiling main.c failed: absolute path inclusion(s) found in rule '//:main':
    # the source file 'main.c' includes the following non-builtin files with absolute paths (if these are builtin files, make sure these paths are in your toolchain):
    #   'C:/Users/mark/_bazel_mark/w77p7fta/external/+_repo_rules+llvm_toolchain/toolchain/lib/clang/19/include/vadefs.h'
    cc_args(
        name = "{}_no_canonical_prefixes".format(name),
        actions = [
            "@rules_cc//cc/toolchains/actions:c_compile",
            "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
            "@rules_cc//cc/toolchains/actions:link_actions",
        ],
        args = [
            "-no-canonical-prefixes",
            "-fno-canonical-system-headers",  # gcc only? yes, need to configure this when adding clang support
        ],
        visibility = ["//visibility:private"],
    )

    cc_args(
        name = "{}_sysroot".format(name),
        actions = [
            "@rules_cc//cc/toolchains/actions:c_compile",
            "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
            "@rules_cc//cc/toolchains/actions:link_actions",
        ],
        args = ["--sysroot={sysroot}"],
        format = {
            "sysroot": sysroot,
        },
        visibility = ["//visibility:private"],
    )

# TODO: currently the cc_toolchain macro produces targets whose names dont follow the rules of symbolic macros
# see: https://github.com/bazelbuild/rules_cc/pull/487
# declare_toolchain = macro(
#     attrs = {
#         # configurable = False is required because macros wrap configurable attrs in
#         # a select(...) which cant be used when inlining the labels and strings in
#         # the toolchain declarations.
#         "sysroot": attr.label(mandatory = True, configurable = False),
#         "all_tools": attr.label(mandatory = True, configurable = False),
#     },
#     implementation = _declare_toolchain,
# )
