package main

import "core:c"
import gl "vendor:OpenGL"
import stb "vendor:stb/image"

Texture :: struct {
	texture: u32,
}

width, height: i32
	nrChannels: c.int

createTexture :: proc(texture: ^Texture, file: cstring) {
	stb.set_flip_vertically_on_load(c.int(1))

	gl.GenTextures(1, &texture.texture)
	gl.BindTexture(gl.TEXTURE_2D, texture.texture)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	image_data := stb.load(cstring(file), &width, &height, &nrChannels, 0)

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

}
