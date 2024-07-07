const std = @import("std");
const zjsc = @import("zig-jsc");

const jsc = zjsc.jsc_types;
const c_api = zjsc.jsc_c_api;

const allocator = std.heap.c_allocator;

pub fn main() !void {
    const context = jsc.Context.init();
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

fn log(ctx: jsc.Context, function: jsc.Value, this: jsc.Value, argument_count: usize, arguments: []jsc.Value, except: []jsc.Value) jsc.Value {
    _ = except; // autofix
    _ = this; // autofix
    _ = function; // autofix

    const args = arguments[0..argument_count];
    const input = args[0].toString();

    // var buffer = allocator.alloc(u8, jsc.getStringMaxSize(input)) catch unreachable;
    // defer allocator.free(buffer);

    // const string_length = jsc.createStringWithBuffer(input, buffer.ptr, buffer.len);
    // const string = buffer[0..string_length];

    const out = std.io.getStdOut().writer();
    out.print("log {s}", .{input}) catch {};
    return jsc.createUndefined(ctx);
}

fn render(ctx: jsc.Context, function: jsc.Value, this: jsc.Value, argument_count: usize, arguments: []jsc.Value, except: []jsc.Value) jsc.Value {
    _ = except; // autofix
    _ = arguments; // autofix
    _ = argument_count; // autofix
    _ = this; // autofix
    _ = function; // autofix
    const out = std.io.getStdOut();
    out.writeAll("Render") catch {};

    return ctx.createUndefined();
}
