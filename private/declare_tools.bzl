"""Macro for declaring the tools inside the lazy_download_bins repo rule."""

load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")
load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")

def _declare_tools(name, visibility, all_files, target):
    all_files_target_name = "{}_all_files".format(name)
    all_files_target = ":{}".format(all_files_target_name)
    native.filegroup(
        name = all_files_target_name,
        srcs = all_files,
        visibility = ["//visibility:private"],
    )

    directory(
        name = "{}_root".format(name),
        srcs = [all_files_target],
        visibility = ["//visibility:private"],
    )

    subdirectory(
        name = "{}_sysroot".format(name),
        parent = ":{}_root".format(name),
        path = "{}/sysroot".format(target),
        visibility = visibility,
    )

    tool_map = {}
    tools = [
        ("ar_actions", "ar"),
        ("assembly_actions", "gcc"),
        ("c_compile", "gcc"),
        ("cpp_compile_actions", "g++"),
        ("link_actions", "g++"),
        ("objcopy_embed_data", "objcopy"),
        ("strip", "strip"),
    ]

    for (action, tool) in tools:
        target_name = "{}_{}".format(name, action)
        tool_map["@rules_cc//cc/toolchains/actions:{}".format(action)] = target_name
        cc_tool(
            name = target_name,
            src = ":bin/{}-{}".format(target, tool),
            data = [all_files_target],
            visibility = ["//visibility:private"],
        )

    cc_tool_map(
        name = "{}_all_tools".format(name),
        tools = tool_map,
        visibility = visibility,
    )

declare_tools = macro(
    attrs = {
        "all_files": attr.label_list(mandatory = True, configurable = False),
        "target": attr.string(mandatory = True, configurable = False),
    },
    implementation = _declare_tools,
)
