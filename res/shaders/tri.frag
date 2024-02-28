#version 400 core

in vec4 v_color;
in vec2 TexCoord;
out vec4 o_color;

uniform sampler2D ourTexture;

void main() {
  o_color = texture(ourTexture, TexCoord);
}
