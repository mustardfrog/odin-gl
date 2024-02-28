#version 330 core
layout(location=0) in vec3 a_position;
layout(location=1) in vec4 a_color;
layout(location=2) in vec2 a_TexCoord;

out vec4 v_color;
uniform mat4 u_transform;
out vec2 TexCoord;

void main() {	
	gl_Position =  vec4(a_position, 1.0);
	v_color = a_color;
	TexCoord = a_TexCoord;
}
