#version 450
#extension GL_ARB_separate_shader_objects: enable

layout(binding=1) uniform sampler tex_sampler;
layout(set=1, binding=0) uniform texture2D tex;

layout(location=0) in vec3 colour_in;
layout(location=1) in vec2 uv_coord_in;

layout(location=0) out vec4 colour_out;

void main()
{
	colour_out=vec4(colour_in*texture(sampler2D(tex, tex_sampler), uv_coord_in/textureSize(sampler2D(tex, tex_sampler), 0)).rgb, 1.0);
}