const std = @import("std");
const zjsc = @import("zig-jsc");

const jsc = zjsc.c_api;

/// Type similar to `Combine.Cancellable` that is used to cancel subscriptions to events.
pub const Cancellable = struct {
    cancelHandler: fn () void,

    pub fn init(cancelFn: fn () void) Cancellable {
        return Cancellable{
            .cancelHandler = cancelFn,
        };
    }

    pub fn deinit() void {
        cancel();
    }

    /// Cancel the associated event subscription.
    pub fn cancel(self: Cancellable) void {
        self.cancelHandler();
    }
};

/// Configure the default configuration for new contexts.
pub const VM = struct {
    groupRef: jsc.JSContextGroupRef,

    pub fn init() VM {
        const group = jsc.JSContextGroupCreate();
        return VM{
            .groupRef = group,
        };
    }

    pub fn init_with_group(groupRef: jsc.JSContextGroupRef) VM {
        jsc.JSContextGroupRetain(groupRef);
        return VM{
            .groupRef = groupRef,
        };
    }

    pub fn release(self: VM) void {
        jsc.JSContextGroupRelease(self.groupRef);
    }
};

/// Context configuration.
pub const Configuration = struct {
    /// Whether scripts evaluated by this context should be assessed in `strict` mode. Defaults to `true`.
    strict: bool,

    // /// The script loader to use for loading JavaScript script files. If the loader vends a non-nil `didChange` listener collection, dynamic reloading will be enabled.
    // scriptLoader: JXScriptLoader

    /// The logging function to use for JX log messages.
    // log: fn (text: []u8) void,

    /// Whether dynamic reloading of JavaScript script resources is enabled.
    pub fn is_dynamic_reload_enabled() bool {
        // return scriptLoader.didChange != null;
        return false;
    }

    pub fn init() Configuration {
        return Configuration{
            .strict = true,
            // self.scriptLoader = scriptLoader ?? DefaultScriptLoader(),
            // .log = fn (text: []u8) void{std.debug.print("{}", .{text})},
        };
    }

    pub fn init_strict(strict: bool) Configuration {
        // const log = fn (text: []u8) void{std.debug.print("{}", .{text})};
        return Configuration{
            .strict = strict,
            // self.scriptLoader = scriptLoader ?? DefaultScriptLoader(),
            // .log = log,
        };
    }
    // pub fn init_log(comptime log: fn ([]u8) void) Configuration {
    //     return Configuration{
    //         .strict = true,
    //         // self.scriptLoader = scriptLoader ?? DefaultScriptLoader(),
    //         .log = log,
    //     };
    // }
};

pub const Context = struct {
    /// The virtual machine associated with this context
    vm: VM,

    /// Context confguration.
    configuration: Configuration,

    /// The underlying `JSGlobalContextRef` that is wrapped by this context
    contextRef: jsc.JSGlobalContextRef,

    /// Creates `Context`. `Value` references may be used interchangably with multiple instances of `Context` with the same `VM`, but sharing between  separate `VM`s will result in undefined behavior.
    pub inline fn init() Context {
        const vm = VM.init();
        const configuration = Configuration.init();

        return Context{
            .vm = vm,
            .contextRef = jsc.JSGlobalContextCreateInGroup(vm.groupRef, null),
            .configuration = configuration,
        };
    }

    /// Creates `Context`. `Value` references may be used interchangably with multiple instances of `Context` with the same `VM`, but sharing between  separate `VM`s will result in undefined behavior.
    ///
    /// - Parameters:
    ///   - configuration: Context configuration.
    pub fn init_with_configuration(configuration: Configuration) Context {
        const vm = VM.init();
        return Context{
            .vm = vm,
            .contextRef = jsc.JSGlobalContextCreateInGroup(vm.groupRef, null),
            .configuration = configuration,
        };
    }

    /// Creates `Context` with the given `VM`. `Value` references may be used interchangably with multiple instances of `Context` with the same `VM`, but sharing between  separate `VM`s will result in undefined behavior.
    ///
    /// - Parameters:
    ///   - vm: The shared virtual machine to use; defaults  to creating a new VM per context.
    ///   - configuration: Context configuration.
    pub fn init_with_vm(vm: VM, configuration: Configuration) Context {
        return Context{
            .vm = vm,
            .contextRef = jsc.JSGlobalContextCreateInGroup(vm.groupRef, null),
            .configuration = configuration,
        };
    }
    pub fn init_wrap(context: jsc.ContextRef) Context {
        const vm = zjsc.VM.init_with_group(jsc.JSContextGetGroup(context));
        const configuration = Configuration.init();

        return Context{
            .vm = vm,
            .contextRef = context,
            .configuration = configuration,
        };
    }

    pub fn release(self: Context) void {
        jsc.JSGlobalContextRelease(self.contextRef);
    }

    // /// For use by service providers only.
    // public var spi: JXContextSPI?

    pub fn getGlobal(self: Context) zjsc.Object {
        return zjsc.Object.init_obj(self, jsc.JSContextGetGlobalObject(self.contextRef));
    }

    /// Creates a JavaScript value of the `undefined` type.
    pub fn createUndefined(self: zjsc.Context) zjsc.Value {
        return zjsc.Value.init_undefined(self);
    }

    /// Creates a JavaScript value of the `null` type.
    pub fn createNull(self: zjsc.Context) zjsc.Value {
        return zjsc.Value.init_null(self);
    }

    /// Creates a JavaScript `Boolean` value.
    pub fn createBool(self: zjsc.Context, value: bool) zjsc.Value {
        return zjsc.Value.init_bool(value, self);
    }

    /// Creates a JavaScript value of the `Number` type.
    pub fn createNumber(self: zjsc.Context, comptime T: type, value: T) zjsc.Value {
        return zjsc.Value.init_number(value, self);
    }

    /// Creates a JavaScript value of the `String` type.
    pub fn createString(self: zjsc.Context, value: []u8) zjsc.Value {
        return zjsc.Value.init_string(value, self);
    }

    /// Creates a JavaScript `Object`.
    pub fn createObject(self: Context) zjsc.Value {
        return zjsc.Object.init(self);
    }

    pub fn createFunction(self: Context, name: []const u8, callback: jsc.JSObjectCallAsFunctionCallback) zjsc.Value {
        return zjsc.Value.init_function(name, callback, self);
    }

    pub fn setProperty(object: zjsc.Value, name: []const u8, value: zjsc.Value) void {
        object.setProperty(name, value);
    }

    pub fn evaluateScript(self: Context, script: []const u8) zjsc.Value {
        const jsscript = zjsc.createString(@alignCast(script));
        defer zjsc.releaseString(jsscript);

        return zjsc.Value.init(self, zjsc.evaluateScript(self.contextRef, jsscript));
    }
};
