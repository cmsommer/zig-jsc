const functions = @import("./functions.zig");
pub const jsc_types = @import("./types.zig");

pub const jsc_c_api = functions.c_api;
pub const jsc_functions = functions.functions;

pub const JSCallback = fn (jsc_types.Context, jsc_types.Value, jsc_types.Value, usize, []jsc_types.Value, []jsc_types.Value) jsc_types.Value;

pub const JSError = error{
    EvaluateError,
    ConvertError,
};
