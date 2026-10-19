import ui2

fn build() ui2.Element {
	return ui2.screen(0x1a1a2e, [
		ui2.label('', 'OpenGL Widget (draws circle)', ui2.rect(20, 20, 400, 30), ui2.TextStyle{
			color: 0xffffff
			size: 18
			bold: true
		}),
		// Simple OpenGL widget: external GL surface that draws a circle.
		ui2.opengl('gl_surface', ui2.rect(20, 100, 300, 300)),
	])
}

fn main() {
	ui2.run_window('OpenGL Circle', 400, 500, build, fn (_ string) {})
}
