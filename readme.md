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
