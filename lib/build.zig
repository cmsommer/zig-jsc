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

    // if (target.result.is()) {
    lib.linkSystemLibrary("javascriptcoregtk-4.1");
    lib.linkLibC();
    // }

    b.installArtifact(lib);
}
