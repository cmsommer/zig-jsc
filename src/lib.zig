const jsc = @import("jsc.zig");

pub const JSContextRef = jsc.JSContextRef;
pub const JSStringRef = jsc.JSStringRef;
pub const JSObjectRef = jsc.JSObjectRef;
pub const JSValueRef = jsc.JSValueRef;

const JSError = error{
    EvaluateError,
    ConvertError,
};

pub fn createContext() jsc.JSGlobalContextRef {
    const context_group: jsc.JSContextGroupRef = jsc.JSContextGroupCreate();
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

pub fn createString(text: [*c]const u8) jsc.JSStringRef {
    const string = jsc.JSStringCreateWithUTF8CString(text);
    return string;
}

pub fn createStringWithBuffer(string: JSStringRef, buf: [*c]u8, size: usize) usize {
    const new_size = jsc.JSStringGetUTF8CString(string, buf, size);
    return new_size;
}

pub fn createFunction(context: jsc.JSGlobalContextRef, name: jsc.JSStringRef, callback: jsc.JSObjectCallAsFunctionCallback) jsc.JSObjectRef {
    const function = jsc.JSObjectMakeFunctionWithCallback(context, name, callback);
    return function;
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

test "Create Context" {
    const context = createContext();
    _ = context; // autofix
}
