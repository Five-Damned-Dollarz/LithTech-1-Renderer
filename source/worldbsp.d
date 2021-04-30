module WorldBSP;

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
	void* unknown_2; // possible address?
	WorldBSP* bsp;
	float[4] unknown_3;
	Object* objects; // unsure
	Node* next;

	static assert(this.sizeof==48);
}

struct Surface
{
	float[3][6] opq_map;
	void* unknown_1;
	Plane* plane; // unsure?
	uint flags;
	ushort texture_id;
	ushort texture_flags;
	uint unknown_2;

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
	Buffer* unknown_2; // start?
	Buffer* unknown_3; // end?
	Buffer* unknown_4; // next, if start != end?
	Buffer* unknown_5; // entry to Buffer** unknown_3?
	int unknown_6;
	Buffer* unknown_7;
	int unknown_8;

	static assert(this.sizeof==48);
}

struct Polygon
{
	float[4] vector_1; // looks like (WorldModel?) node rotation?
	Surface* surface;
	int[3] buf1;
	float[3] vector_2; // from polygon list
	int[2] buf2;
	ushort[2] unknown_1; // [1] = some id?
	short[2] unknown_2; // [0] = maybe next id, to create loops?
	int[3] buf3;
	float[3] vector_3; // from point list?
	int[5] buf4;

	static assert(this.sizeof==104);
}

struct Vector
{
	float[3] xyz;
}

struct Buffer // just for testing!
{
	Buffer*[32] buf;
}

struct MainWorld
{
	uint unknown_1; // memory used?
	WorldBSP* world_bsp;

	ushort[2] unknown_2; // not an address!
	int unknown_2_count;

	int[3] unknown_3;
	float[4] unknown_4;
	int[8] unknown_5;
	void* unknown_6;

	float[3][6] unknown_vectors_1; // maybe
	int unknown_7;
	void* unknown_8;

	Buffer** unknown_9;
	int unknown_9_count;

	//int[2] unknown_9;

	//void*[64] buf;

	static assert(this.sizeof>=168);
}

struct WorldBSP
{
	uint unknown_0; // memory use, maybe?
	void* next_section; // yes, in the map.dat...

	Plane* planes;
	uint plane_count;

	Node* nodes;
	uint node_count;

	Buffer* unknown_1;
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

	Vector* points;
	uint point_count;

	Portal* portals;
	uint portal_count;

	const char* texture_string; // combined texture string?
	const char** textures; // array of indexes to texture_string?

	uint unknown_9; // flags?

	int[26] unknown_10;
	void*[2] unknown_11;

	float[3] extents_min;
	float[3] extents_max;

	float[3] extents_plus_min; // extents_min - 100, don't know why
	float[3] extents_plus_max; // extents_max + 100

	uint info_flags;
	uint unknown_count;

	int[4] unknown_12;

	void*[3] unknown_14;

	ubyte* leaf_list_contents; // dense packed 1D array, LeafList.data[0..LeafList.length]

	PBlockTable pblock_table;
}