package window

import "core:fmt"
import "core:c"

import gl "vendor:OpenGL"
import "vendor:glfw"

GL_MAJOR_VERSION: c.int : 4
GL_MINOR_VERSION :: 3

window: glfw.WindowHandle

createWindow :: proc() {
	// glfw.WindowHint(glfw.RESIZABLE, 1)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)


	if (!glfw.Init()) {
		fmt.print("Failed to init glfw")
		return
	}
	defer glfw.Terminate()

	window = glfw.CreateWindow(400, 600, "hello", nil, nil)
	if window == nil {
		fmt.println("Cannot Create Window")
		return
	}
	defer glfw.DestroyWindow(window)
	glfw.MakeContextCurrent(window)
}
