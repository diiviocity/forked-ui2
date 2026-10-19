# OpenGL Widget (gg) Demo

`opengl(id, frame)` reserves a surface in the `gg` renderer. The surface is drawn
after the rest of the UI, by the function installed with
`set_gl_surface_renderer`, which runs on the UI thread with the GL context
current. The `vore` player uses it to draw libmpv video through the render API.

```sh
v -d ui2_custom_rendering run main.v
```
