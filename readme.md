# AST Tree Printer in Zig

This project implements a simple Abstract Syntax Tree (AST) structure in Zig and prints it as an ASCII tree.

- The AST consists of two node types: `number` (leaf node) and `add` (internal node with two children).
- The sample tree built in `main.zig` is: `(((1 + 2) + (3 + 4)) + 5)`.
- The tree is printed using a pre-order depth-first traversal, with ASCII branches and indentation to visualize the hierarchy.
- The code demonstrates recursive tree traversal, dynamic indentation, and branch drawing using a boolean array to track vertical guides.
- Output:

```
add
├── add
|  ├── add
|  |  ├── number(1)
|  |  └── number(2)
|  └── add
|     ├── number(3)
|     └── number(4)
└── number(5)
```

This is useful for visualizing tree structures, such as ASTs, in a readable text format.

## Explanation (what the algorithm does)

* The tree is printed with a **pre‑order depth‑first traversal**: print the current node first, then its children.
* To draw nice ASCII branches, we keep a boolean array (called `guides` in the code) where
  `guides[d] == true` means: “at **depth d**, there are still **unprinted siblings** to the right,”
  so descendants must render a vertical guide `"|  "` in that column.
* For each child of the current node:

  1. Determine if it’s the **last** child (`is_last`).
  2. Print indentation by scanning all ancestor depths `0 ..< depth` and outputting `"|  "` if `guides[i]` is `true`, otherwise spaces `"   "`.
  3. Print the branch connector: `"├── "` if not last, or `"└── "` if last.
  4. Print the child’s label (`add` or `number(v)`).
  5. Update `guides[depth] = !is_last` so descendants know whether to keep a vertical guide at this level.
  6. Recurse into the child with `depth + 1`.

* **Time complexity** is `O(N)` where `N` is the number of nodes; each node is visited once.

## Code

```zig
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
        guides.*[depth] = !is_last;

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
```

