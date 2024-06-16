const std = @import("std");

pub fn build(b: *std.Build) void {
    const windows = b.option(bool, "windows", "Target Microsoft Windows") orelse false;

    const target = b.resolveTargetQuery(.{ .os_tag = if (windows) .windows else .linux });
    // const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_jsc = b.dependency("zig_jsc", .{});
    const lib = zig_jsc.artifact("zig-jsc");

    // lib.linkSystemLibrary("javascriptcoregtk-4.1");
    // lib.linkLibC();

    const exe = b.addExecutable(.{
        .name = "zig-jsc-test",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(lib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
