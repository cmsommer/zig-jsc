pub const jsc = @import("./jsc.zig");
pub const jsc_functions = @import("./cfunctions.zig");
const types = @import("./types.zig");

const JSError = error{
    EvaluateError,
    ConvertError,
};
