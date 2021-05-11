#version 450
#extension GL_ARB_separate_shader_objects: enable

layout(binding=0) uniform UniformBufferObject {
	mat4 model;
	mat4 view;
	mat4 proj;
} ubo;

layout(location=0) in vec3 position_in;
layout(location=1) in vec3 colour_in;
layout(location=2) in vec3[3] opq_map_in;

layout(location=0) out vec3 fragColour;
layout(location=1) out vec2 fragTexCoord;

vec2 GenerateTextureCoords()
{
	vec3 temp=position_in-opq_map_in[0];

	float dot_x=dot(temp, opq_map_in[1])/256.0f;
	float dot_y=dot(temp, opq_map_in[2])/256.0f;

	return vec2(dot_x, dot_y);
}

void main()
{
    gl_Position=ubo.proj*ubo.view*ubo.model*vec4(position_in, 1.0);
    fragColour=colour_in;
    fragTexCoord=GenerateTextureCoords();
}