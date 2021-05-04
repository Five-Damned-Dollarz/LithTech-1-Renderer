module WorldBSP;

import RendererTypes: DLink;

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
		short[2] unknown_1;
		void* unknown_ptr;
		int[2] unknown_2;
	}

	UnknownStruct* unknown_ptr;
	short[4] unknown_1;
	float[3] position;
	short[6] unknown_2;
}

struct Plane
{
	float[3] vector;
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
	float[3] center;
	float radius;
	Object* objects; // unsure
	Node*[2] next;

	static assert(this.sizeof==52);
}

struct Surface
{
	float[3][6] opq_map;
	void* unknown_1; // texture effect?
	Plane* plane;
	uint flags;
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
	float[4] vector;
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
	float[3] center;
	float radius;

	Surface* surface;

	float[3] unknown_1;
	float[3] polygon_list;
	void*[2] unknown_2;

	ushort unknown; // set to 0 on frame start?
	ushort frame_code;

	Buffer*[2] unknown_3;

	ushort vertex_count;
	ushort vertex_extra;

	struct DiskVert
	{
		Vector4* vertex_data;
		Vector4 unknown_1;
		ubyte[4] unknown_2;
	}
	DiskVert* vertices;

	@property DiskVert[] DiskVerts() return
	{
		return (cast(DiskVert*)&vertices)[0..vertex_count+vertex_extra];
	}

	static assert(this.sizeof>=72); // smallest runtime case possible should be 188?
}

struct Vector
{
	float[3] xyz;
}

struct Vector4
{
	float[4] xyzw; // w is set to 0 on frame start when called from WorldBSP.Points[n]
}

struct Buffer // just for testing!
{
	Buffer*[32] buf;
}

struct MainWorld
{
	uint memory_used;
	WorldBSP* world_bsp;

	ushort[2] unknown_2; // not an address?
	int unknown_2_count;

	int[4] unknown_3;
	float[3] unknown_4;

	Buffer* unknown_4a;
	uint unknown_4a_count;

	int[6] unknown_5;
	void* unknown_6;

	float[3][2] unknown_vectors_1; // maybe
	float[3][4] extents;
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
	Buffer* prev;
	Buffer* next;
	UnknownObject* data;

	Buffer*[3] buf;

	static assert(this.sizeof==24);
}

struct UnknownObject
{
	UnknownObject* prev;
	UnknownObject* next;

	int unknown_0;

	DLink link;
	UnknownList* list; // ?

	short[2] unknown_1;
	int unknown_2;

	UnknownObject* root; // ?
	void*[4] unknown_3;

	float[3] world_translation;
	float[4] rotation; // unknown
	float[3] unknown_4; // unknown

	short[4] unknown_5;
	short[2] frame_code; // maybe?

	// [108] is set to 0 on frame start

	static assert(this.sizeof>=108);
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

	Vector4* points;
	uint point_count;

	Portal* portals;
	uint portal_count;

	const char* textures_begin; // combined texture string
	const char** textures; // array of indexes to texture_string
	uint texture_count;

	/// No clue if this is actually here, or pointed to

	int[26] unknown_10;
	void*[2] unknown_11;

	float[3] extents_min;
	float[3] extents_max;

	float[3] extents_plus_min; // extents_min - 100, don't know why
	float[3] extents_plus_max; // extents_max + 100

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