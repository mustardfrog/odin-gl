package main

import "core:c"
import "core:fmt"
import "core:image"
import glm "core:math/linalg/glsl"
import "core:time"

import gl "vendor:OpenGL"
import "vendor:glfw"
import stb "vendor:stb/image"

cameraPos := glm.vec3{0, 0, 3}
cameraFront := glm.vec3{0, 0, -1}
cameraUp := glm.vec3{0, 1, 0}

// cameraTarget := glm.vec3{0, 0, 0}
// cameraDirection := glm.normalize(cameraPos - cameraTarget)
//
deltaTime := 0.0
lastFrame := 0.0

main :: proc() {

	createWindow()

	glfw.MakeContextCurrent(window)
	gl.load_up_to(
		int(GL_MAJOR_VERSION),
		GL_MINOR_VERSION,
		glfw.gl_set_proc_address,
	)

	glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
	glfw.SetCursorPosCallback(window, mouse_callback)

	program, program_ok := gl.load_shaders_file(
		"res/shaders/tri.vert",
		"res/shaders/tri.frag",
	)

	if !program_ok {
		fmt.eprintln("Failed to create GLSL program")
		return
	}
	defer gl.DeleteProgram(program)

	uniforms := gl.get_uniforms_from_program(program)
	defer delete(uniforms)

	texture: Texture
	createTexture(&texture, cstring("assets/fax.jpg"))

	oo_texture: Texture
	createTexture(&oo_texture, cstring("assets/therock_5.png"))

	vao: u32
	gl.GenVertexArrays(1, &vao);defer gl.DeleteVertexArrays(1, &vao)
	vbo, ebo: u32
	gl.GenBuffers(1, &vbo);defer gl.DeleteBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo);defer gl.DeleteBuffers(1, &ebo)

	Vertex :: struct {
		pos: glm.vec3,
		col: glm.vec4,
		tex: glm.vec2,
	}

	Cube :: struct {
		pos: glm.vec3,
		col: glm.vec2,
	}

	vertices := []Vertex {
		{{+0.5, +0.5, 0}, {0.0, 1.0, 0.0, 0.75}, {1.0, 1.0}},
		{{+0.5, -0.5, 0}, {0.0, 0.0, 1.0, 0.75}, {1.0, 0.0}},
		{{-0.5, -0.5, 0}, {1.0, 1.0, 0.0, 0.75}, {0.0, 0.0}},
		{{-0.5, +0.5, 0}, {1.0, 0.0, 0.0, 0.75}, {0.0, 1.0}},
	}

	cube_positions := []glm.vec3 {
		{0.0, 0.0, 0.0},
		{2.0, 5.0, -15.0},
		{-1.5, -2.2, -2.5},
		{-3.8, -2.0, -12.3},
		{2.4, -0.4, -3.5},
		{-1.7, 3.0, -7.5},
		{1.3, -2.0, -2.5},
		{1.5, 2.0, -2.5},
		{1.5, 0.2, -1.5},
		{-1.3, 1.0, -1.5},
	}

	cube_vertices := []Cube {
		{{-0.5, -0.5, -0.5}, {0.0, 0.0}},
		{{0.5, -0.5, -0.5}, {1.0, 0.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{-0.5, 0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 0.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{0.5, -0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 1.0}},
		{{0.5, 0.5, 0.5}, {1.0, 1.0}},
		{{-0.5, 0.5, 0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{0.5, -0.5, -0.5}, {1.0, 1.0}},
		{{0.5, -0.5, 0.5}, {1.0, 0.0}},
		{{0.5, -0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, 0.5, -0.5}, {0.0, 1.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, 0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, 0.5, -0.5}, {0.0, 1.0}},
	}

	indices := []u16{0, 1, 2, 2, 3, 0}

	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(cube_vertices) * size_of(cube_vertices[0]),
		raw_data(cube_vertices),
		gl.STATIC_DRAW,
	)

	gl.EnableVertexAttribArray(0)
	gl.EnableVertexAttribArray(1)

	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		false,
		size_of(Cube),
		offset_of(Cube, pos),
	)

	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		false,
		size_of(Cube),
		offset_of(Cube, col),
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(indices[0]),
		raw_data(indices),
		gl.STATIC_DRAW,
	)

	gl.UseProgram(program)
	gl.Uniform1i(gl.GetUniformLocation(program, "ourTexture1"), 0)
	gl.Uniform1i(gl.GetUniformLocation(program, "ourTexture2"), 1)

	proj: glm.mat4
	proj = glm.mat4Perspective(45., WIDTH / HEIGHT, 0.1, 100.)
	gl.UniformMatrix4fv(
		gl.GetUniformLocation(program, "projection"),
		1,
		false,
		&proj[0][0],
	)

	// start_tick := time.tick_now()

	gl.Enable(gl.DEPTH_TEST)

	loop: for (!glfw.WindowShouldClose(window)) {
		current_frame := glfw.GetTime()
		deltaTime = current_frame - lastFrame
		lastFrame = current_frame

		glfw.PollEvents()
		if (glfw.GetKey(window, glfw.KEY_X) == glfw.PRESS) {
			glfw.SetWindowShouldClose(window, true)
		}

		process_input(window)
		// duration := time.tick_since()
		// t := time.duration_seconds()

		gl.ClearColor(0.5, 0.7, 1.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		// radius := 10.0
		// camX := glm.sin(glfw.GetTime()) * radius
		// camZ := glm.cos(glfw.GetTime()) * radius

		view := glm.identity(glm.mat4)
		view = glm.mat4LookAt(cameraPos, cameraPos + cameraFront, cameraUp)
		// view = glm.mat4LookAt({f32(camX), 0, f32(camZ)}, {0, 0, 0}, {0, 1, 0})

		gl.UniformMatrix4fv(
			gl.GetUniformLocation(program, "view"),
			1,
			false,
			&view[0][0],
		)

		gl.ActiveTexture((gl.TEXTURE0))
		gl.BindTexture(gl.TEXTURE_2D, texture.texture)
		gl.ActiveTexture((gl.TEXTURE1))
		gl.BindTexture(gl.TEXTURE_2D, oo_texture.texture)

		// cannot call BindVertexArray() inside loop and will segfault | still don't know why
		// gl.BindVertexArray(vao)
		// gl.DrawElements(gl.TRIANGLES, i32(len(indices)), gl.UNSIGNED_SHORT, nil)
		for i := 0; i < len(cube_positions); i += 1 {

			model := glm.identity(glm.mat4)

			model = glm.mat4Translate(cube_positions[i])

			angle := 20.0 * i
			gl.UniformMatrix4fv(
				gl.GetUniformLocation(program, "model"),
				1,
				false,
				&model[0][0],
			)

			model = glm.mat4Rotate(glm.vec3{1, 0, 0}, f32(angle))

			gl.DrawArrays(gl.TRIANGLES, 0, 36)
		}

		glfw.SwapBuffers((window))
	}
	cleanWindow()
}

process_input :: proc(window: glfw.WindowHandle) {
	cameraSpeed: f32 = .5 * f32(deltaTime)

	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		cameraPos += cameraSpeed * cameraFront
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		cameraPos -= cameraSpeed * cameraFront
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		cameraPos -= glm.normalize(glm.cross(cameraFront, cameraUp) * cameraSpeed)
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		cameraPos += glm.normalize(glm.cross(cameraFront, cameraUp) * cameraSpeed)
	}
}

lastX: f32 = WIDTH / 2
lastY: f32 = HEIGHT / 2
yaw: f32 = -90
pitch: f32 = 0
firstMouse := true

mouse_callback :: proc "c" (window: glfw.WindowHandle, xpos_, ypos_: f64) {
	xpos := f32(xpos_)
	ypos := f32(ypos_)

	if firstMouse {
		lastX = xpos
		lastY = ypos
		firstMouse = false
	}

	xoffset := xpos - lastX
	yoffset := lastY - ypos
	lastX = xpos
	lastY = ypos

	sensitivity: f32 = 0.1
	xoffset *= sensitivity
	yoffset *= sensitivity

	yaw += xoffset
	pitch += yoffset
	if (pitch > 89.0) {
		pitch = 89.0
	}
	if (pitch < -89.0) {
		pitch = -89.0
	}

	front: glm.vec3
	front.x = glm.cos(glm.radians(yaw)) * glm.cos(glm.radians(pitch))
	front.y = glm.sin(glm.radians(pitch))
	front.z = glm.sin(glm.radians(yaw)) * glm.cos(glm.radians(pitch))

	cameraFront = glm.normalize(front)
}
