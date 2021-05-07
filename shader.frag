#version 450
#extension GL_ARB_separate_shader_objects: enable

layout(binding=1) uniform sampler2D tex_sampler;

layout(location=0) in vec3 colour_in;
layout(location=1) in vec2 uv_coord_in;

layout(location=0) out vec4 colour_out;

void main()
{
	colour_out=vec4(colour_in, 1.0); //texture(tex_sampler, uv_coord_in);
}