// An X11 or Wayland clipboard belongs to a client that has to stay around to
// hand its contents over. The standard command-line clients — wl-copy, xclip and
// xsel — do exactly that from the background, so driving them gives custom-
// rendered Linux windows a real system clipboard without taking over the event
// loop sokol owns.
module ui2

import os

struct LinuxClipboardTool {
	copy  string // shell command reading the text from the file named by %s
	paste string
}

fn linux_has_executable(name string) bool {
	return (os.find_abs_path_of_executable(name) or { '' }).len > 0
}

fn linux_clipboard_tool() ?LinuxClipboardTool {
	if os.getenv('WAYLAND_DISPLAY').len > 0 && linux_has_executable('wl-copy')
		&& linux_has_executable('wl-paste') {
		return LinuxClipboardTool{
			copy:  'wl-copy < %s'
			paste: 'wl-paste --no-newline --type text'
		}
	}
	if os.getenv('DISPLAY').len == 0 {
		return none
	}
	if linux_has_executable('xclip') {
		return LinuxClipboardTool{
			copy:  'xclip -selection clipboard -in < %s'
			paste: 'xclip -selection clipboard -out'
		}
	}
	if linux_has_executable('xsel') {
		return LinuxClipboardTool{
			copy:  'xsel --clipboard --input < %s'
			paste: 'xsel --clipboard --output'
		}
	}
	return none
}

fn native_clipboard_supported() bool {
	linux_clipboard_tool() or { return false }
	return true
}

fn native_set_clipboard_text(text string) bool {
	tool := linux_clipboard_tool() or { return false }
	path := os.join_path(os.temp_dir(), 'ui2-clipboard-${os.getpid()}.txt')
	os.write_file(path, text) or { return false }
	defer {
		os.rm(path) or {}
	}
	// The tool reads the file before it forks to keep serving the selection; its
	// output goes to /dev/null so the background copy does not hold the pipe
	// this call waits on.
	command := tool.copy.replace('%s', os.quoted_path(path)) + ' >/dev/null 2>&1'
	return os.execute(command).exit_code == 0
}

fn native_clipboard_text() ?string {
	tool := linux_clipboard_tool() or { return none }
	result := os.execute(tool.paste + ' 2>/dev/null')
	if result.exit_code != 0 {
		return none
	}
	return result.output
}
