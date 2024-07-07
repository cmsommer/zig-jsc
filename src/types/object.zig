const root = @import("zig-jsc");

const jsc = root.jsc_c_api;
const types = root.jsc_types;

/// Creates a JavaScript `Object`.
///
/// - Parameters:
///   - context: The execution context to use.
pub inline fn init_object(context: types.Context) types.Value {
    return init(context, jsc.JSObjectMake(context.contextRef, null, null));
}

const Object = struct {
    /// Assume this object in a object and try to set a property on it
    pub fn setProperty(self: Object, key: []const u8, value: types.Value) !void {
        if (!jsc.JSValueIsObject(self.context.contextRef, self.valueRef))
            return error.ConvertError;

        const jskey = function.createString(@alignCast(key));
        defer function.releaseString(jskey);

        const obj = jsc.JSValueToObject(self.context.contextRef, self.valueRef, null);

        function.setProperty(self.context.contextRef, obj, jskey, value.valueRef);
    }

    pub fn toValue() {
        
    }
};
