module WorldBSP;

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

struct Polygon
{
	ushort[2] unknown_1;
	float[2] unknown_2;
	int id;
}

struct Surface
{
	float[3][6] opq_map;
	void*[5] buf; // unknown
}

struct Leaf
{
	float[10] buf;
	float unknown_float;
	float buf2;
}

struct Vector
{
	float[3] xyz;
}

struct Buffer // just for testing!
{
	void*[16] buf;
}

struct WorldBSP
{
	void*[2] unknown_addresses;

	// unsure of many of these
	Plane* planes;
	uint plane_count;

	Buffer* polygons;
	uint polygon_count;

	Buffer* unknown_1;
	uint unknown_1_count;

	Surface* surfaces;
	uint surface_count;

	Buffer* unknown_2;
	uint unknown_2_count;

	Leaf* leaves;
	uint leaf_count;

	Buffer* unknown_3;
	uint unknown_3_count;

	uint unknown_4a;
	void* unknown_4b;

	void* unknown_5;

	Buffer* unknown_7;
	uint unknown_7_count;

	Vector* points;
	uint point_count;

	Portal* portals;
	uint portal_count;

	void* unknown_8a;
	void* unknown_8b;

	uint unknown_9; // flags?

	int[26] unknown_10;
	void*[2] unknown_11;

	float[3] extents_min;
	float[3] extents_max;

	float[3] extents_plus_min; // extents_min - 100, don't know why
	float[3] extents_plus_max; // extents_max + 100

	void*[10] unknown_12;

	PBlockTable unknown_struct_1;

	//void*[64] buf;
}