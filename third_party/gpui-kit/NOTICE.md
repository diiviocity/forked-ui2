# GPUI Kit attribution

Source: https://github.com/longbridge/gpui-kit
Revision: `1b6059c13315dc5c304759ad3aa666e0b6e301d8`
Copyright 2024 - 2026 Longbridge <https://longbridge.com>

`ui/pagination.v` adapts the controlled pagination behavior and page-window
algorithm from `crates/base/src/pagination.rs`. The V implementation changes
types and error handling, caps visible-page allocation, adds guarded action
encoding/decoding, and renders through UI2's existing elements.
`ui/component_catalog_test.v` includes adapted pagination behavior tests and
new UI2 regression tests. These two files are distributed under Apache-2.0;
the complete license is in `LICENSE-APACHE` alongside this notice.

The other component implementations are new V code following the GPUI Kit
catalog's concepts, not copied Rust renderers. They and the new example and
documentation use UI2's existing MIT license. No GPUI Kit assets or runtime
are included, and this addition does not change the license of existing UI2
files.
