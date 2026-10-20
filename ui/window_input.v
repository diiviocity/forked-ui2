@[has_globals]
module ui2

// window_input.v holds the platform-neutral state of the window input hooks. The custom
// renderer delivers pointer moves and draws the menu bar from it; native backends
// accept the calls and do not act on them yet.

__global g_pointer_move_handler = PointerMoveFn(unsafe { nil })
__global g_menu_bar_hidden = false

// on_pointer_move reports every pointer move over the window, wherever it lands, in
// logical units. The custom renderer delivers it; native backends do not yet.
pub fn on_pointer_move(handler PointerMoveFn) {
	g_pointer_move_handler = handler
}

// set_menu_bar_hidden hides the menu bar in the custom renderer: it takes no room,
// draws nothing and takes no clicks. Native menu bars are not hidden.
pub fn set_menu_bar_hidden(hidden bool) {
	g_menu_bar_hidden = hidden
}

// menu_bar_hidden reports the state set by set_menu_bar_hidden.
pub fn menu_bar_hidden() bool {
	return g_menu_bar_hidden
}
