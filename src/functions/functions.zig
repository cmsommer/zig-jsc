const std = @import("std");
const zjsc = @import("zig-jsc");

const jsc = zjsc.c_api;

pub const JSContextRef = jsc.JSContextRef;
pub const JSContextGroupRef = jsc.JSContextGroupRef;
pub const JSStringRef = jsc.JSStringRef;
pub const JSObjectRef = jsc.JSObjectRef;
pub const JSValueRef = jsc.JSValueRef;

pub fn retainContextGroup(group: JSContextGroupRef) void {
    _ = jsc.JSContextGroupRetain(group);
}

pub fn createContextGroup() jsc.JSContextGroupRef {
    return jsc.JSContextGroupCreate();
}

pub fn createContext(context_group: jsc.JSContextGroupCreate) jsc.JSGlobalContextRef {
    const context: jsc.JSGlobalContextRef = jsc.JSGlobalContextCreateInGroup(context_group, null);
    return context;
}

pub fn getGlobalObject(context: jsc.JSGlobalContextRef) jsc.JSObjectRef {
    const global_object: jsc.JSObjectRef = jsc.JSContextGetGlobalObject(context);
    return global_object;
}

pub fn getStringMaxSize(string: jsc.JSStringRef) usize {
    return jsc.JSStringGetMaximumUTF8CStringSize(string);
}

pub fn createString(text: []const u8) jsc.JSStringRef {
    const cstr: [*c]const u8 = @ptrCast(text);
    return jsc.JSStringCreateWithUTF8CString(cstr);
}

pub fn createStringWithBuffer(string: JSStringRef, buf: [*c]u8, size: usize) usize {
    const new_size = jsc.JSStringGetUTF8CString(string, buf, size);
    return new_size;
}

pub fn createFunction(context: jsc.JSGlobalContextRef, name: jsc.JSStringRef, callback: jsc.JSObjectCallAsFunctionCallback) jsc.JSObjectRef {
    const function = jsc.JSObjectMakeFunctionWithCallback(context, name, callback);
    return function;
}

pub fn createBoolean(context: jsc.JSContextRef, value: bool) jsc.JSValueRef {
    return jsc.JSValueMakeBoolean(context, value);
}

pub fn createObject(context: jsc.JSGlobalContextRef) jsc.JSObjectRef {
    return jsc.JSObjectMake(context, null, null);
}

pub fn createUndefined(context: jsc.JSContextRef) jsc.JSValueRef {
    return jsc.JSValueMakeUndefined(context);
}

pub fn setProperty(context: jsc.JSGlobalContextRef, obj: jsc.JSObjectRef, name: jsc.JSStringRef, value: jsc.JSValueRef) void {
    jsc.JSObjectSetProperty(context, obj, name, value, jsc.kJSPropertyAttributeNone, null);
}

pub fn evaluateScript(context: jsc.JSContextRef, script: jsc.JSStringRef) jsc.JSValueRef {
    // const exp: jsc.JSValueRef = undefined;
    const ret = jsc.JSEvaluateScript(context, script, null, null, 1, null);
    // if (exp == undefined) {
    return ret;
    // }
    // return JSError.EvaluateError;
}

pub fn valueToString(context: jsc.JSContextRef, name: jsc.JSValueRef) jsc.JSStringRef {
    // const exp: jsc.JSValueRef = undefined;
    const ret = jsc.JSValueToStringCopy(context, name, null);
    // if (exp == undefined) {
    return ret;
    // }
    // return JSError.ConvertError;
}

pub fn releaseContext(context: jsc.JSGlobalContextRef) void {
    jsc.JSGlobalContextRelease(context);
}

pub fn releaseString(string: JSStringRef) void {
    jsc.JSStringRelease(string);
}

pub fn toString(context: jsc.JSContextRef, value: JSValueRef) ![:0]u8 {
    if (!jsc.JSValueIsString(context, value)) {
        return error.ConvertError;
    }

    const jsstring = jsc.JSValueToStringCopy(context, value, null);

    const count = jsc.JSStringGetLength(jsstring);

    const buffer: [*c]u8 = 0;
    const size = jsc.JSStringGetUTF8CString(jsstring, buffer, count);
    _ = size; // autofix

    const a: [:0]u8 = std.mem.span(buffer);
    return a;
}

test "Create Context" {
    const context = createContext();
    _ = context; // autofix
}
