const std = @import("std");

/// We draw vertical guide bars per depth. Adjust if trees can be deeper.
const MAX_DEPTH: usize = 128;
const Guides = [MAX_DEPTH]bool;

/// A tiny AST: either a number (leaf) or an `add` node with two children.
const Node = union(enum) {
    number: i32,
    add: struct {
        left: *Node,
        right: *Node,
    },
};

/// Prints the textual label for a node.
/// number(v) -> "number(v)"
/// add       -> "add"
fn printNodeLabel(n: *const Node) void {
    switch (n.*) {
        .number => |v| std.debug.print("number({d})\n", .{v}),
        .add => std.debug.print("add\n", .{}),
    }
}

/// Print indentation up to `depth`, using `guides[i]` to decide
/// whether a vertical bar "|  " must be drawn at level `i`.
fn printIndent(guides: *const Guides, depth: usize) void {
    var i: usize = 0;
    while (i < depth) : (i += 1) {
        if (guides.*[i]) {
            std.debug.print("|  ", .{});
        } else {
            std.debug.print("   ", .{});
        }
    }
}

/// Recursively print the children of `n` as an ASCII tree.
/// Invariant:
///   guides[d] == true  -> there are more siblings at depth `d` still to come,
///                         so descendants must render a vertical guide at column `d`.
fn printChildren(n: *const Node, guides: *Guides, depth: usize) void {
    // Collect this node's children as a slice of pointers.
    const children: []const *const Node = switch (n.*) {
        .number => &[_]*const Node{}, // leaf: no children
        .add => |b| &[_]*const Node{ b.left, b.right },
    };

    // Iterate with indices to know if a child is the last one.
    for (children, 0..) |child, idx| {
        const is_last = idx == children.len - 1;

        // 1) Indentation for all ancestor depths.
        printIndent(guides, depth);

        // 2) Branch connector at this depth.
        std.debug.print("{s}", .{if (is_last) "└── " else "├── "});

        // 3) Child label itself.
        printNodeLabel(child);

        // 4) Let descendants know if a guide bar must continue at `depth`.
        //    Use `defer` to restore the previous state on return,
        //    which makes the control flow easier to reason about.
        const prev = guides.*[depth];
        guides.*[depth] = !is_last; // continue bar if there are more siblings later
        defer guides.*[depth] = prev;

        // 5) Recurse into the child's subtree.
        printChildren(child, guides, depth + 1);
    }
}

/// Entry point for printing a whole tree: print root label, then its children.
fn printAstTree(root: *const Node) void {
    var guides = std.mem.zeroes(Guides); // all guide bars are initially off
    printNodeLabel(root);
    printChildren(root, &guides, 0);
}

pub fn main() !void {
    // Build the sample tree: (((1 + 2) + (3 + 4)) + 5)
    var n1 = Node{ .number = 1 };
    var n2 = Node{ .number = 2 };
    var n3 = Node{ .number = 3 };
    var n4 = Node{ .number = 4 };
    var add1 = Node{ .add = .{ .left = &n1, .right = &n2 } };
    var add2 = Node{ .add = .{ .left = &n3, .right = &n4 } };
    var add3 = Node{ .add = .{ .left = &add1, .right = &add2 } };
    var n5 = Node{ .number = 5 };
    var root = Node{ .add = .{ .left = &add3, .right = &n5 } };

    printAstTree(&root);
}
