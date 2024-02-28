package main

import "core:c"
import "core:fmt"

import gl "vendor:OpenGL"
import "vendor:glfw"

GL_MAJOR_VERSION: c.int : 4
GL_MINOR_VERSION :: 0

window: glfw.WindowHandle

WIDTH :: 800
HEIGHT :: 600

createWindow :: proc() {
	glfw.WindowHint(glfw.RESIZABLE, 1)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	if (!glfw.Init()) {
		fmt.print("Failed to init glfw")
		return
	}

	window = glfw.CreateWindow(WIDTH, HEIGHT, "hello", nil, nil)
	// defer glfw.DestroyWindow(window)
	if window == nil {
		fmt.println("Cannot Create Window")
		return
	}

	glfw.SetFramebufferSizeCallback(window, frameBufferSizeCallback)
	// defer glfw.Terminate()
}

cleanWindow :: proc() {
	glfw.Terminate()
	glfw.DestroyWindow(window)
}

frameBufferSizeCallback :: proc "c" (
	window: glfw.WindowHandle,
	width: i32,
	height: i32,
) {
	gl.Viewport(0, 0, width, height)
}
