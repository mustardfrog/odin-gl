package main

import "core:fmt"
import os "core:os"
import "core:strings"
import gl "vendor:OpenGL"

Shader :: struct {
	program: u32,
}

createShader :: proc(
	shader: ^Shader,
	vertexShaderPath: string,
	fragmentShaderPath: string,
) {

	// fragment Shader
	fragmentShaderSource, frag_ok := os.read_entire_file(fragmentShaderPath)
	if !frag_ok {
		fmt.println("cannot read fragment shader file")
	}

	fragmentShader := gl.CreateShader(gl.FRAGMENT_SHADER)
	f := strings.clone_to_cstring((string(fragmentShaderSource)))
	fragment: [^]cstring = &f

	gl.ShaderSource(fragmentShader, 1, fragment, nil)
	gl.CompileShader(fragmentShader)
	checkComplieErrors(fragmentShader, "FRAGMENT")

	// vertex shader
	vertexShaderSource, ok := os.read_entire_file(
		vertexShaderPath,
		context.allocator,
	)
	if !ok {
		fmt.println("cannot read vertex shader file")
	}

	vertexShader := gl.CreateShader(gl.VERTEX_SHADER)
	v := strings.clone_to_cstring((string(vertexShaderSource)))
	vertex: [^]cstring = &v

	fmt.printf("%s", v)
	fmt.printf("%s", f)

	gl.ShaderSource(vertexShader, 1, vertex, nil)
	gl.CompileShader(vertexShader)
	checkComplieErrors(vertexShader, "VERTEX")

		fmt.printf("before linking shader program: %d \n", shader.program);
	shader.program = gl.CreateProgram()
	gl.AttachShader(shader.program, vertexShader)
	gl.AttachShader(shader.program, fragmentShader)
	gl.LinkProgram(shader.program)

	checkComplieErrors(shader.program, "PROGRAM")
		fmt.printf("after linking shader program: %d \n", shader.program);

	gl.DeleteShader(vertexShader)
	gl.DeleteShader(fragmentShader)
	delete(fragmentShaderSource, context.allocator)
	delete(vertexShaderSource, context.allocator)
}

checkComplieErrors :: proc(shader: u32, type: string) -> i32 {
	success: i32
	infoLog: [512]u8
	// infoLog: [^]u8 = &info
	// char;infoLog[1024]

	if type != "PROGRAM" {
		gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)
		if (success == 0) {
			gl.GetShaderInfoLog(shader, 1024, nil, raw_data(infoLog[:]))
			fmt.printf("CANNOT COMPILE:: %s", type)
			fmt.printf("%s", infoLog)
			fmt.println(success)
		}
	} else {
		gl.GetProgramiv(shader, gl.LINK_STATUS, &success)
		if (success == 0) {
			gl.GetProgramInfoLog(shader, 1024, nil, raw_data(infoLog[:]))
			fmt.printf("SHADER LINKING FAILED::  %s", type)
			fmt.printf("%s", infoLog)
			fmt.printf("success status: %d ", success)
		}
	}

	return success
}

useShader :: proc(shader: Shader) {
	gl.UseProgram(shader.program)
}

cleanShader :: proc() {
}
