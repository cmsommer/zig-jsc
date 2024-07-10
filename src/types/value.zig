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
    ///   - value: The value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_number(comptime T: type, value: T, context: zjsc.Context) Value {
        return init(context, jsc.JSValueMakeNumber(context.contextRef, value));
    }

    /// Creates a JavaScript value of the `String` type.
    ///
    /// - Parameters:
    ///   - value: The value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_string(value: []u8, context: zjsc.Context) Value {
        const jsvalue: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString(value);
        defer {
            jsc.JSStringRelease(value);
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
