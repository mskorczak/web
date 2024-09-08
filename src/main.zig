const std = @import("std");
const zap = @import("zap");
const Allocator = std.mem.Allocator;
//fn dispatch_routes(r: zap.Request) void {
//    if (r.path) |the_path| {
//        std.debug.print("PATH: {s}\n", .{the_path});
//   }
//
//    if (r.query) |the_query| {
//       std.debug.print("QUERY: {s}\n", .{the_query});
//    }
//    if (r.path) |path| {
//        if (routes.get(path)) |method| {
//           method(r);
//            return;
//        }
//    }
//    r.setStatus(.not_found);
//   r.sendBody("404 - File not found") catch return;
//}

pub const JungleRouter = struct {
    const Self = @This();
    allocator: Allocator,

    pub fn init(allocator: Allocator) Self {
        return .{ .allocator = allocator };
    }
    pub fn index(self: *Self, req: zap.Request) void {
        std.log.warn("index", .{});

        const string = std.fmt.allocPrint(
            self.allocator,
            "Test",
            .{},
        ) catch return;
        defer self.allocator.free(string);
        req.sendFile("src/public/index.html") catch return;
    }

    pub fn home(self: *Self, req: zap.Request) void {
        std.log.warn("home", .{});

        const string = std.fmt.allocPrint(
            self.allocator,
            "HOME!!!",
            .{},
        ) catch return;
        defer self.allocator.free(string);
        req.sendBody(string) catch return;
    }

    //pub fn blog(self: *Self, req: zap.Request) void {
    //    std.log.warn("blog", .{});
    //   const template =
    //    \\ {{=<< >>=}}
    //    \\ * Files:
    //    \\ <<#files>>
    //    \\ <<<& name>> (<<name>>)
    //    \\ <</files>>
    //    ;
    //    var mustache = Mustache.fromData(template) catch return;
    //    defer mustache.deinit();
    //}

};

//fn route_git() void {}
//fn route_blog() void {}
//fn route_resume() void {}
//fn route_contact() void {}

fn not_found(req: zap.Request) void {
    req.sendBody("404 - Not Found") catch return;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();
    var router = zap.Router.init(allocator, .{
        .not_found = not_found,
    });
    defer router.deinit();
    var jungle_router = JungleRouter.init(allocator);
    try router.handle_func("/", &jungle_router, &JungleRouter.index);
    try router.handle_func("/home", &jungle_router, &JungleRouter.home);
    var listener = zap.HttpListener.init(.{ .port = 3000, .on_request = router.on_request_handler(), .log = true, .max_clients = 100000, .public_folder = "src/public" });
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    zap.start(.{
        .threads = 2,
        .workers = 1, // 1 worker enables sharing state between threads
    });
}
