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

	char[200] filename;		// What DLL this comes from.
	char[100] driver_name;	// This is what the DLLs use to identify a card.
	char[100] display_name;		// This is a 'friendly' string describing the card.

	// 3 align bytes here

	int width, height;
	uint depth;
	Mode* next;

	static assert(Mode.sizeof==420);
}

struct RenderContextInit
{
	int[64] buf;
}

struct RenderContext
{
	char[8] unknown_1;
	RenderContextInit *init_ptr;
	int unknown_2; // 0x0000FFFF?

	static assert(RenderContext.sizeof==0x10);
}

struct SharedTexture
{
	int[34] buf;

	// 136 bytes min?

	static assert(SharedTexture.sizeof==136);
	// static assert(SharedTexture.sizeof>=0x23+width*height*2); // 0x23+width*height*2
}

struct SceneDesc
{
	//
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

struct DEPalette
{
	//
}

struct RenderDLL
{
	void* UnknownFunc;
	void* function(void*) SetPanningSkyInfo; // GetTexture?
	void* SomethingPanningSkyInfo; // FreeTexture?
	void* UnknownFunc_1;
	void* UnknownFunc_2;
	void* UnknownFunc_3;
	void* UnknownFunc_4;
	void function(const char*) RunConsoleString; // RunConsoleString?
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
	void function(SharedTexture*, char*) BindTexture;
	void function(SharedTexture*) UnbindTexture;
	int function(DEPalette*) QueryDeletePalette;
	int function(SharedTexture*) SetMasterPalette;
	void* function(RenderContextInit*) CreateContext;
	void function(RenderContext*) DeleteContext;
	void function(Rect*, uint) Clear;
	bool function() Start3D;
	bool function() End3D;
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
	void function(SharedTexture*, out int, out int, out int) GetSurfaceInfo;
	void* function(SharedTexture*) LockSurface;
	void function(SharedTexture*) UnlockSurface;
	int function(void*, uint) OptimizeSurface;
	void function(void*) UnoptimizeSurface;
	int function() LockScreen;
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
	TestStruct* unknown_8; // unknown
	uint unknown_9; // unknown
}

struct TestStruct
{
	int[90] buffer;
}

struct ConVar
{
	char* name;
	int int_cache; // possible "is_set"?
	float float_cache;
	float default_value=0.0;
	void* engine_cvar;

	static assert(ConVar.sizeof==20);
}