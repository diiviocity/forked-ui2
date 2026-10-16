# GPUI Kit component migration

This is a first portable migration, not complete GPUI Kit parity. It compares
UI2 at `15709bb28ddb4a05c499f52936a11cf0feedb22d` with
[GPUI Kit](https://github.com/longbridge/gpui-kit) at
`1b6059c13315dc5c304759ad3aa666e0b6e301d8`.

## Added components

All constructors return `!Element`, validate finite/non-negative frame
geometry, and compose existing UI2 elements rather than introducing renderer
kinds or a Rust dependency. Their child frames are parent-local.

| GPUI Kit concept | UI2 API | Behavior in this migration |
| --- | --- | --- |
| Badge | `badge(BadgeConfig)` | Text, capped counters, zero visibility, dot display |
| Avatar | `avatar(AvatarConfig)` | Image or Unicode-scalar first/last initials |
| Tag | `tag(TagConfig)` | Solid/outline styling, optional dismiss action |
| Separator | `separator(SeparatorConfig)` | Horizontal/vertical, bounded thickness |
| Skeleton | `skeleton(SkeletonConfig)` | Static rounded or centered circular placeholder |
| Kbd | `kbd(KbdConfig)` | Display-only keyboard shortcut hint |
| Link | `link(LinkConfig)` | Button activation with application-owned navigation |
| Alert | `inline_alert(InlineAlertConfig)` | Inline title/message and optional dismiss action; `alert()` remains the OS message box |
| Empty | `empty_state(EmptyStateConfig)` | Empty-state text and optional primary action |
| GroupBox | `group_box(GroupBoxConfig)` | Labeled border and padded content body |
| DescriptionList | `description_list(DescriptionListConfig)` | Two-column term/value rows |
| Collapsible | `collapsible(CollapsibleConfig)` | Controlled disclosure; closed content unmounted |
| Breadcrumb | `breadcrumb(BreadcrumbConfig)` | Stable item keys, disabled items, non-actionable current location |
| Pagination | `pagination(PaginationConfig)` | Controlled page navigation, page windows, compact mode |

The display and container builders are new V implementations following the
catalog's concepts. The pagination state/window algorithm is adapted from
`crates/base/src/pagination.rs`; see the [attribution](../third_party/gpui-kit/NOTICE.md)
and Apache-2.0 license. Existing UI2 code remains under its existing license.

## Added primitives

`ComponentSize` and `component_metrics` supply small/medium/large metrics.
`ComponentTheme`, `ComponentTone`, and `component_theme(dark)` provide explicit,
immutable semantic color tokens. Pass the same theme to related components;
there is no global theme singleton. `component_inset` safely pads a `Rect`,
preserving its coordinate space and clamping padding for tiny frames.

`PaginationState` contains normalized, immutable controlled state. It clamps
empty totals to one page, rejects disabled/current/out-of-range transitions,
and exposes `items()`, `previous_page()`, `next_page()`, and `request_page()`.
The requested visible window is clamped to 5..100; total pages are not capped.
Ellipses expose half-open hidden ranges, so clients can implement their own
jump UI without allocating a list for every page in the dataset.

```v
state := ui2.pagination_state(5, 1000).with_visible_pages(7)
pages := ui2.pagination(
    id: 'results'
    frame: ui2.rect(20, 20, 420, 40)
    state: state
    theme: ui2.component_theme(false)
) or { panic(err) }
```

In the application's event handler, decode and validate the action against
its **current** state, then store the returned page and rebuild:

```v
if page := ui2.pagination_page_from_action('results', state, event) {
    // Update the model's current page, preserving its theme/window preferences.
    // Rebuild pagination with pagination_state(page, state.total_pages()).
    println('Requested page ${page}')
}
```

The decoder rejects unrelated IDs, malformed digits, integer overflow,
leading-zero encodings, disabled state, and invalid destinations. Previous,
next, and numbered controls all use the same action encoding. The current page
is an enabled button marked `current` (a disabled one is dimmed and announced as
unavailable by native backends); activating it decodes to nothing. Ellipses are
labels in this version, not clickable page-jump menus.

## Identity and state

Interactive components require a non-empty `id`. Internal actionable parts
reserve `${id}:component:` for their mounted IDs; application children must
not reuse that namespace. Action IDs are separate: tag/alert/empty-state
buttons use the configured action; collapsible defaults to its root ID;
breadcrumb entries default to the item ID. Generated children are anonymous
where lookup is unnecessary. Each constructor checks the resulting subtree
with `validate_element_tree`; the renderer still validates the complete tree.

Handle a disclosure or dismiss event in application state and rebuild. No
builder mutates a model or creates timers. Collapsible removes its body while
closed, so local native edits/focus in that body are not retained. Group-box
and collapsible children are positioned relative to their body, not the root.
Application-supplied child geometry is not automatically resized or clipped
by these builders beyond the existing backend's behavior.

Button text is centered in its frame on every backend, so give a link a frame
sized to its text. UI2 has no backend-neutral text measurement, so breadcrumb
items are sized from an estimate of their label width and packed from the
left, shrinking evenly when the trail does not fit.

Accessibility roles, labels, and current/expanded state are attached to the
resulting elements. This is metadata, not a claim of GPUI's AccessKit parity;
keyboard behavior and native accessibility mapping remain backend-dependent.
AppKit exposes `group`, `navigation`, `status` and `alert` as `AXGroup`,
`separator` as `AXSplitter` and `img` as `AXImage`.
Images use the existing image implementation: initials are chosen only when
`image_path` is empty, not after a load failure. Image masking also depends on
the backend. Skeletons do not shimmer; keyboard hints do not register shortcuts;
links never automatically launch a URL. Display strings are application-owned;
pagination's built-in accessibility strings are currently English.

These are V APIs. This migration does not add VML tags, compiled-VML lowering,
or C ABI constructors for the new components.

## Existing counterparts retained

UI2 already provides buttons, checkboxes, switches, sliders, text input,
dropdowns, progress bars, charts, accordion, carousel, tabbed panel, tree view,
menus, tooltips, modal view, popup, animation, and several layout families.
They are retained rather than replaced by parallel implementations. These are
counterparts, not assertions that every GPUI option or interaction is present.
The existing `spinner` is a selection control, not a GPUI loading indicator.

## Remaining migration work

Not implemented here: virtual lists/tables and selection models; dock and
resizable panel persistence; command/searchable lists and advanced comboboxes;
calendar/date/time/color pickers; loading spinner/shimmer; toast lifecycle,
hover-card/popover/sheet focus management; radio/rating/stepper; forms and
settings; toolbars/sidebars/status bars; attachment/message/questionnaire/speech
components; Markdown/HTML, diff, syntax highlighting and LSP; icon assets;
platform focus traps and full accessibility parity. GPUI's application/runtime,
WebAssembly and JavaScript extension infrastructure are not part of this port.
These larger features need their own renderer/input work and behavior tests;
this change deliberately does not add placeholders claiming they are supported.

## Verification and gallery

With V 0.5.2+ and the repository's normal native dependencies installed:

```sh
v test ui/component_catalog_test.v
v run examples/component_catalog/main.v
# macOS/Windows custom renderer:
v -d ui2_custom_rendering test ui/component_catalog_test.v
v -d ui2_custom_rendering run examples/component_catalog/main.v
```

The gallery exercises all 14 additions, themes, dismiss actions, disclosure,
breadcrumb navigation events and pagination. The regression suite covers
identity, disabled/action behavior, invalid and tiny geometry, Unicode initials,
page-window coverage, large totals and malicious action payloads. The existing
CI matrix now runs that suite and builds the gallery with the other examples.
Manual visual/keyboard/screen-reader testing is still required on each backend.
