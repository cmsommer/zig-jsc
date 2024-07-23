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

    mod.addImport("zig-jsc", mod);

    lib.linkLibC();

    lib.addLibraryPath(b.path("lib/webkit-linux-x64/"));
    lib.linkSystemLibrary("JavaScriptCore");

    mod.addLibraryPath(b.path("lib/webkit-linux-x64/"));
    mod.linkSystemLibrary("JavaScriptCore", .{
        .needed = true,
    });

    // switch (target.result.os.tag) {
    //     .windows => {
    //         mod.addObjectFile(b.path("jsc/lib/x86_64-windows/libJavaScriptCore.lib"));
    //         lib.addObjectFile(b.path("jsc/lib/x86_64-windows/libJavaScriptCore.lib"));
    //     },
    //     else => {
    // mod.addObjectFile(b.path("jsc/lib/x86_64-linux/libbmalloc.a"));
    // mod.addObjectFile(b.path("jsc/lib/x86_64-linux/libWTF.a"));
    // mod.addObjectFile(b.path("jsc/lib/x86_64-linux/libJavaScriptCore.a"));
    //     },
    // }

    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_unit_tests.addLibraryPath(b.path("lib/webkit-linux-x64/"));
    lib_unit_tests.linkSystemLibrary("JavaScriptCore");

    lib_unit_tests.root_module.addImport("zig-jsc", &lib_unit_tests.root_module);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
