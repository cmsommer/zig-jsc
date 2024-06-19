const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig-jsc",
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("zig-jsc", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    mod.linkSystemLibrary("", .{});
    // switch (target.result.os.tag) {
    //     .windows => {
    //         mod.addObjectFile(b.path("jsc/lib/x86_64-windows/libJavaScriptCore.lib"));
    //         lib.addObjectFile(b.path("jsc/lib/x86_64-windows/libJavaScriptCore.lib"));
    //     },
    //     else => {
    mod.addObjectFile(b.path("jsc/lib/x86_64-linux/libbmalloc.a"));
    mod.addObjectFile(b.path("jsc/lib/x86_64-linux/libWTF.a"));
    mod.addObjectFile(b.path("jsc/lib/x86_64-linux/libJavaScriptCore.a"));
    //     },
    // }

    b.installArtifact(lib);
}
