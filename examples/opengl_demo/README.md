# OpenGL Widget (gg) Demo

`opengl(id, frame)` reserves a surface in the `gg` renderer. Until the application
supplies a texture it shows a blue disc. The application renders into a GL texture
from `set_gl_surface_renderer`, which runs before each frame on the UI thread with
the GL context current, and passes the texture with `set_gl_surface_texture`.
ui2 draws it as a quad in the UI's own pass, so menus and other overlays draw
above it. The `vore` player uses this to show libmpv video.

```sh
v -d ui2_custom_rendering run main.v
```
