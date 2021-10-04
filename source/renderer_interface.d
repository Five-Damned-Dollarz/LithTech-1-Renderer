module RendererTypes;

import WorldBsp;
import Texture;
import Objects.BaseObject;
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
align(4):
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

struct RenderContext // this is whatever we want; should probably save lightmaps in here
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
	vec3 global_light_colour;
	vec3 global_light_direction;
	vec3 global_light_scale;
	float[3] camera_unknown;

	// frame timing
	float frame_delta;
	uint frame_ticks;

	// unknown
	float[9] unkown_matrix;
	float[3] unknown_vector;
	BaseObject** unknown_array_2; // world model array? limited to max 30?
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
	void function(void* /+ ModelHookData* +/ pData, void* pUser) model_hook_fnc_ptr;
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

struct DString
{
	DLink link;
	uint is_init; // flags?
	ushort length_real;
	ushort length;
	char data; // possibly in place array?

	@property string ToString() const
	{
		return (&data)[0..length].idup;
	}

	static assert(data.offsetof==20);
}

enum ClearFlags : uint
{
	Colour=0x1,
	Depth=0x2,
}

enum GlobalPanType
{
	SkyShadow=0,
	FogLayer,
	Count
}

struct GlobalPan
{
	SharedTexture* texture_ref;
	vec2 offset;
	vec2 scale;
}

extern(C)
struct RenderDLL
{
	BaseObject* function(BaseObject*, Attachment*) GetAttachmentObject; // called by ProcessAttachment
	TextureData* function(SharedTexture*, void* /+ out bool? +/) GetTexture;
	void function(SharedTexture*) FreeTexture;
	/+ --- Fairly confident these are palette functions +/
	DEPalette* function(DLink*) DLinkToPalette; // this is the only reasonable guess I have
	Colour* function(DEPalette*) GetPaletteColours; // return (param_1 + 0x18)
	void* function(DEPalette*) GetPaletteUnknownFunc; // returns DEPalette*? return *(param_1 + 0xC)
	void function(DEPalette*, void*) SetPaletteUnknownFunc; // void return; *(param_1 + 0xC) = param2
	/+ --- +/
	void function(const char*) RunConsoleString;
	void function(const char* pMsg, ...) CPrint;
	void* function(const char*) GetConsoleVar;
	float function(void*) GetVarValueFloat;
	const char* function(void*) GetVarValueString;
	void* function() UnknownFunc_5; // does nothing in d3d.ren

	version(LITHTECH_1_5)
	{
		/+ No idea what these do yet +/
		void* function() Alloc4Bytes;
		void function(void*) Free4Bytes;
		void function() UnknownFunc_x;
	}

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
	void function(int argc, const char** args) RenderCommand;
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

	version(LITHTECH_1_5)
	{
		/+ I'm not sure of any of these! +/
		void function(void*) GetBackBufferCount;
		void function() CreateNewBackBuffer;
		void function(char* /+ file name +/, int /+ width +/, int /+ height +/) CreateImageFile; // unsure what it's saving
		void function(void*) SetEnvironmentMapTexture;
		void function(void*) SetGlobalSomething; // copies 24 bytes, possibly a texture?
		void function(byte) EnableSomeMatrixMagic;
	}

	void* unknown_3;
	SharedTexture* envmap_texture;
	GlobalPan[GlobalPanType.Count] global_pans;
	HMODULE render_dll_handle;

	struct PaletteList
	{
		DLink[30] palettes; // *cast(DEPalette*)palettes.data
		uint count;

		static assert(this.sizeof==364);
	}
	PaletteList* palette_list; // Related(?): #define MAX_SKYOBJECTS 30 // Maximum number of sky objects.

	static assert(render_dll_handle.offsetof==264);
}