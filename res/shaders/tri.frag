#version 400 core

in vec4 v_color;
in vec2 TexCoord;

out vec4 o_color;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;

void main() {
  o_color =  mix(texture(ourTexture1, TexCoord), texture(ourTexture2, TexCoord), 0.7) ;
}
