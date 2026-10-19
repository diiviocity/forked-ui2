// vfmt off
@[has_globals]
module ui2

// gl_surface.v is the platform-neutral side of `opengl` elements. The gg renderer
// draws them, and native backends show them as transparent views, so applications
// can call these functions on every platform.

// GlTextureRequest names a GL texture that the application renders into for one
// `opengl` element. The texture stays owned by the application.
pub struct GlTextureRequest {
pub:
	gl_texture u32
	width      int
	height     int
}

__global g_gl_surface_renderer = GlSurfaceFn(unsafe { nil })
__global g_gl_surface_requests = map[string]GlTextureRequest{}

// set_gl_surface_renderer installs the function that renders into each `opengl`
// element. It runs before every frame, on the UI thread, with the GL context current,
// for the elements drawn in the previous frame. A new element is therefore first
// rendered one frame after it appears.
pub fn set_gl_surface_renderer(renderer GlSurfaceFn) {
	g_gl_surface_renderer = renderer
}

// set_gl_surface_texture shows gl_texture, a GL texture of width x height pixels, in
// the `opengl` element with this id. Call it from the surface renderer. Requests for
// elements that are no longer drawn are dropped.
pub fn set_gl_surface_texture(id string, gl_texture u32, width int, height int) {
	g_gl_surface_requests[id] = GlTextureRequest{
		gl_texture: gl_texture
		width:      width
		height:     height
	}
}
