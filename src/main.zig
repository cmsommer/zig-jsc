const std = @import("std");
const jsc = @import("./jsc.zig");
const linq = @import("./select.zig");
const select = linq.iterator;

const allocator = std.heap.c_allocator;

pub fn main() !void {
    const context = jsc.jsc_context_new();
    const global_object = jsc.jsc_context_get_global_object(context);

    const a = @typeInfo(@TypeOf(log));
    const args = a.Fn.params;

    // for (args) |arg| {
    //     arg.type;
    // }

    const logsomething_function = jsc.jsc_value_new_function_variadic(context, "logsomething", logsomething, null, null, 0);
    const log_function = jsc.jsc_value_new_functionv(context, "log", log, null, null, 0, args.len, jsc.GType);
    const render_function = jsc.jsc_value_new_functionv(context, "render", log, null, null, 0, args.len, null);
    // ObjectMakeFunctionWithCallback(global_context, log_function_name, logFromJavascript);

    jsc.jsc_value_object_set_property(global_object, "logsomething", logsomething_function);
    jsc.jsc_value_object_set_property(global_object, "log", log_function);
    jsc.jsc_value_object_set_property(global_object, "render", render_function);

    const log_call_statement = "log('Hello from JavaScript inside Zig');";
    const logsomething_call_statement = "logsomething();";
    const render_call_statement = "render('Render this in zig');";

    _ = jsc.jsc_context_evaluate(context, log_call_statement, 1);
    _ = jsc.jsc_context_evaluate(context, logsomething_call_statement, 1);
    _ = jsc.jsc_context_evaluate(context, render_call_statement, 1);
}

fn log(context: *jsc.JSCContext) callconv(.C) void {
    _ = context; // autofix
}

fn logsomething() callconv(.C) void {
    std.debug.print("Hello from Zig", .{});
}

fn render(context: *jsc.JSCContext) callconv(.C) jsc.JSCValue_autoptr {
    return jsc.jsc_value_new_undefined(context);
}

// fn logFromJavascript(
//     ctx: jsc.JSCContextClass,
//     function: jsc.JSCValueClass,
//     this: jsc.JSCValueClass,
//     argument_count: usize,
//     _arguments: [*c]const jsc.JSCValueClass,
//     except: [*c]jsc.JSCValueClass,
// ) callconv(.C) jsc.JSCValueClass {
//     _ = except; // autofix
//     _ = this; // autofix
//     _ = function; // autofix
//     const args = _arguments[0..argument_count];
//     const input: jsc.JSCValue = jsc.jsc_value_to_string(args[0]);

//     var buffer = allocator.alloc(u8, jsc.JSStringGetMaximumUTF8CStringSize(input)) catch unreachable;
//     defer allocator.free(buffer);

//     const string_length = jsc.JSStringGetUTF8CString(input, buffer.ptr, buffer.len);
//     const string = buffer[0..string_length];

//     var stdout = std.io.getStdOut();

//     stdout.writeAll(string) catch {};

//     return jsc.JSValueMakeUndefined(ctx);
// }
