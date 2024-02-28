package main

import "core:c"
import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:time"

import gl "vendor:OpenGL"
import "vendor:glfw"

import "core:image"
import stb "vendor:stb/image"

main :: proc() {

	createWindow()

	glfw.MakeContextCurrent(window)
	gl.load_up_to(
		int(GL_MAJOR_VERSION),
		GL_MINOR_VERSION,
		glfw.gl_set_proc_address,
	)

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

	width, height: i32
	nrChannels: c.int

	texture: u32
	gl.GenTextures(1, &texture)
	gl.BindTexture(gl.TEXTURE_2D, texture)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(
		gl.TEXTURE_2D,
		gl.TEXTURE_MIN_FILTER,
		gl.LINEAR_MIPMAP_LINEAR,
	)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	image_data := stb.load(
		cstring("assets/fax.jpg"),
		&width,
		&height,
		&nrChannels,
		0,
	)

	stb.set_flip_vertically_on_load(c.int(1))
	defer stb.image_free(image_data)

	if image_data != nil {
		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGB,
			width,
			height,
			0,
			gl.RGB,
			gl.UNSIGNED_BYTE,
			image_data,
		)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	}

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

	vertices := []Vertex {
		{{+0.5, +0.5, 0}, {0.0, 1.0, 0.0, 0.75}, {1.0, 1.0}},
		{{+0.5, -0.5, 0}, {0.0, 0.0, 1.0, 0.75}, {1.0, 0.0}},
		{{-0.5, -0.5, 0}, {1.0, 1.0, 0.0, 0.75}, {0.0, 0.0}},
		{{-0.5, +0.5, 0}, {1.0, 0.0, 0.0, 0.75}, {0.0, 1.0}},
	}

	indices := []u16{0, 1, 2, 2, 3, 0}

	// gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(vertices[0]),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)

	gl.EnableVertexAttribArray(0)
	gl.EnableVertexAttribArray(1)
	gl.EnableVertexAttribArray(2)

	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		false,
		size_of(Vertex),
		offset_of(Vertex, pos),
	)
	gl.VertexAttribPointer(
		1,
		3,
		gl.FLOAT,
		false,
		size_of(Vertex),
		offset_of(Vertex, col),
	)

	gl.VertexAttribPointer(
		2,
		2,
		gl.FLOAT,
		false,
		size_of(Vertex),
		offset_of(Vertex, tex),
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(indices[0]),
		raw_data(indices),
		gl.STATIC_DRAW,
	)
	// start_tick := time.tick_now()

	loop: for (!glfw.WindowShouldClose(window)) {
		glfw.PollEvents()
		if (glfw.GetKey(window, glfw.KEY_X) == glfw.PRESS) {
			glfw.SetWindowShouldClose(window, true)
		}

		// pos := glm.vec3{glm.cos(t * 2), glm.sin(t * 2), 0}
		// pos := glm.vec3{1, 1, 1}
		// pos *= 0.5
		//
		// model := glm.mat4{0.9, 0, 0, 0, 0, 0.9, 0, 0, 0, 0, 0.9, 0, 0, 0, 0, 1}
		//
		// model[0, 3] = -pos.x
		// model[1, 3] = -pos.y
		// model[2, 3] = -pos.z
		//
		// model[3].yzx = pos.yzx
		//
		// model = model * glm.mat4Rotate({1, 1, 1}, 0)
		//
		// view := glm.mat4LookAt({1, -1, +1}, {0, 0, 0}, {1, 0, 1})
		// proj := glm.mat4Perspective(45, 1.3, 0.1, 100.0)
		//
		// // matrix multiplication
		// u_transform := proj * view * model
		//
		// // matrix types in Odin are stored in column-major format but written as you'd normal write them
		// gl.UniformMatrix4fv(
		// 	uniforms["u_transform"].location,
		// 	1,
		// 	false,
		// 	&u_transform[0, 0],
		// )

		/*gl.Viewport(0, 0, WIDTH, HEIGHT)*/
		gl.ClearColor(0.5, 0.7, 1.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.BindTexture(gl.TEXTURE_2D, texture)
		gl.UseProgram(program)

		// gl.BindVertexArray(vao)
		// cannot call BindVertexArray() inside loop and will segfault 
		// gl.BindVertexArray(vao)
		gl.DrawElements(gl.TRIANGLES, i32(len(indices)), gl.UNSIGNED_SHORT, nil)

		glfw.SwapBuffers((window))
	}
	cleanWindow()
}
