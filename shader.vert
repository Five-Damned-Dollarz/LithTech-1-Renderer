#version 450
#extension GL_ARB_separate_shader_objects: enable

#define MAX_LIGHT_COUNT 40

layout(set=0, binding=0) uniform UniformBufferObject {
	mat4 model;
	mat4 view;
	mat4 proj;
} ubo;

struct LightObj
{
	vec3 position; float pad;
	vec3 colour;
	float radius;
};

layout(set=0, binding=2) uniform LightList {
	uint count; float pad, pad_, pad__;
	LightObj lights[MAX_LIGHT_COUNT];
} light_list;

layout(location=0) in vec3 position_in;
layout(location=1) in vec3 colour_in;
layout(location=2) in vec2 uv_in;

layout(location=0) out vec3 fragColour;
layout(location=1) out vec2 fragTexCoord;

vec3 CalculateLight()
{
	vec3 colour_out=colour_in;

	for(uint i=0; i<light_list.count; ++i)
	{
		LightObj obj=light_list.lights[i];

		float pos_diff=distance(obj.position, position_in);
		if (pos_diff>obj.radius) continue;

		float ratio=1.0-pos_diff*(1.0/obj.radius);
		colour_out+=obj.colour-(1.0-obj.colour)*ratio;
	}

	return colour_out;
}

void main()
{
	gl_Position=ubo.proj*ubo.view*ubo.model*vec4(position_in, 1.0);

	fragColour=CalculateLight();
	fragTexCoord=uv_in;
}