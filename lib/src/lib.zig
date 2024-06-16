const jsc = @import("./jsc.zig");

pub fn createContext() void {
    const context_group: jsc.JSContextGroupRef = jsc.JSContextGroupCreate();
    const context: jsc.JSGlobalContextRef = jsc.JSGlobalContextCreateInGroup(context_group, null);
    return context;
}
