// Android has no file picker a NativeActivity app can reach without a JVM
// callback this layer does not install, so open and save dialogs are
// unavailable. The _android file suffix is what keeps this compiling: V
// claims every _nix file for Android too, and file_dialog_nix's body is
// spelled out for the desktops, so without an os-specific file of its own
// the dialog's functions would not exist at all on Android.
module ui2

fn native_file_dialog_supported() bool {
	return false
}

fn native_file_dialog(cfg FileDialogConfig) []string {
	eprintln('ui2: native file dialogs are unavailable on this target')
	return []string{}
}
