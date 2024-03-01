#version 330 core
layout(location=0) in vec3 a_position;
layout(location=1) in vec2 a_TexCoord;

out vec4 v_color;
uniform mat4 u_transform;
out vec2 TexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {	
	gl_Position = projection * view * model *  vec4(a_position, 1.0);
	// v_color = a_color;
	TexCoord = a_TexCoord;
}
