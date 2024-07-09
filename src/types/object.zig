const root = @import("zig-jsc");

const jsc = root.jsc_c_api;
const types = root.jsc_types;
const function = root.jsc_functions;

pub inline fn init_obj(context: types.Context, objectRef: jsc.JSObjectRef) Object {
    jsc.JSValueProtect(context.contextRef, objectRef);
    return Object{
        .context = context,
        .objectRef = objectRef,
    };
}

/// Creates a JavaScript `Object`.
///
/// Parameters:
/// - context: The execution context to use.
pub inline fn init(context: types.Context) Object {
    const objectRef = jsc.JSObjectMake(context.contextRef, null, null);
    return init_obj(context, objectRef);
}

pub inline fn init_array(context: types.Context, arr: []) Object {
    const objectRef = jsc.JSObjectMakeArray(context.contextRef, );
    return init_obj(context, objectRef);
}

const Object = struct {
    context: jsc.ContextRef,
    objectRef: jsc.JSObjectRef,

    /// Assume this object in a object and try to set a property on it
    pub fn setProperty(self: Object, key: []const u8, value: types.Value) !void {
        const jskey = function.createString(@alignCast(key));
        defer function.releaseString(jskey);

        const obj = jsc.JSValueToObject(self.context.contextRef, self.valueRef, null);

        function.setProperty(self.context.contextRef, obj, jskey, value.valueRef);
    }

    pub fn asValue() types.Value {
        return types.Value{};
    }
};
