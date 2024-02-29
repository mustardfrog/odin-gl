package main

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
