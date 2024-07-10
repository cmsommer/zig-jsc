const zjsc = @import("zig-jsc");

const jsc = zjsc.c_api;

pub const Object = struct {
    context: zjsc.Context,
    objectRef: jsc.JSObjectRef,

    pub inline fn init_obj(context: zjsc.Context, objectRef: jsc.JSObjectRef) Object {
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
    pub inline fn init(context: zjsc.Context) Object {
        const objectRef = jsc.JSObjectMake(context.contextRef, null, null);
        return init_obj(context, objectRef);
    }

    pub inline fn init_array(comptime T: type, arr: []T, context: zjsc.Context) Object {
        const objectRef = jsc.JSObjectMakeArray(context.contextRef, arr);
        return init_obj(context, objectRef);
    }

    /// Assume this object in a object and try to set a property on it
    pub fn setProperty(self: Object, key: []const u8, value: zjsc.Value) !void {
        const jskey = zjsc.createString(@alignCast(key));
        defer zjsc.releaseString(jskey);

        zjsc.setProperty(self.context.contextRef, self.objectRef, jskey, value.valueRef);
    }

    pub fn asValue() zjsc.Value {
        return zjsc.Value{};
    }
};
