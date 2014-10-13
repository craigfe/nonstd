Non-standard Mini-Library
=========================

*“In the presence of a [good](http://opam.ocaml.org/) package manager; standard
libraries are an obsolete concept.”*

This library is an extremely minimalistic library to `open`:

- `val (|>)` (for compatibility with older versions of OCaml),
- `include` [`Printf`](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Printf.html),
- A `List` module (similar to [Core](http://github.com/janestreet/core)'s one),
- `Array` is [`ArrayLabels`](http://caml.inria.fr/pub/docs/manual-ocaml/libref/ArrayLabels.html),
- Minimalistic `Option` module,
- Basic `Int` and `Float` modules.

and that's all, no dependencies, no blobs.

