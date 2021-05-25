module RendererTypes;

import WorldBSP;
import Texture;
import vk.Surface;

import gl3n.linalg;

import core.sys.windows.windows;

struct Buffer // just for testing!
{
	Buffer*[32] buf;
}

struct RenderStructInit
{
	//int version_;
	Mode mode;
	void* main_window;

	static assert(this.sizeof==424);
}

struct Mode // RMode_t from basedefs
{
	byte is_hardware;

	char[200] filename; // What DLL this comes from.
	char[100] driver_name; // This is what the DLLs use to identify a card.
	char[100] display_name; // This is a 'friendly' string describing the card.

	// 3 align bytes here

	int width, height;
	uint depth;
	Mode* next;

	static assert(this.sizeof==420);
}

struct RenderContextInit
{
	MainWorld* main_world;
	void*[4] buf;
	void* list_end; // byte 24
	void* list_head;// byte 28
	void*[48] buf2;
}

struct RenderContext // this is whatever we want
{
	Buffer* unknown_1;
	int unknown_2; // 0x0000FFFF? "framecode"

	MainWorld* main_world;
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

	float[3] unknown_1;
	float[3] unknown_2;
	RenderContext* render_context;
	float[3] global_light_colour;
	float[3] global_light_direction;
	float[3] global_light_scale;
	float[3] camera_unknown;

	// frame timing
	float frame_delta;
	uint frame_ticks;

	// unknown
	float[9] unkown_matrix;
	float[3] unknown_vector;
	UnknownObject** unknown_array_2; // world model array?
	int unknown_count;

	// camera stuff
	Rect view_rect;
	float fov_x, fov_y;
	float far_clipping_plane;
	vec3 camera_position;
	float[4] camera_rotation; // can't use gl3n's quat because w is first, when it's last in DRotation

	// object list (for DrawMode.ObjectList)
	void** obj_list_head;
	int obj_count;

	// model hook
	void function(void* /+ModelHookData*+/ pData, void* pUser) model_hook_fnc_ptr;
	void* model_hook_user;

	static assert(this.sizeof==240);
}

struct Rect // possibly DirectX struct?
{
	int x1;
	int y1;
	int x2;
	int y2;
}

enum LTPixelFormat : int
{
	RGB_565=0,
	RGB_555,
}

enum BlitRequestFlags : uint
{
	ColourKey=0x1
}

struct BlitRequest
{
	ImageSurface* surface_ptr;
	BlitRequestFlags flags;
	ushort colour_key;
	private ushort buf;
	Rect* source_rect;
	Rect* dest_rect;

	void* unknown;
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
	DLink link;
	int[3] unknown;
	Colour[256] colours;
}

enum ClearFlags : uint
{
	Colour=0x1,
	Depth=0x2,
}

extern(C)
struct RenderDLL
{
	/+ DObject* +/ UnknownObject* function(UnknownObject* /+ DObject* +/, Attachment*) AttachmentSomething; // called by ProcessAttachment
	TextureData* function(SharedTexture*, void* /+ out bool? +/) GetTexture;
	void function(SharedTexture*) FreeTexture;
	void function() UnknownFunc_1;
	void function() UnknownFunc_2;
	void function(/+ DEPalette*? +/) UnknownFunc_3; // returns DEPalette*?
	void function() UnknownFunc_4;
	void function(const char*) RunConsoleString;
	void function(const char* pMsg, ...) CPrint;
	void* function(const char*) GetConsoleVar;
	float function(void*) GetVarValueFloat;
	const char* function(void*) GetVarValueString;
	void* function() UnknownFunc_5; // does nothing in d3d.ren
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
	int function(DEPalette*) QueryDeletePalette; // unknown
	int function(SharedTexture*) SetMasterPalette;
	void* function(RenderContextInit*) CreateContext;
	void function(RenderContext*) DeleteContext;
	void function(Rect*, ClearFlags) Clear;
	int function() Start3D;
	int function() End3D;
	int function() IsIn3D;
	int function() StartOptimized2D;
	void function() EndOptimized2D;
	int function() IsInOptimized2D;
	int function(SceneDesc*) RenderScene;
	void function(int argc, char** args) RenderCommand;
	void* function(const char*) GetHook; // must handle "LPDIRECTDRAW" (IDirectDraw4*) and "BACKBUFFER" (IDirectDrawSurface4*) to support Smack video
	void function() SwapBuffers;
	int function() GetInfoFlags;
	LTPixelFormat function() GetBufferFormat;
	ImageSurface* function(const int, const int) CreateSurface;
	void function(ImageSurface*) DeleteSurface;
	void function(ImageSurface*, int*, int*, int*) GetSurfaceInfo;
	void* function(ImageSurface*) LockSurface;
	void function(ImageSurface*) UnlockSurface;
	/+ --- These probably also take ImageSurface* +/
	int function(void* /+ ImageSurface*? +/, uint) OptimizeSurface;
	void function(void* /+ ImageSurface*? +/) UnoptimizeSurface;
	int function(int, int, int, int, void**, int*) LockScreen;
	void function() UnlockScreen;
	/+ --- +/
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
	DLink* unknown_8; // 364 bytes, array of 30 DLinks + an int. Looks very much like palette data; cast(DEPalette*)unknown_8[i].data - Related(?): #define MAX_SKYOBJECTS 30 // Maximum number of sky objects.
	uint unknown_9; // unknown
}