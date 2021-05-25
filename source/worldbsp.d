module WorldBSP;

import RendererTypes: DLink, Buffer;
import Model;
import Texture;

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

enum NodeFlags
{
	// 0x1
	// 0x2
	Unknown=0x8, // very important, possibly visible?
}

struct Node
{
	NodeFlags flags; // unknown, (flags & 8) seems important
	Polygon* polygons;
	Plane* planes;
	int side; // 0 = front, 6 = back
	Leaf* viewer_leaf; // leaf a camera's currently in? mostly null
	WorldBSP* bsp;
	vec3 center;
	float radius;
	UnknownList* objects; // unsure
	Node*[2] next;

	static assert(this.sizeof==52);
}

struct Surface
{
	vec3[6] opq_map;
	SharedTexture* shared_texture; // not filled when recieved by CreateContext
	Plane* plane;
	SurfaceFlags flags; // top byte = surface effect? bottom 3 bytes = flags
	ushort texture_flags;
	ushort texture_id;
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
	LeafList* leaf_list;
	Buffer* unknown_2; // start? -- in place DLink?
	Buffer* unknown_3; // end?
	Buffer* unknown_4; // next, if start != end?
	Buffer* unknown_5; // pointer into WorldBSP.unknown_2 or copy node's polygon list pointer? 4 byte stride
	int unknown_6; // set to 0 at the start of each frame draw; unknown_5 count?
	Buffer* unknown_7;
	int unknown_8; // leaf list id?

	static assert(this.sizeof==48);
}

struct Polygon // drawn with D3DPT_TRIANGLEFAN/GL_TRIANGLE_FAN?
{
	vec3 center;
	float radius;

	Surface* surface;

	float unknown_1a;
	Polygon* next; // [1] = Polygon* next?
	float unknown_1b;
	vec3 polygon_list; // from PolygonList in the dat

	void* unknown_2;
	void* lightmap_texture; // possibly for our created lightmap RenderTexture?
	ubyte* lightmap_data;

	ushort unknown; // set to 0 on frame start?
	ushort frame_code;

	int is_lightmapped; // unknown

	ushort vertex_count;
	ushort vertex_extra;

	struct DiskVert
	{
		vec4* vertex_data;
		vec2 uv; // not normalized, will need texture dimensions to tile in Vulkan; not filled in by CreateContext call
		private vec2 pad; // unsure if this is used
		ubyte[4] colour;
	}
	DiskVert vertices; // this is intended to be drawn as a triangle fan: [0, 1, 2], [0, 2, 3], [0, 3, 4], [0, 4, 5], etc.

	/// only draw one of the following sets or you get z-fighting where DiskExtras has extra cuts in the faces
	@property DiskVert[] DiskVerts() return
	{
		return (&vertices)[0..(vertex_count)];
	}

	@property DiskVert[] DiskExtras() return // this set of triangles is for FixTJunc
	{
		return (&vertices)[(vertex_count)..(vertex_count+vertex_extra)];
	}

	static assert(lightmap_data.offsetof==52);
	static assert(this.sizeof>=72); // smallest runtime case possible should be 212?
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
	vec3 unknown_7; // extents?
	vec3 extents_min; // extents -200
	vec3 extents_max; // extents +200
	vec3 extents_normal; // 1f / (max - min)
	int unknown_8;
	void* unknown_9;

	WorldData** world_models;
	uint world_model_count;
	int unknown_10; // dupe of world_model_count?

	MainWorld* self; // unsure?
	void* self_unknown;

	int[5] buf;

	MainWorld* self2; // same as RenderContextInit.main_world

	//int[2] unknown_9;
	//void*[64] buf;

	static assert(self.offsetof==172);
	static assert(this.sizeof>=168);
	static assert(this.sizeof==204);
}

struct UnknownList // WorldModelList? Something Node related?
{
	UnknownList* prev;
	UnknownList* next;
	UnknownObject* data;

	Node* node;
	UnknownList*[2] buf; // [0] = Node*? [1/2] = other entries in the list?

	static assert(this.sizeof==24);
}

struct Attachment
{
	vec3 position;
	float[4] rotation;
	ushort unknown;
	ushort unknown_id; // count or id
	uint node_id; // -1 = no node
	Attachment* next;
}

struct UnknownObject // This is the base Object; Model, WorldModel, Sprite, Light, ParticleSystem, LineSystem, Polygrid, and Container derive from it
{
	DLink link;
	DLink link_unknown; // maybe not even a link?
	Buffer* list; // unknown

	void*[2] unknown_1; // suspect functors based on object type id from engine

	Buffer* root; // UnknownList? static assert(root.offsetof==36)

	ModelFlags flags;
	uint user_flags;

	ubyte[4] colour;

	Attachment* attachments;
	vec3 position;
	float[4] rotation;
	vec3 scale;

	float unknown_5;
	short[2] unknown_6;
	short ffff; // unknown, is set to FFFF on creation, possible bitmask for what's updated
	short[2] frame_code; // [108] is set to 0 on frame start

	ObjectType type_id;
	ubyte block_priority;

	float unknown_7;
	vec3 velocity;
	vec3 acceleration;
	float friction_coeff;
	float mass;
	float force_ignore_limit;
	int unknown_8;
	int unknown_9;

	vec3 bounds_min_relative;
	vec3 bounds_max_relative;
	vec3 dimensions;

	void*[5] buf1;

	Buffer* self1;

	uint state;

	void*[4] buf2;
	Buffer*[3] self2;
	void*[7] buf3;
	Buffer* self3;
	uint client_user_flags;
	void* buf4;
	Buffer* class_;

	// probably where "base" Object ends and derived data begins?
align(2):
	short buf4a;
	WorldData* bsp;

	void*[4] buf5;
	short buf6;

	Buffer* model_nodes;

	//mat4 mat4_unknown_2;
	//mat4 mat4_unknown_3;

	//Buffer[4] buf2;

	//pragma(msg, this.sizeof);
	static assert(this.sizeof>=108);
	static assert(flags.offsetof==40);
	static assert(colour.offsetof==48); // if colour[4] (alpha) is not 0xFF then add to transparent draw list instead of solid
	static assert(attachments.offsetof==52);
	//static assert(???.offsetof==84); for type_id=ParticleSystem, unsure what these values are for
	static assert(type_id.offsetof==110);
	//static assert(???.offsetof==124); unsure what this is yet, but it's necessary for visibility?
	static assert(client_user_flags.offsetof==284);
	static assert(class_.offsetof==292);
	//static assert(light_radius.offsetof==296); for type_id=Light, possibly padded to 298?
	static assert(bsp.offsetof==298); // for type_id=WorldModel
	//static assert(???.offsetof==316); polygon pointer?
	static assert(model_nodes.offsetof==320); // for type_id=Model, if 0 skip adding to draw list; possible pointer to model nodes?
	// possibly 300 byte stride for BaseObject?
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

	UnknownList* world_models; // must have 24 byte stride
	uint world_models_count;

	Surface* surfaces;
	uint surface_count;

	LeafList* leaf_lists; // leaf lists?
	uint leaf_list_count;

	Leaf* leaves;
	uint leaf_count;

	short* unknown_3; // 2 byte stride? unsure, seems to have random data
	uint unknown_3_count;

	uint unknown_4; // leaf_list_contents length? possible address? possible flag for something?

	Node* node_root;
	UnknownList* world_model_root;

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

	// possibly skybox related?
	vec3 extents_min;
	vec3 extents_max;

	vec3 extents_plus_min; // extents_min - 100
	vec3 extents_plus_max; // extents_max + 100

	uint info_flags;
	uint unknown_count;

	//int unknown_12;
	float[4] unknown_12;

	ubyte* lightmap_data; // no size for this; polygons[0..polygon_count].select(x => x.flags & LightMap (0x80)) [w 1B, h 1B, data (w * h * 2B)] as RGB565 packed short

	uint world_flags; // frame code?

	void* unknown_14; // diskvert data?
	ubyte* leaf_list_contents; // dense packed 1D array, LeafList.data[0..LeafList.length]

	PBlockTable pblock_table;

	static assert(this.sizeof==360);
}