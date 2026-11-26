const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const opts = b.addOptions();
    opts.addOption(bool, "debug_allocations", false);
    opts.addOption(bool, "enable_tracy", false);
    opts.addOption(bool, "enable_tracy_allocation", false);
    opts.addOption(bool, "enable_tracy_callstack", false);
    const sd = b.addOptions();
    sd.addOption([]const u8, "linker", "ld");
    sd.addOption([]const u8, "sysroot", "");
    sd.addOption([]const u8, "gcc_install_prefix", "");
    sd.addOption([]const u8, "rtlib", "libgcc");
    sd.addOption([]const u8, "unwindlib", "libgcc");
    const aro = b.createModule(.{ .root_source_file = b.path("aro/aro.zig") });
    aro.addOptions("build_options", opts);
    aro.addOptions("system_defaults", sd);
    const main = b.createModule(.{ .root_source_file = b.path("root.zig"), .target = target, .optimize = optimize });
    main.addImport("aro", aro);
    main.addOptions("build_options", opts);
    const exe = b.addExecutable(.{ .name = "translate-c", .root_module = main });
    b.installArtifact(exe);
}
