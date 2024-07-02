const std = @import("std");
const root = @import("zig-jsc");

const jsc = root.jsc_c_api;
const types = root.jsc_types;
const function = root.jsc_functions;

/// A JavaScript object.
///
/// This wraps a `JSObjectRef`, and is the equivalent of `JavaScriptCore.JSValue`.
pub const Value = struct {
    context: types.Context,
    valueRef: jsc.JSValueRef,

    pub fn init_copy(context: types.Context, value: types.Value) Value {
        return init(context, value.valueRef);
    }

    pub fn init(context: types.Context, valueRef: jsc.JSValueRef) Value {
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
    pub fn init_undefined(context: types.Context) Value {
        return init(context, jsc.JSValueMakeUndefined(context.contextRef));
    }

    /// Creates a JavaScript value of the `null` type.
    ///
    /// - Parameters:
    ///   - context: The execution context to use.
    pub fn init_null(context: types.Context) Value {
        return init(context, jsc.JSValueMakeNull(context.contextRef));
    }

    /// Creates a JavaScript `Boolean` value.
    ///
    /// - Parameters:
    ///   - value: The value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_bool(value: bool, context: types.Context) Value {
        return init(context, jsc.JSValueMakeBoolean(context.contextRef, value));
    }

    /// Creates a JavaScript value of the `Number` type.
    ///
    /// - Parameters:
    ///   - value: The value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_number(comptime T: type, value: T, context: types.Context) Value {
        return init(context, jsc.JSValueMakeNumber(context.contextRef, value));
    }

    /// Creates a JavaScript value of the `String` type.
    ///
    /// - Parameters:
    ///   - value: The value to assign to the object.
    ///   - context: The execution context to use.
    pub fn init_string(value: []u8, context: types.Context) Value {
        const jsvalue: jsc.JSStringRef = jsc.JSStringCreateWithUTF8CString(value);
        defer {
            jsc.JSStringRelease(value);
        }

        return init(context, jsc.JSValueMakeString(context.contextRef, jsvalue));
    }

    /// Creates a JavaScript `Object`.
    ///
    /// - Parameters:
    ///   - context: The execution context to use.
    pub fn init_object(context: types.Context) Value {
        return init(context, jsc.JSObjectMake(context.contextRef, null, null));
    }

    pub fn init_function(name: []const u8, callback: root.JSCallback, context: types.Context) Value {
        const jsname = function.createString(@alignCast(name));
        defer function.releaseString(jsname);

        const cb = fn (ctx: jsc.JSContextRef, func: jsc.JSObjectRef, this: jsc.JSObjectRef, count: usize, args: [*c]const jsc.JSValueRef, exp: [*c]jsc.JSValueRef) callconv(.C) jsc.JSValueRef{
            const c = types.Context.init()
            return callback()
        };

        return init(context, function.createFunction(context.contextRef, jsname, cb));
    }

    /// Assume this object in a object and try to set a property on it
    pub fn setProperty(self: Value, key: []const u8, value: Value) !void {
        if (!jsc.JSValueIsObject(self.context.contextRef, self.valueRef))
            return error.ConvertError;

        const jskey = function.createString(@alignCast(key));
        defer function.releaseString(jskey);

        const obj = jsc.JSValueToObject(self.context.contextRef, self.valueRef, null);

        function.setProperty(self.context.contextRef, obj, jskey, value.valueRef);
    }

    pub fn release(self: Value) void {
        jsc.JSValueUnprotect(self.context.contextRef, self.valueRef);
    }

    /// Assumes value is string and return a zig u8 char string that represents it
    pub fn toString(self: Value) []u8 {
        if (!jsc.JSValueIsString(self.context.contextRef, self.valueRef)) {
            return error.ConvertError;
        }

        const count = jsc.JSStringGetLength(self);
        const buffer: [*c]u8 = [count]u8{};

        const size = jsc.JSStringGetUTF8CString(self.valueRef, buffer, count);
        _ = size; // autofix

        return @ptrCast(buffer);
    }
};
