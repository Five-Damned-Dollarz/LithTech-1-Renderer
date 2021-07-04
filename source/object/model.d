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
	vec3 unknown_5; // scale?
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

	static assert(this.sizeof==28);
}

struct AnimBoundBox
{
	uint unknown_1; // possibly an id?
	vec3 min, max;
}

struct ModelFace
{
	ushort[3] vertices;
	byte[3] normal;
	ubyte unknown;

	static assert(this.sizeof==10);
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

	void*[2] unknown_10; // [0] = UVs somehow? 48 byte stride [1] = weird vertices?

	uint lod_count;

	float lod_dist_min; // LODSTARTDIST
	float lod_interval; // LODINCREMENT
	float lod_dist_max; // LODMAXDIST
	float unknown_11; // MIPMAPDISTADD?

	int unknown_12; // short[2]?

	mat4* node_matrices;
	uint node_matrix_count;

	char* command_string; // + 0x10 = in-place node name?

	void* unknown_13; // list of pointers to animation something?
	float unknown_float_b; // DrawIndexedDist command string
	void*[6] buf;

	ModelAnim* animations;
	uint animation_count;

	void* buf2;

	static assert(this.sizeof>=252); // guessing at size for now
	static assert(nodes.offsetof==128);
	static assert(node_count.offsetof==132);
	static assert(animations.offsetof==244);
	static assert(animation_count.offsetof==248);
}

struct AnimData
{
	void*[17] buf;

	static assert(this.sizeof==68);
}

ModelObject* ToModel(BaseObject* obj)
{
	return cast(ModelObject*)obj;
}

struct ModelObject
{
	alias base this;
	BaseObject base;

	import Texture: SharedTexture;
	SharedTexture* texture; // probably part of BaseObject?

	AnimData* anim_data;

	void*[4] buf;

	ModelData* model_data;

	void* buf1;

	short[2] frame_code; // byte | 0x1 | 0x2
	ModelAnim* buf1a; // mirrors anim_current
	AnimKeyframe* model_frame; // mirrors anim_curr_keyframes?

	void*[2] buf2;

	ModelAnim* anim_current;
	AnimKeyframe* anim_curr_keyframes;

	void* buf3;
	uint frame_index; // seems possible?
	float frame_interpolation; // not sure, but seems like it could be the keyframe interpolation

	int unknown_zero;
	float[2] unknown_sqrt;

	void* unknown_nodes;

	void*[9] buf4;

	int ffff; // unknown?

	static assert(texture.offsetof==296); // for type_id=Model, this /should/ be where the texture is, but doesn't seem to be?
	static assert(anim_data.offsetof==300);
	//static assert(???.offsetof==316); polygon pointer?
	static assert(model_data.offsetof==320); // for type_id=Model, this might actually just be the raw model data
	//static assert(model_flags.offsetoff==328); // for type_id=Model, 0x2 = is looping anim
	static assert(model_frame.offsetof==336); // for type_id=Model, +4 = vec3[2] min/max
	static assert(anim_current.offsetof==348); // for type_id=Model
	static assert(unknown_sqrt.offsetof==372); // for type_id=Model, unknown sqrt(2) / 2 * 0.1 vals
	static assert(unknown_nodes.offsetof==380); // for type_id=Model, array of ints? node related?
}

LTResult GetNextModelNode(ModelObject* obj, uint node, out uint next)
{
	if ((obj!=null) && (obj.type_id==1))
	{
		if (node+1>obj.model_data.node_count)
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
		if (node<obj.model_data.node_count)
		{
			strncpy(name, obj.model_data.nodes[node].name, max_length-1);
			return LTResult.Ok;
		}
	}

	return LTResult.InvalidParams;
}

int GetModelAnimation(ModelObject* obj)
{
	if ((obj!=null) && (obj.type_id==1))
	{
		return (cast(int)obj.anim_current-cast(int)obj.model_data.animations)/ModelAnim.sizeof;
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

// debug only!
import std.stdio: File;
void TraverseModel(File file, ModelNode* node)
{
	import std.string: fromStringz;
	file.writeln("[", node, "]: ", node.name.fromStringz, " ", *node);

	if (node.child_nodes && node.child_node_count)
	{
		foreach(ref child; node.child_nodes[0..node.child_node_count])
		{
			TraverseModel(file, &child);
		}
	}
}