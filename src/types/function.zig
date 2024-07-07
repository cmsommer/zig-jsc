const root = @import("zig-jsc");

const jsc = root.jsc_c_api;
const types = root.jsc_types;

const Function = struct {
    context: jsc.ContextRef,
    valueRef: jsc.JSValueRef,

    pub fn init(name: []const u8, callback: root.JSCallback, context: types.Context) Function {
        const jsname = Function.createString(@alignCast(name));
        defer Function.releaseString(jsname);

        jsc.JSValueProtect(context.contextRef, valueRef);
        return Function{
            .context = context,
            .valueRef = valueRef,
        };
    }

    pub fn cb(self: Function, ctx: jsc.JSContextRef, func: jsc.JSObjectRef, this: jsc.JSObjectRef, count: usize, args: [*c]const jsc.JSValueRef, exp: [*c]jsc.JSValueRef) callconv(.C) jsc.JSValueRef {
        const ctxWrap = types.Context.init_wrap(ctx);
        const funcWrap = types.Value.init(func);
        const thisWrap = types.Value.init(this);
        // const argsWrap = args: [*c]const jsc.JSValueRef,
        // const expWrap = exp: [*c]jsc.JSValueRef

        return callback(ctxWrap, funcWrap, thisWrap, args, exp);
    }
};
