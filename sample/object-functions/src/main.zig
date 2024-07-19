const std = @import("std");
const zjsc = @import("zig-jsc");

const c_api = zjsc.c_api;

const allocator = std.heap.c_allocator;

pub fn main() !void {
    const context = zjsc.Context.init();
    defer context.release();

    const global_object = context.getGlobal();

    const log_name = "log";
    const render_name = "render";

    const log_fn = context.createFunction(log_name, log);
    const render_fn = context.createFunction(render_name, render);

    try global_object.setProperty(log_name, log_fn);
    try global_object.setProperty(render_name, render_fn);

    const log_call_statement = "log('Hello from JavaScript inside Zig');";
    const render_call_statement = "const a = render();";

    _ = context.evaluateScript(log_call_statement);
    _ = context.evaluateScript(render_call_statement);
}
fn log(ctx: c_api.JSContextRef, function: c_api.JSObjectRef, this: c_api.JSObjectRef, argc: usize, args: [*c]const c_api.JSValueRef, exp: [*c]c_api.JSValueRef) callconv(.C) c_api.JSValueRef {
    _ = exp; // autofix
    _ = this; // autofix
    _ = function; // autofix

    const arguments = args[0..argc];
    const input = zjsc.toString(ctx, arguments[0]) catch return zjsc.createUndefined(ctx);

    // var buffer = allocator.alloc(u8, jsc.getStringMaxSize(input)) catch unreachable;
    // defer allocator.free(buffer);

    // const string_length = jsc.createStringWithBuffer(input, buffer.ptr, buffer.len);
    // const string = buffer[0..string_length];

    const out = std.io.getStdOut().writer();
    out.print("log {s}\n", .{input}) catch {};
    return zjsc.createUndefined(ctx);
}

fn render(ctx: c_api.JSContextRef, function: c_api.JSObjectRef, this: c_api.JSObjectRef, argc: usize, args: [*c]const c_api.JSValueRef, exp: [*c]c_api.JSValueRef) callconv(.C) c_api.JSValueRef {
    _ = exp; // autofix
    _ = args; // autofix
    _ = argc; // autofix
    _ = this; // autofix
    _ = function; // autofix

    const out = std.io.getStdOut().writer();
    out.writeAll("Render") catch {};

    return zjsc.createUndefined(ctx);
}
