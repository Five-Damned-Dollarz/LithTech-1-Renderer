#version 450
#extension GL_ARB_separate_shader_objects: enable

#define MAX_LIGHT_COUNT 40

layout(binding=0) uniform UniformBufferObject {
	mat4 model;
	mat4 view;
	mat4 proj;
} ubo;

struct LightObj
{
	vec3 position;
	vec3 colour;
	float radius;
};

layout(binding=1) uniform LightList {
	uint light_count;
	LightObj lights[MAX_LIGHT_COUNT];
} light_list;

layout(location=0) in vec3 position_in;
layout(location=1) in vec3 colour_in;
layout(location=2) in vec2 uv_in;

layout(location=0) out vec3 fragColour;
layout(location=1) out vec2 fragTexCoord;

vec3 CalculateLight() // should return lit vertex colour with channels between [0, 255]
{
	vec3 colour_out=vec3(0.0, 0.0, 0.0);

	for(uint i=0; i<light_list.light_count; ++i)
	{
		LightObj obj=light_list.lights[i];

		float pos_diff=distance(obj.position, position_in);
		if (pos_diff>obj.radius) continue;

		float ratio=(1.0-pos_diff/obj.radius)*0.7;
		colour_out+=(obj.colour*2-0xFF)*ratio;
	}

	return colour_out;
}

void main()
{
	gl_Position=ubo.proj*ubo.view*ubo.model*vec4(position_in, 1.0);
	fragColour=colour_in; // CalculateLight()/255.0, does this language let you div a vec with a scalar?
	fragTexCoord=uv_in;
}