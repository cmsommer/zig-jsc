const functions = @import("./functions.zig");
const jsc_types = @import("./types.zig");

pub usingnamespace jsc_types;
pub usingnamespace functions.functions;

pub const c_api = functions.c_api;
pub const JSCallback = fn (jsc_types.Context, jsc_types.Value, jsc_types.Value, usize, []jsc_types.Value, []jsc_types.Value) jsc_types.Value;
pub const JSError = error{
    EvaluateError,
    ConvertError,
};
