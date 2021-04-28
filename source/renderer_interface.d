module RendererTypes;

import core.sys.windows.windows;

extern(C) @nogc nothrow:

struct RenderStructInit // final answer, the function zeros 420 bytes before filling this
{
	//int version_;
	Mode mode;
	void* main_window;

	static assert(RenderStructInit.sizeof==424);
}

struct Mode // confirmed to be RMode_t from basedefs
{
	byte is_hardware;

	char[200] filename; // What DLL this comes from.
	char[100] driver_name; // This is what the DLLs use to identify a card.
	char[100] display_name; // This is a 'friendly' string describing the card.

	// 3 align bytes here

	int width, height;
	uint depth;
	Mode* next;

	static assert(Mode.sizeof==420);
}

struct RenderContextInit
{
	void*[5] buf; // [0] = pointer to MainWorld?
	void* list_end; // byte 24
	void* list_head;// byte 28
	void*[48] buf2;
}

struct RenderContext // this is whatever we want to make it
{
	char[4] unknown_1;
	int unknown_2; // 0x0000FFFF?
	//RenderContextInit init_ptr;

	MainWorld* main_world;

	//byte[1072-12] buf;
}

struct MainWorld
{
	void* unknown_1;
	WorldBSP* world_bsp; // possibly?

	int[5] unknown_2;
	float[4] unknown_3;
	int[8] unknown_4;

	float[3][6] unknown_vectors_1; // maybe
	int unknown_5;
	void*[2] unknown_6;
	int[2] unknown_7;

	void*[64] buf;
}

struct WorldBSP
{
	void*[3] unknown_addresses;

	uint plane_count;
	void* planes;

	uint polygon_count;
	void* polygons;

	uint unknown_1;
	void* unknown_1_ptr;

	uint surface_count;
	void* surfaces;

	uint unknown_2;
	void* unknown_2_ptr;

	uint leaf_count;
	void* leaves;

	uint unknown_3;
	uint unknown_4;
	void* unknown_4_ptr;
	void* unknown_5;
	void* unknown_6;

	uint unknown_7;
	void* unknown_7_ptr;

	uint point_count;
	void* points;

	uint portal_count;
	void* portals;

	void* unknown_8;

	uint unknown_9; // flags?

	int[26] unknown_10;
	void*[2] unknown_11;

	float[3] extents_min;
	float[3] extents_max;

	float[3] extents_plus_min; // extents_min - 100, don't know why
	float[3] extents_plus_max; // extents_max + 100

	void*[256] buf;
}

struct SharedTexture
{
	int[34] buf;
}

enum DrawMode : int
{
	Normal=1,
	ObjectList,
}

struct SceneDesc
{
	DrawMode draw_mode;

	// debug text
	uint* ticks_render_objects;
	uint* ticks_render_models;
	uint* ticks_render_sprites;
	uint* ticks_render_worldmodels;
	uint* ticks_render_particles;
	uint* ticks_render_unknown;

	// global lighting?
	float[3] global_light;
	float[3] global_light_scale;
	RenderContext* render_context;
	float[9] unknown_array_1;
	float[3] camera_unknown;

	// frame timing
	float frame_delta;
	uint frame_ticks;

	// unknown
	float[9] unkown_matrix;
	float[3] unknown_vector;
	int* unknown_array_2;
	int unknown_count;

	// camera stuff
	Rect view_rect;
	float fov_x, fov_y;
	float far_clipping_plane;
	float[3] camera_position;
	float[4] camera_rotation;

	// object list
	void** obj_list_head;
	int obj_count;

	// model hook
	void function(void* /+ModelHookData*+/ pData, void* pUser) model_hook_fnc_ptr;
	void* model_hook_user;

	static assert(SceneDesc.sizeof==240);
}

struct Rect // possibly DirectX struct?
{
	int x1;
	int y1;
	int x2;
	int y2;
}

struct BlitRequest
{
	void* surface_ptr;
	int unknown_1;
	int unknown_2;
	void* source_ptr;
	void* dest_ptr;
	void*[32] buf;
}

// borrowing DLink and DList from Blood 2's dlink.h
struct DLink
{
	DLink* prev, next;
	void* data;
}

struct DList
{
	uint elements;
	DLink head;
}

struct DEPalette
{
	//
}

struct RenderDLL
{
	void function(void* /+DObject*+/, void* /+*(DObject + 0x34)+/) AttachmentSomething; // called by ProcessAttachment
	void* function(void*) SetPanningSkyInfo; // GetTexture?
	void function() SomethingPanningSkyInfo; // FreeTexture?
	void function() UnknownFunc_1;
	void function() UnknownFunc_2;
	void function() UnknownFunc_3;
	void function() UnknownFunc_4;
	void function(const char*) RunConsoleString;
	void function(const char* pMsg, ...) CPrint;
	void* function(const char*) GetConsoleVar;
	float function(void*) GetVarValueFloat;
	const char* function(void*) GetVarValueString;
	void* function() UnknownFunc_5; // does nothing
	int screen_width;
	int screen_height;
	int is_init;
	int unknown_1;
	int unknown_2;
	int lightmap_memory_use; // total texture allocs? unknown
	int memory_saved; // unknown
	int function(RenderStructInit*) Init;
	void function() Term;
	void function(SharedTexture**) SetSoftSky;
	void function(SharedTexture*, int) BindTexture;
	void function(SharedTexture*) UnbindTexture;
	int function(DEPalette*) QueryDeletePalette;
	int function(SharedTexture*) SetMasterPalette;
	void* function(RenderContextInit*) CreateContext;
	void function(RenderContext*) DeleteContext;
	void function(Rect*, uint) Clear;
	int function() Start3D;
	int function() End3D;
	int function() IsIn3D;
	int function() StartOptimized2D;
	void function() EndOptimized2D;
	int function() IsInOptimized2D;
	int function(SceneDesc*) RenderScene;
	void function(int argc, char** args) RenderCommand;
	uint function(const char*) GetHook;
	void function() SwapBuffers;
	int function() GetInfoFlags;
	int function() GetBufferFormat;
	SharedTexture* function(int, int) CreateSurface;
	void function(SharedTexture*) DeleteSurface;
	void function(SharedTexture*, int*, int*, int*) GetSurfaceInfo;
	void* function(SharedTexture*) LockSurface;
	void function(SharedTexture*) UnlockSurface;
	int function(void*, uint) OptimizeSurface;
	void function(void*) UnoptimizeSurface;
	int function(int, int, int, int, void**, int*) LockScreen;
	void function() UnlockScreen;
	void function(BlitRequest*) BlitToScreen;
	void function(const char*) MakeScreenShot;
	void function() ReadConsoleVariables;
	void* unknown_3;
	SharedTexture* envmap_texture;
	void* panning_sky_info;
	void*[4] unknown_arrays; // somehow grouped
	void* unknown_array;
	int unknown_4;
	int unknown_5;
	int unknown_6;
	int unknown_7;
	HMODULE render_dll_handle;
	DLink* unknown_8; // Related(?): #define MAX_SKYOBJECTS 30 // Maximum number of sky objects.
	uint unknown_9; // unknown
}