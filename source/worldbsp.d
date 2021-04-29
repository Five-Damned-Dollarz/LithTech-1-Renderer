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
	int unk_1;
	int unk_2;
	int unk_3;
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
	void* unknown_1;
	void* unknown_2;
	WorldBSP* bsp;
	float[4] unknown_3;
	Object* objects; // unsure
	Node* next; // unsure
	void* unknown_4;

	static assert(this.sizeof==52);
}

struct Surface
{
	float[3][6] opq_map;
	void*[5] buf; // unknown
}

struct LeafList
{
	short portal_id;
	ushort length;
	ubyte* data;
}

struct Leaf
{
	float[10] buf;
	float unknown_float;
	float buf2;
}

struct Polygon
{
	float[3] vector_1;
	int[5] buf;
	float[3] vector_2;
	int[7] buf2;
	float[3] vector_3;
	int[5] buf3;

	static assert(this.sizeof==104);
}

struct Vector
{
	float[3] xyz;
}

struct Buffer // just for testing!
{
	void*[16] buf;
}

struct MainWorld
{
	uint unknown_1; // memory used?
	WorldBSP* world_bsp;

	int[5] unknown_2;
	float[4] unknown_3;
	int[8] unknown_4;
	void* unknown_5;

	float[3][6] unknown_vectors_1; // maybe
	int unknown_6;
	void*[2] unknown_7;
	int[2] unknown_8;

	void*[64] buf;
}

struct WorldBSP
{
	uint unknown_0; // memory use, maybe?
	void* next_section; // yes, in the map.dat...

	// unsure of many of these
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

	Buffer* unknown_3;
	uint unknown_3_count;

	uint unknown_4a;

	Node* nodes_duplicate; // nodes duplicate?
	Buffer* unknown_1_duplicate; // why?

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

	void*[4] unknown_14;

	PBlockTable pblock_table;

	//void*[16] buf;
}