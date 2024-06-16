const std = @import("std");
const jsc = @import("zig-jsc");

const allocator = std.heap.c_allocator;

pub fn main() !void {
    const context = jsc.createContext();
    const global_object: jsc.JSObjectRef = jsc.JSContextGetGlobalObject(context);

    const logsomething_name: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString("logsomething");
    const log_name: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString("log");
    const render_name: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString("render");

    const log_fn: jsc.JSObjectRef = jsc.JSObjectMakeFunctionWithCallback(context, log_name, log);
    const render_fn: jsc.JSObjectRef = jsc.JSObjectMakeFunctionWithCallback(context, render_name, render);

    // const console_obj = jsc.JSObjectMake(context, jsClass: JSClassRef, data: ?*anyopaque)

    jsc.JSObjectSetProperty(context, global_object, log_name, log_fn, jsc.kJSPropertyAttributeNone, null);
    jsc.JSObjectSetProperty(context, global_object, render_name, render_fn, jsc.kJSPropertyAttributeNone, null);

    const log_call_statement: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString("log('Hello from JavaScript inside Zig');");
    const render_call_statement: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString("const a = render();");

    _ = jsc.JSEvaluateScript(context, log_call_statement, null, null, 1, null);
    _ = jsc.JSEvaluateScript(context, render_call_statement, null, null, 1, null);

    jsc.JSGlobalContextRelease(context);

    jsc.JSStringRelease(log_call_statement);
    jsc.JSStringRelease(render_call_statement);

    jsc.JSStringRelease(logsomething_name);
    jsc.JSStringRelease(log_name);
    jsc.JSStringRelease(render_name);
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
    const input: jsc.JSStringRef = jsc.JSValueToStringCopy(ctx, args[0], null);

    var buffer = allocator.alloc(u8, jsc.JSStringGetMaximumUTF8CStringSize(input)) catch unreachable;
    defer allocator.free(buffer);

    const string_length = jsc.JSStringGetUTF8CString(input, buffer.ptr, buffer.len);
    const string = buffer[0..string_length];

    const out = std.io.getStdOut().writer();
    out.print("log {s}", .{string}) catch {};
    return jsc.JSValueMakeUndefined(ctx);
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

    return jsc.JSValueMakeUndefined(ctx);
}
