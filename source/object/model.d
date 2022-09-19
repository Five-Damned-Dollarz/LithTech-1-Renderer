module Objects.Model;

import Objects.BaseObject;
import Texture: SharedTexture;
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

	private AnimKeyframe* keyframes;
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
	void*[2] unknown_1a;
	ModelData* self_ref;
	char* file_name;
	void*[2] unknown_1b; // [1] = memory use?

	vec3 bounds_min, bounds_max;
	float bounds_radius;

	void*[2] unknown_2; // DLink?

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

	uint vertex_count_total; // all vertices, including replacements
	ModelVertex* vertices;
	uint vertex_count_base; // of the highest LOD model, the remainder are used to reduce polycount

	uint face_count;
	ModelFace* faces;

	float* uvs; // UVs, 6 floats, 48 byte stride
	void* unknown_10; // float[6] * face_count might fit, possibly "normalized" (0-255) UVs?

	uint lod_count;

	// set via command_string
	float lod_dist_min; // LODSTARTDIST
	float lod_interval; // LODINCREMENT
	float lod_dist_max; // LODMAXDIST
	float unknown_11; // MIPMAPDISTADD?

	int unknown_12; // short[2]? short* unknown_12; // maybe list of shorts? possibly LOD vertex replacement ids?

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

ModelObject* ToModel(BaseObject* obj)
{
	return cast(ModelObject*)obj;
}

enum ModelFlags : uint // upper 2 bytes are 0xFFFF if slow transition is not wanted
{
	// Unknown=0x1,
	Looping=0x2,
	// IsLoaded=0x4, // unsure
}

struct ModelObject
{
	alias base this;
	BaseObject base;

	/+
	 +   Took another look at the texture issue and noticed that there's actually 2 different almost identical objects in
	 + memory; one has a class and no texture, and the other has a texture and no class.
	 +   They aren't parent/child attached but must be client/server linked, doing an object memory dump from a client
	 + connected to a multiplayer server shows only objects with a texture.
	 +   How does (should?) the renderer filter server objects when running singleplayer; I suspect the original d3d.ren
	 + simply goes through all the matrix transform math with a null texture assigned... Not optimal.
	 +/

	SharedTexture* texture;

	///// this section is frequently used as if it's an in-place struct by passing &anim_data into functions; possible TODO: split out into AnimData struct?
	// {
	void* anim_data;
	void*[4] buf; // [2] = unknown, maybe flags? values like 0x401B50, 0x44C800, [3] = pointer to self

	ModelData* model_data;
	uint keyframe_current;
	ModelFlags model_flags;

	struct ModelFrame
	{
		ModelAnim* animation;
		AnimKeyframe* frame_data;
		uint anim_time; // in ms
		uint frame_index;
	}
	ModelFrame[2] keyframes;
	float frame_interpolation;
	// }
	/////

	int unknown_zero;
	float[2] unknown_sqrt;

	void* unknown_nodes;

	/+
	// I think there's actually another BaseObject starting here, which is pointed to from base.class_.unknown_flags
	void*[9] buf4;

	int ffff; // unknown?
	+/

	static assert(texture.offsetof==296);
	static assert(anim_data.offsetof==300);
	// 304 texture?
	static assert(model_data.offsetof==320); // this might actually just be the raw model data
	static assert(model_flags.offsetof==328);
	static assert(keyframes.offsetof==332);
	//static assert(anim_current.offsetof==348);
	static assert(unknown_sqrt.offsetof==372); // unknown sqrt(2) / 2 * 0.1 vals
	static assert(unknown_nodes.offsetof==380); // array of ints? node related?
}

LTResult GetNextModelNode(ModelObject* obj, uint node, out uint next)
{
	if ((obj!=null) && (obj.type_id==ObjectType.Model))
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
	if ((node==0) || (max_length==0) || (obj==null) || (obj.type_id!=ObjectType.Model))
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
	if ((obj!=null) && (obj.type_id==ObjectType.Model))
	{
		return (cast(int)obj.keyframes[1].animation-cast(int)obj.model_data.animations)/ModelAnim.sizeof;
	}

	return -1;
}

bool GetModelLooping(ModelObject* obj)
{
	if ((obj!=null) && (obj.type_id==ObjectType.Model))
		return cast(bool)(obj.model_flags & ModelFlags.Looping);

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