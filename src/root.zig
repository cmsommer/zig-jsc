const std = @import("std");
const testing = std.testing;

const jsc = @cImport({
    @cDefine("BUILDING_WEBKIT", {});
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCClass.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCContext.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCDefines.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCException.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCOptions.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCValue.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCVersion.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCVirtualMachine.h");
    @cInclude("/usr/include/webkitgtk-6.0/jsc/JSCWeakValue.h");
});

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
    const context = jsc.jsc_context_new();
    _ = context; // autofix
}
