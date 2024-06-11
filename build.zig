const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const lib = b.addModule("zig-jsc-test", .{
    //     .root_source_file = b.path("src/root.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // lib.addIncludePath(.{ .cwd_relative = "/usr/include/glib-2.0/" });
    // lib.addIncludePath(.{ .cwd_relative = "/usr/include/webkitgtk-6.0/" });

    const exe = b.addExecutable(.{
        .name = "zig-jsc-test",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();
    // exe.linkSystemLibrary("javascriptcoregtk-4.1");
    exe.linkSystemLibrary("javascriptcoregtk-6.0");
    // exe.root_module.addImport("zig-jsc", lib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
