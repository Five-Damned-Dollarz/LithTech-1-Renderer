module WorldBSP;

import RendererTypes: DLink, Buffer;
import Model;

import gl3n.linalg;

struct Object // just placeholder for now
{
	void*[74] buf;

	static assert(this.sizeof==296);
}

struct PBlockTable // ?
{
	float[3] vec_1;
	float[3] vec_2;
	int unknown_1;
	int unknown_2a;
	int unknown_3a; // pblock_count?
	int unknown_2b;
	int unknown_3b; // pblock_count_b?

	struct PBlock
	{
		short size;
		short unknown_1;

		struct Contents
		{
			ubyte vert_index;
			ubyte padding;
			ubyte[4] content;
		}
		Contents* contents; // [0..size]
	}
	PBlock* pblock_array;
}

struct Portal
{
	struct UnknownStruct
	{
		//short[2] unknown_1;
		void* unknown;
		void* unknown_ptr;
		int[2] unknown_2;
		void[16] what;
	}

	UnknownStruct* unknown_ptr;
	int unknown_1;
	int index;
	vec3 position;
	vec3 dimensions;
}

struct Plane
{
	vec3 vector;
	float distance;
}

struct Node
{
	uint flags; // unknown, (flags & 8) seems important
	Polygon* polygons;
	Plane* planes;
	int unknown_1;
	Leaf* viewer_leaf; // leaf a camera's currently in? mostly null
	WorldBSP* bsp;
	vec3 center;
	float radius;
	Object* objects; // unsure
	Node*[2] next;

	static assert(this.sizeof==52);
}

struct Surface
{
	vec3[6] opq_map;
	void* unknown_1; // texture effect?
	Plane* plane;
	SurfaceFlags flags;
	ushort texture_id;
	ushort texture_flags;
	uint index;

	static assert(this.sizeof==92);
}

struct LeafList
{
	short portal_id;
	ushort length;
	ubyte* data;
}

struct Leaf
{
	float[4] vector; // center + radius?
	LeafList* leaf_list; // pointer to our leaf list?
	Buffer* unknown_2; // start? -- in place DLink?
	Buffer* unknown_3; // end?
	Buffer* unknown_4; // next, if start != end?
	Buffer* unknown_5; // entry to Buffer** unknown_3?
	int unknown_6; // set to 0 at the start of each frame draw
	Buffer* unknown_7;
	int unknown_8;

	static assert(this.sizeof==48);
}

struct Polygon // drawn with D3DPT_TRIANGLEFAN/GL_TRIANGLE_FAN?
{
	vec3 center;
	float radius;

	Surface* surface;

	float[3] unknown_1;
	vec3 polygon_list; // from PolygonList in the dat
	void*[2] unknown_2;

	ushort unknown; // set to 0 on frame start?
	ushort frame_code;

	Buffer*[2] unknown_3;

	ushort vertex_count;
	ushort vertex_extra;

	struct DiskVert
	{
		vec4* vertex_data;
		vec4 unknown_1;
		ubyte[4] colour;
	}
	DiskVert vertices; // this is intended to be drawn as a triangle fan: [0, 1, 2], [0, 2, 3], [0, 3, 4], [0, 4, 5], etc.

	@property DiskVert[] DiskVerts() return // these seem unsplit
	{
		return (&vertices)[0..(vertex_count)];
	}

	@property DiskVert[] DiskExtras() return // these are broken up into smaller triangles, possibly related to FixTJunc CVar?
	{
		return (&vertices)[(vertex_count)..(vertex_count+vertex_extra)];
	}

	static assert(this.sizeof>=72); // smallest runtime case possible should be 188?
}

struct MainWorld
{
	uint memory_used;
	WorldBSP* world_bsp;

	ushort[2] unknown_2; // not an address?
	int unknown_2_count;

	int[4] unknown_3;
	float[3] unknown_4; // fog related?

	Buffer* unknown_4a;
	uint unknown_4a_count;

	int[6] unknown_5;
	void* unknown_6;

	float[3][2] unknown_vectors_1; // maybe
	vec3[4] extents;
	int unknown_7;
	void* unknown_8;

	WorldData** world_models;
	int world_model_count;

	//int[2] unknown_9;

	//void*[64] buf;

	static assert(this.sizeof>=168);
}

struct UnknownList
{
	UnknownList* prev;
	UnknownList* next;
	UnknownObject* data;

	Node* node;
	UnknownList*[2] buf; // [0] = Node*? [1/2] = other entries in the list?

	static assert(this.sizeof==24);
}

struct UnknownObject // WorldModel
{
	DLink link;
	DLink link_unknown; // maybe not even a link?
	UnknownList* list; // ?

	Buffer* unknown_1;

	Buffer* unknown_2; // attachment?
	UnknownObject* root; // ?

	ModelFlags flags;

	void* unknown_3a;
	void* unknown_3b;
	Buffer* attachments; // pragma(msg, attachments.offsetof==52);

	vec3 world_translation;
	float[4] rotation;
	float[3] scale;

	short[4] unknown_5;
	short[3] frame_code; // [108] is set to 0 on frame start

align(2):
	ObjectType type_id;
	void*[6] unknown_6;
	int unknown_7;
	mat4 mat4_unknown_1; // ?

	void*[23] buf1;

	WorldData* bsp;

	mat4 mat4_unknown_2;
	mat4 mat4_unknown_3;

	//Buffer[4] buf2;

	//pragma(msg, this.sizeof);
	static assert(this.sizeof>=108);
	static assert(flags.offsetof==40);
	static assert(type_id.offsetof==110);
	// possibly 300 byte stride for one of the object types?
	// 428-432 stride?
}

struct WorldData
{
	WorldBSP*[2] objs; // orig + transformed?

	// DLink?; may not even be part of this struct at all?
	void*[2] refs; //  [0, 1] = ???
	WorldData* self;
}

struct WorldBSP
{
	uint memory_used; // memory use, maybe?
	void* next_section; // yes, in the map.dat...

	Plane* planes;
	uint plane_count;

	Node* nodes;
	uint node_count;

	UnknownList* unknown_1; // world object related? must have 24 byte stride
	uint unknown_1_count;

	Surface* surfaces;
	uint surface_count;

	LeafList* leaf_lists; // leaf lists?
	uint leaf_list_count;

	Leaf* leaves;
	uint leaf_count;

	Buffer** unknown_3; // unsure, seems to have random data
	uint unknown_3_count;

	uint unknown_4; // possible address? possible flag for something?

	Node* nodes_duplicate; // nodes duplicate? Possible root_node?
	Buffer* unknown_1_duplicate; // why? Possible root_unknown_1?

	Polygon** polygons; // polygons?
	uint polygon_count;

	vec4* points; // w is set to 0 on frame start when called from WorldBSP.Points[n]
	uint point_count;

	Portal* portals;
	uint portal_count;

	const char* textures_begin; // combined texture string
	const char** textures; // array of indexes to texture_string
	uint texture_count;

	/// No clue if this is actually here, or pointed to

	int[26] unknown_10;
	void*[2] unknown_11;

	vec3 extents_min;
	vec3 extents_max;

	vec3 extents_plus_min; // extents_min - 100, don't know why
	vec3 extents_plus_max; // extents_max + 100

	uint info_flags;
	uint unknown_count;

	//int unknown_12;
	float[4] unknown_12;

	void* unknown_13;
	uint world_flags;
	void* unknown_14;

	ubyte* leaf_list_contents; // dense packed 1D array, LeafList.data[0..LeafList.length]

	PBlockTable pblock_table;
}