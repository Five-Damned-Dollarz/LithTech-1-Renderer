module Objects.Model;

import Objects.BaseObject;
import Codes;

import gl3n.linalg;

import core.stdc.string;

struct ModelAnim
{
	char* name;
	uint duration; // in ms

	vec3 anim_dims;
	AnimNode** unknown_2; // seems to be pointer to pointer to node keyframes, possibly only vertex animated nodes?
	vec3 bounds_min;
	vec3 bounds_max;
	float radius; // appears to be average radius

	AnimKeyframe* keyframes;
	uint keyframe_count;

	@property AnimKeyframe[] Keyframes()
	{
		return keyframes[0..keyframe_count];
	}

	void*[5] unknown_4; // [2] = anim ref?
	vec3 unknown_5;
	void*[6] buf;

	static assert(this.sizeof==116);
}

struct AnimKeyframe
{
	uint time_index;
	vec3 bounds_min;
	vec3 bounds_max;
	//
	void* unknown;
	void*[3] unknown_1;
}

struct AnimNode
{
	char** node_name;
	ModelAnim* anim_ref;
	ubyte* compressed_vertices;
	void* unknown; // null?
	vec3 scale;
	vec3 translation;
}

enum NodeFlags : ushort
{
	Null=0x1,
	Triangles=0x2,
	Deformation=0x4,
}

struct ModelNode
{
	char* name;

	vec3 bounds_min;
	vec3 bounds_max;

	void* unknown_1;

	ushort* deform_vertices; // list of vertex indices
	uint deform_vertex_count;

	void* unknown_2;

	ushort index;
	NodeFlags flags;

	ModelNode* child_nodes;
	uint child_node_count;

	static assert(this.sizeof==56);
}

struct ModelVertex
{
	vec3 position;
	float[2] uv;
	byte[3] normal;
	ubyte node_index;
	ushort[2] deform_replacements;
}

struct AnimBoundBox
{
	void* unknown;
	vec3 min, max;
}

struct ModelFace
{
	ushort[3] vertices;
	byte[3] normal;
}

struct ModelData
{
	void*[6] unknown_1;
	vec3 bounds_min, bounds_max;
	float bounds_radius;

	void*[2] unknown_2;

	void* unknown_3; // self???
	uint unknown_3_count;

	void*[12] unknown_4;

	uint flags;

	ModelNode* unknown_5; // first non-zero node?
	uint unknown_5_count;

	ModelNode** nodes;
	uint node_count;

	ModelNode** unknown_7; // vertex animated nodes?
	uint unknown_7_count;

	uint unknown_8;

	uint unknown_9_count; // vertex_count[0]?
	ModelVertex* vertices; // vertices?
	uint unknown_9_count_b; // vertex_count[1]?

	uint face_count;
	ModelFace* faces;

	void*[2] unknown_10; // [0] = UVs somehow? [1] = weird vertices?

	uint lod_count;

	float[3] unknown_floats; // possibly lod distances?

	void* unknown_11;
	void* unknown_12;

	mat4* node_matrices;
	uint node_matrix_count;

	void* node_0_name; // + 0x10 = in-place node name?

	void* unknown_13;
	float unknown_float_b;
	void*[6] buf;

	ModelAnim* animations;
	uint animation_count;

	void* buf2;

	static assert(this.sizeof>=252); // guessing at size for now
	static assert(nodes.offsetof==0x80);
	static assert(node_count.offsetof==0x84);
	static assert(animations.offsetof==0xf4);
	static assert(animation_count.offsetof==0xf8);
}

struct ModelObject
{
	alias base this;
	BaseObject base;

	void*[6] buf;

	ModelData* model_data;

	void*[3] buf1;
	AnimBoundBox* model_frame;
	void*[2] buf2;

	ModelAnim* anim_current;

	//static assert(???.offsetof==316); polygon pointer?
	static assert(model_data.offsetof==320); // for type_id=Model, this might actually just be the raw model data
	//static assert(model_flags.offsetoff==328); // for type_id=Model, 0x2 = is looping anim
	static assert(model_frame.offsetof==336); // for type_id=Model, +4 = vec3[2] min/max
	static assert(anim_current.offsetof==348); // for type_id=Model
}

LTResult GetNextModelNode(ModelObject* obj, uint node, out uint next)
{
	if ((obj!=null) && (obj.type_id==1))
	{
		uint node_count=*cast(uint*)((cast(uint)obj.model_data) + 0x84); // model_data + 0x84 = node_count
		if (node+1>node_count)
		{
			return LTResult.Finished;
		}
		next=node+1;
		return LTResult.Ok;
	}
	return LTResult.InvalidParams;
}

LTResult GetModelNodeName(ModelObject* obj, uint node, char* name, int max_length)
{
	if ((node==0) || (max_length==0) || (obj==null) || (obj.type_id!=1))
	{
		return LTResult.Error; // assert(0);
	}
	else
	{
		uint node_count=*cast(uint*)((cast(uint)obj.model_data)+0x84);
		if (node<node_count)
		{
			char** node_name_list=*cast(char***)(cast(uint)obj.model_data+0x80);
			strncpy(name, *(cast(char**)node_name_list[node]), max_length-1);
			return LTResult.Ok;
		}
	}
	return LTResult.InvalidParams;
}

int GetModelAnimation(ModelObject* obj)
{
	if ((obj!=null) && (obj.type_id==1))
	{
		return (*cast(int*)(cast(int)obj.anim_current)-*cast(int*)(cast(int)obj.model_data+0xf4))/ModelAnim.sizeof;
	}
	return -1;
}

bool GetModelLooping(ModelObject* obj)
{
	if ((obj!=null) && (obj.type_id==1)) {
		return cast(bool)(*cast(int*)(cast(int)obj+328) >> 1 & 1);
	}
	return 0;
}

/+
void TraverseModel(ModelNode* node)
{
	test_out.writeln("[", node, "]: ", (cast(char*)node.unknown).fromStringz, " ", *node);
	if (node.child_nodes && node.child_node_count)
	{
		foreach(ref child; node.child_nodes[0..node.child_node_count])
		{
			TraverseModel(&child);
		}
	}
}
TraverseModel(*node_);
+/