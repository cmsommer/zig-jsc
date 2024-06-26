const std = @import("std");
const root = @import("root");

const jsc = root.jsc;

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
        return VM{
            .groupRef = jsc.JSContextGroupCreate(),
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
const Configuration = struct {
    /// Whether scripts evaluated by this context should be assessed in `strict` mode. Defaults to `true`.
    strict: bool,

    // /// The script loader to use for loading JavaScript script files. If the loader vends a non-nil `didChange` listener collection, dynamic reloading will be enabled.
    // scriptLoader: JXScriptLoader

    /// The logging function to use for JX log messages.
    log: fn (text: []u8) void,

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
    pub fn init_log(comptime log: fn ([]u8) void) Configuration {
        return Configuration{
            .strict = true,
            // self.scriptLoader = scriptLoader ?? DefaultScriptLoader(),
            .log = log,
        };
    }
};

pub const Context = struct {
    /// The virtual machine associated with this context
    vm: VM,

    /// Context confguration.
    configuration: Configuration,

    /// The underlying `JSGlobalContextRef` that is wrapped by this context
    contextRef: jsc.JSGlobalContextRef,

    /// Creates `Context`. `Value` references may be used interchangably with multiple instances of `Context` with the same `VM`, but sharing between  separate `VM`s will result in undefined behavior.
    ///
    /// - Parameters:
    ///   - configuration: Context configuration.
    pub fn init(configuration: Configuration) Context {
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

    pub fn release(self: Context) void {
        jsc.JSGlobalContextRelease(self.contextRef);
    }

    // /// For use by service providers only.
    // public var spi: JXContextSPI?
};
