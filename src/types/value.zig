const std = @import("std");
const zjsc = @import("zig-jsc");

const jsc = zjsc.c_api;

/// A JavaScript object.
///
/// This wraps a `JSObjectRef`, and is the equivalent of `JavaScriptCore.JSValue`.
pub const Value = struct {
    context: zjsc.Context,
    valueRef: jsc.JSValueRef,

    pub fn init_copy(context: zjsc.Context, value: zjsc.Value) Value {
        return init(context, value.valueRef);
    }

    pub fn init(context: zjsc.Context, valueRef: jsc.JSValueRef) Value {
        jsc.JSValueProtect(context.contextRef, valueRef);
        return Value{
            .context = context,
            .valueRef = valueRef,
        };
    }

    /// Creates a JavaScript value of the `undefined` type.
    ///
    /// - Parameters:
    ///   - context: The execution context to use.
    pub inline fn init_undefined(context: zjsc.Context) Value {
        return init(context, jsc.JSValueMakeUndefined(context.contextRef));
    }

    /// Creates a JavaScript value of the `null` type.
    ///
    /// - Parameters:
    ///   - context: The execution context to use.
    pub fn init_null(context: zjsc.Context) Value {
        return init(context, jsc.JSValueMakeNull(context.contextRef));
    }

    /// Creates a JavaScript `Boolean` value.
    ///
    /// - Parameters:
    ///   - value: The value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_bool(value: bool, context: zjsc.Context) Value {
        return init(context, jsc.JSValueMakeBoolean(context.contextRef, value));
    }

    /// Creates a JavaScript value of the `Number` type.
    ///
    /// - Parameters:
    ///   - value: The f64 value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_number(value: f64, context: zjsc.Context) Value {
        return init(context, jsc.JSValueMakeNumber(context.contextRef, value));
    }

    /// Creates a JavaScript value of the `String` type.
    ///
    /// - Parameters:
    ///   - value: The value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_string(value: []const u8, context: zjsc.Context) Value {
        const buffer = std.heap.page_allocator.alloc(u8, value.len + 1) catch {
            @panic("cannot alloc when creating string");
        };
        const jsvalue: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString(buffer.ptr);
        defer {
            jsc.JSStringRelease(jsvalue);
        }

        return init(context, jsc.JSValueMakeString(context.contextRef, jsvalue));
    }
    pub inline fn init_function(name: []const u8, cb: jsc.JSObjectCallAsFunctionCallback, context: zjsc.Context) Value {
        return init(context, zjsc.createFunction(context.contextRef, zjsc.createString(name), cb));
    }

    pub fn release(self: Value) void {
        jsc.JSValueUnprotect(self.context.contextRef, self.valueRef);
    }

    /// Assumes value is string and return a zig u8 char string that represents it
    pub fn toString(self: Value) []u8 {
        return zjsc.toString(self.context.contextRef, self.valueRef);
    }
};

fn log(ctx: jsc.JSContextRef, function: jsc.JSObjectRef, this: jsc.JSObjectRef, argc: usize, args: [*c]const jsc.JSValueRef, exp: [*c]jsc.JSValueRef) callconv(.C) jsc.JSValueRef {
    _ = exp; // autofix
    _ = args; // autofix
    _ = argc; // autofix
    _ = this; // autofix
    _ = function; // autofix

    const out = std.io.getStdOut().writer();
    out.writeAll("log") catch {};

    return zjsc.createUndefined(ctx);
}
test "Test creation" {
    const context = zjsc.Context.init();

    const value = Value.init(context, zjsc.createNumber(context.contextRef, 10));
    const value_undefined = Value.init_undefined(context);
    const value_bool = Value.init_bool(true, context);
    const value_number = Value.init_number(5, context);
    const value_string = Value.init_string("Test", context);
    const value_null = Value.init_null(context);
    const value_function = Value.init_function("log", log, context);

    _ = value;
    _ = value_undefined;
    _ = value_bool;
    _ = value_number;
    _ = value_string;
    _ = value_null;
    _ = value_function;
}
