const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_jsc = b.dependency("zig_jsc", .{ .target = target, .optimize = optimize });
    const lib = zig_jsc.artifact("zig-jsc");
    const mod = zig_jsc.module("zig-jsc");

    const exe = b.addExecutable(.{
        .name = "zig-jsc-sample",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(lib);

    exe.root_module.addImport("zig-jsc", mod);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
