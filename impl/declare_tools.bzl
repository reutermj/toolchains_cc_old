load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")
load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")

def _declare_tools(name, visibility, all_files):
    native.filegroup(
        name = "{}_all_files".format(name),
        srcs = all_files,
        visibility = ["//visibility:private"],
    )

    directory(
        name = "{}_root".format(name),
        srcs = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

    subdirectory(
        name = "{}.sysroot".format(name),
        parent = ":{}_root".format(name),
        path = "x86_64-linux-gnu/sysroot",
        visibility = visibility,
    )

    cc_tool_map(
        name = "{}.all_tools".format(name),
        tools = {
            "@rules_cc//cc/toolchains/actions:ar_actions": ":{}_ar_actions".format(name),
            "@rules_cc//cc/toolchains/actions:assembly_actions": ":{}_assembly_actions".format(name),
            "@rules_cc//cc/toolchains/actions:c_compile": ":{}_c_compile".format(name),
            "@rules_cc//cc/toolchains/actions:cpp_compile_actions": ":{}_cpp_compile_actions".format(name),
            "@rules_cc//cc/toolchains/actions:link_actions": ":{}_link_actions".format(name),
            "@rules_cc//cc/toolchains/actions:objcopy_embed_data": ":{}_objcopy_embed_data".format(name),
            "@rules_cc//cc/toolchains/actions:strip": ":{}_strip".format(name),
        },
        visibility = visibility,
    )

    cc_tool(
        name = "{}_ar_actions".format(name),
        src = ":bin/x86_64-linux-gnu-ar",
        data = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

    cc_tool(
        name = "{}_assembly_actions".format(name),
        src = ":bin/x86_64-linux-gnu-gcc",
        data = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

    cc_tool(
        name = "{}_c_compile".format(name),
        src = ":bin/x86_64-linux-gnu-gcc",
        data = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

    cc_tool(
        name = "{}_cpp_compile_actions".format(name),
        src = ":bin/x86_64-linux-gnu-g++",
        data = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

    cc_tool(
        name = "{}_link_actions".format(name),
        src = ":bin/x86_64-linux-gnu-g++",
        data = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

    cc_tool(
        name = "{}_objcopy_embed_data".format(name),
        src = ":bin/x86_64-linux-gnu-objcopy",
        data = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

    cc_tool(
        name = "{}_strip".format(name),
        src = ":bin/x86_64-linux-gnu-strip",
        data = [":{}_all_files".format(name)],
        visibility = ["//visibility:private"],
    )

declare_tools = macro(
    attrs = {
        "all_files": attr.label_list(mandatory = True, configurable = False),
    },
    implementation = _declare_tools,
)
