const std = @import("std");
const zjsc = @import("zig-jsc");

const jsc = zjsc.jsc_functions;

const allocator = std.heap.c_allocator;

pub fn main() !void {
    const context = jsc.createContext();
    const global_object = jsc.getGlobalObject(context);

    const logsomething_name = jsc.createString("logsomething");
    const log_name = jsc.createString("log");
    const render_name = jsc.createString("render");

    const log_fn = jsc.createFunction(context, log_name, log);
    const render_fn = jsc.createFunction(context, render_name, render);

    // const console_obj = jsc.JSObjectMake(context, jsClass: JSClassRef, data: ?*anyopaque)

    jsc.setProperty(context, global_object, log_name, log_fn);
    jsc.setProperty(context, global_object, render_name, render_fn);

    const log_call_statement = jsc.createString("log('Hello from JavaScript inside Zig');");
    const render_call_statement = jsc.createString("const a = render();");

    _ = jsc.evaluateScript(context, log_call_statement);
    _ = jsc.evaluateScript(context, render_call_statement);

    jsc.releaseContext(context);

    jsc.releaseString(log_call_statement);
    jsc.releaseString(render_call_statement);

    jsc.releaseString(logsomething_name);
    jsc.releaseString(log_name);
    jsc.releaseString(render_name);
}

fn log(
    ctx: jsc.JSContextRef,
    function: jsc.JSObjectRef,
    this: jsc.JSObjectRef,
    argument_count: usize,
    arguments: [*c]const jsc.JSValueRef,
    except: [*c]jsc.JSValueRef,
) callconv(.C) jsc.JSValueRef {
    _ = except; // autofix
    _ = this; // autofix
    _ = function; // autofix

    const args = arguments[0..argument_count];
    const input = jsc.valueToString(ctx, args[0]);

    var buffer = allocator.alloc(u8, jsc.getStringMaxSize(input)) catch unreachable;
    defer allocator.free(buffer);

    const string_length = jsc.createStringWithBuffer(input, buffer.ptr, buffer.len);
    const string = buffer[0..string_length];

    const out = std.io.getStdOut().writer();
    out.print("log {s}", .{string}) catch {};
    return jsc.createUndefined(ctx);
}

fn render(
    ctx: jsc.JSContextRef,
    function: jsc.JSObjectRef,
    this: jsc.JSObjectRef,
    argument_count: usize,
    _arguments: [*c]const jsc.JSValueRef,
    except: [*c]jsc.JSValueRef,
) callconv(.C) jsc.JSValueRef {
    _ = except; // autofix
    _ = _arguments; // autofix
    _ = argument_count; // autofix
    _ = this; // autofix
    _ = function; // autofix
    const out = std.io.getStdOut();
    out.writeAll("Render") catch {};

    return jsc.createUndefined(ctx);
}
