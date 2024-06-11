const std = @import("std");
const jsc = @import("./jsc.zig");

const allocator = std.heap.c_allocator;

pub fn main() !void {
    const context = jsc.jsc_context_new();
    const global_object = jsc.jsc_context_get_global_object(context);
    const log_function_name = jsc.jsc_value_new_string("log");
    const function = jsc.jsc_value_new_function(context, log_function_name, logFromJavascript); //, null, null, 0, null);
    // ObjectMakeFunctionWithCallback(global_context, log_function_name, logFromJavascript);

    jsc.jsc_value_object_set_property(global_object, context, log_function_name, function);

    const log_call_statement = jsc.jsc_value_new_string(context, "log('Hello from JavaScript inside Zig');");
    const ret = jsc.jsc_context_evaluate(context, log_call_statement, 1);
    _ = ret; // autofix
}

fn logFromJavascript(
    ctx: jsc.JSCContext,
    function: jsc.JSCValue,
    this: jsc.JSCValue,
    argument_count: usize,
    _arguments: [*c]const jsc.JSCValue,
    except: [*c]jsc.JSCValue,
) callconv(.C) jsc.JSCValue {
    _ = except; // autofix
    _ = this; // autofix
    _ = function; // autofix
    const args = _arguments[0..argument_count];
    const input: jsc.JSCValue = jsc.jsc_value_to_string(args[0]);

    var buffer = allocator.alloc(u8, jsc.JSStringGetMaximumUTF8CStringSize(input)) catch unreachable;
    defer allocator.free(buffer);

    const string_length = jsc.JSStringGetUTF8CString(input, buffer.ptr, buffer.len);
    const string = buffer[0..string_length];

    var stdout = std.io.getStdOut();

    stdout.writeAll(string) catch {};

    return jsc.JSValueMakeUndefined(ctx);
}
