module WorldBsp;

import RendererTypes: DLink, DString, Buffer;
import Texture;
import Objects.BaseObject;

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
	WorldBsp* bsp;
	vec3 center;
	float radius;
	ObjectList* objects; // unsure
	Node*[2] next;

	static assert(this.sizeof==52);
}

enum SurfaceFlags : uint
{
	Solid=0x1,
	NonExistant=0x2,
	Invisible=0x4,
	Transparent=0x8,
	Sky=0x10,
	Bright=0x20,
	GouraudShade=0x40,
	LightMap=0x80,
	NoSubDiv=0x200,
	Hullmaker=0x400,
	AlwaysLightMap=0x800,
	DirectionalLight=0x1000,

	Unknown=0x8000, // checked by renderer but unclear function
}

struct Surface
{
	vec3[6] opq_map; // [0..2] = UV, [3..4] = lightmap UV? [5] = ???
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

	Polygon** polygons; // pointer into WorldBsp.unknown_2 or copy node's polygon list pointer? 4 byte stride
	uint polygon_count; // set to 0 at the start of each frame draw?

	Buffer* unknown_7; // not a pointer!
	int unknown_8; // leaf list id? flags?

	static assert(this.sizeof==48);
}

struct Polygon // drawn with D3DPT_TRIANGLEFAN/GL_TRIANGLE_FAN
{
	vec3 center;
	float radius;

	Surface* surface;

	void* unknown_1a;
	Polygon* next; // [1] = Polygon* next? lightmap texture pointer? pointer to light objects? free space?
	void* unknown_1b;
	vec3 polygon_list; // from PolygonList in the dat

	void* lightmap_page; // vulkan surface in our case
	ubyte[4] lightmap_info; // w*2, h*2, w, h? //void* lightmap_texture; // possibly for our created lightmap RenderTexture?
	ubyte* lightmap_data;

	ushort unknown; // set to 0 on frame start?
	ushort frame_code;

	int is_lightmapped; // unknown

	ushort vertex_count;
	ushort vertex_extra;

	struct DiskVert
	{
		vec4* vertex_data;
		vec2 uv; // filled in some time after CreateContext call
		vec2 lightmap_uv; // filled in after paging lightmaps
		ubyte[4] colour;
	}
	private DiskVert vertices; // this is intended to be drawn as a triangle fan: [0, 1, 2], [0, 2, 3], [0, 3, 4], [0, 4, 5], etc.

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

public void GenerateLightmapUvs(ref Polygon poly)
{
	if (poly.lightmap_data==null)
	{
		poly.surface.flags=poly.surface.flags & (~SurfaceFlags.LightMap) | SurfaceFlags.DirectionalLight;
		// return; is it safe to skip?
	}

	foreach(ref disk_vert; poly.DiskVerts()) // For reference: d3d.ren @ 0x100374c2
	{
		immutable _lightmap_scale=1f/64f;

		vec3 diff=disk_vert.vertex_data.xyz-poly.polygon_list;

		float unk_x=(diff*poly.surface.opq_map[3])*0.05+0.5;
		float unk_y=(diff*poly.surface.opq_map[4])*0.05+0.5;

		disk_vert.lightmap_uv.x=unk_x;
		disk_vert.lightmap_uv.y=unk_y;
	}
}

struct MainWorld
{
	uint memory_used;
	WorldBsp* world_bsp;

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

struct WorldData
{
	WorldBsp*[2] objs; // orig + transformed?

	// DLink?; may not even be part of this struct at all?
	void*[2] refs; //  [0, 1] = ???
	WorldData* self;
}

struct WorldBsp
{
	uint memory_used; // memory use, maybe?
	void* next_section; // yes, in the map.dat...

	Plane* planes;
	uint plane_count;

	Node* nodes;
	uint node_count;

	ObjectList* world_models; // must have 24 byte stride
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

	Node* root_node;
	ObjectList* world_model_root;

	Polygon** polygons; // polygons?
	uint polygon_count;

	vec4* points; // w is set to 0 on frame start when called from WorldBsp.Points[n]
	uint point_count;

	Portal* portals;
	uint portal_count;

	const char* textures_begin; // combined texture string
	const char** textures; // array of indexes to texture_string
	uint texture_count;

	/// No clue if this is actually here, or pointed to
	int[26] unknown_10;

	BaseObject* owner_obj; // will always be (type_id==WorldModel || type_id==Container); EXCEPTION: g_RenderContext.main_world.world_bsp's will always be type_id==Normal
		// sometimes this can be null, don't know why this happens!

	void* unknown_11;

	// possibly skybox related?
	vec3 extents_min;
	vec3 extents_max;

	vec3 extents_plus_min; // extents_min - 100
	vec3 extents_plus_max; // extents_max + 100

	uint info_flags;
	uint unknown_count;

	float unknown_12;

	vec3 unknown_vector; // some sort of translation?

	ubyte* lightmap_data; // no size for this; polygons[0..polygon_count].select(x => x.flags & LightMap (0x80)) [w 1B, h 1B, data (w * h * 2B)] as RGB565 packed short

	uint world_flags; // frame code?

	void* unknown_14; // diskvert data?
	ubyte* leaf_list_contents; // dense packed 1D array, LeafList.data[0..LeafList.length]

	PBlockTable pblock_table;

	static assert(this.sizeof==360);
	static assert(owner_obj.offsetof==216);
}