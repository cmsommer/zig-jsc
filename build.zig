const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zig-jsc", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    mod.addImport("zig-jsc", mod);

    mod.addIncludePath(b.path("lib/include/"));
    mod.addLibraryPath(b.path("lib/webkit-linux-x64/"));
    mod.linkSystemLibrary("JavaScriptCore", .{ .preferred_link_mode = .static });

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
}
