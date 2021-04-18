import core.sys.windows.windows;
import core.sys.windows.dll;

//import std.string;
import std.stdio;
import core.stdc.stdlib;
import core.stdc.stdio;
import core.stdc.string;

import RendererTypes;
import RendererMain;

import bindbc.sdl;

extern(Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
	switch (ulReason)
	{
		case DLL_PROCESS_ATTACH:
			test_out.open("test.txt", "w");
			test_out.writeln("Process Attach:");

			auto ret=loadSDL();
			test_out.writeln(ret);
			test_out.flush();

			g_hInst=hInstance;

			dll_process_attach(hInstance, true);
			break;

		case DLL_PROCESS_DETACH:
			test_out.close();

			dll_process_detach(hInstance, true);
			break;

		case DLL_THREAD_ATTACH:
			dll_thread_attach(true, true);
			break;

		case DLL_THREAD_DETACH:
			dll_thread_detach(true, true);
			break;

		default:
	}
	return true;
}

void test(string pretty=__PRETTY_FUNCTION__)
{
    test_out.writeln(pretty);
    test_out.flush();
}


extern(C):

__gshared HINSTANCE g_hInst;

__gshared RenderDLL* _renderer;
__gshared HWND _window_main;
__gshared Renderer _renderer_inst;

__gshared File test_out;
__gshared ConVar[110] _convars;

__gshared bool _is_in_3D=false;

export Mode* GetSupportedModes()
{
	import std.string;
	import core.stdc.string;

	SDL_Init(SDL_INIT_VIDEO);

	int mode_count=SDL_GetNumDisplayModes(0);
	Mode[] modes=new Mode[mode_count];

	immutable string renderer_filename="d_ren.ren\0";
	const char* driver_name=SDL_GetCurrentVideoDriver();
	const char* display_name=SDL_GetDisplayName(0);

	foreach(int i, ref mode; modes)
	{
		SDL_DisplayMode sdl_mode;
		SDL_GetDisplayMode(0, i, &sdl_mode);

		mode.is_hardware=true;
		memcpy(mode.filename.ptr, renderer_filename.toStringz, 200 /*renderer_filename.length*/);
		memcpy(mode.driver_name.ptr, driver_name, 100);
		memcpy(mode.display_name.ptr, display_name, 100);
		mode.width=sdl_mode.w;
		mode.height=sdl_mode.h;
		mode.depth=(sdl_mode.format >> 8) & 0xFF;

		if (i<mode_count-1)
			mode.next=&modes[i+1];
	}

	SDL_Quit();

	return modes.ptr;
}

export void FreeModeList(Mode* modes_head)
{
	modes_head.destroy();
	modes_head=null;
}

export void RenderDLLSetup(RenderDLL* renderer)
{
	_renderer=renderer;
	renderer.Init=&Init;
	renderer.Term=&Term;
	renderer.SetSoftSky=&SetSoftSky;
	renderer.BindTexture=&BindTexture;
	renderer.UnbindTexture=&UnbindTexture;
	renderer.QueryDeletePalette=&QueryDeletePalette;
	renderer.SetMasterPalette=&SetMasterPalette;
	renderer.CreateContext=&CreateContext;
	renderer.DeleteContext=&DeleteContext;
	renderer.Clear=&Clear;
	renderer.Start3D=&Start3D;
	renderer.End3D=&End3D;
	renderer.IsIn3D=&IsIn3D;
	renderer.StartOptimized2D=&StartOptimized2D;
	renderer.EndOptimized2D=&EndOptimized2D;
	renderer.IsInOptimized2D=&IsInOptimized2D;
	renderer.RenderScene=&RenderScene;
	renderer.RenderCommand=&RenderCommand;
	renderer.GetHook=&GetHook;
	renderer.SwapBuffers=&SwapBuffers;
	renderer.GetInfoFlags=&GetInfoFlags;
	renderer.GetBufferFormat=&GetBufferFormat;
	renderer.CreateSurface=&CreateSurface;
	renderer.DeleteSurface=&DeleteSurface;
	renderer.GetSurfaceInfo=&GetSurfaceInfo;
	renderer.LockSurface=&LockSurface;
	renderer.UnlockSurface=&UnlockSurface;
	renderer.OptimizeSurface=&OptimizeSurface;
	renderer.UnoptimizeSurface=&UnoptimizeSurface;
	renderer.LockScreen=&LockScreen;
	renderer.UnlockScreen=&UnlockScreen;
	renderer.BlitToScreen=&BlitToScreen;
	renderer.MakeScreenShot=&MakeScreenShot;
	renderer.ReadConsoleVariables=&ReadConsoleVariables;

//	test_out.open("test.txt", "w");
	test_out.writeln("RenderDLLSetup called.");
	test_out.writeln(*_renderer);
	test_out.flush();
}

int Init(RenderStructInit* init_struct)
{
	init_struct.mode.is_hardware=true;

	test_out.writeln("Init called.");
	test_out.writeln(*init_struct);
	test_out.flush();

	_window_main=init_struct.main_window;
	_renderer.screen_width=init_struct.mode.width;
	_renderer.screen_height=init_struct.mode.height;

	_renderer_inst=new Renderer;
	_renderer_inst.InitFrom(_window_main);

	//_renderer.screen_depth=init_struct.mode.depth;
	//_renderer.window_flags=0x2; // 0x80000002 = fullscreen

	return 0;
}

void Term()
{
	_renderer_inst.destroy();
	_renderer_inst=null;
}

void SetSoftSky(SharedTexture** textures)
{
	test_out.writeln("SetSoftSky called.");
	//test_out.writeln(textures);
	test_out.writeln(*textures);
	test_out.flush();

	test_out.writeln("SoftSky Renderer:");
	test_out.writeln(*_renderer);
	test_out.writeln(*_renderer.unknown_8);
	test_out.flush();
}

void BindTexture(SharedTexture* texture, char* unknown)
{
	writeln(*texture);
	writeln(unknown);

	struct UnknownTextureData
	{
		void*[16] buf;
	}

	void* texture_ref=texture+0xC;

	if (!texture_ref)
	{
		UnknownTextureData* texture_data=cast(UnknownTextureData*)_renderer.SetPanningSkyInfo(cast(void*)texture);
		test_out.writeln(*texture_data);
	}

	test();
}

void UnbindTexture(SharedTexture*)
{
	test();
}

int QueryDeletePalette(DEPalette*)
{
	test();
	return 0;
}

int SetMasterPalette(SharedTexture*)
{
	test();
	return 0;
}

void* CreateContext(RenderContextInit* context_init)
{
	test_out.writeln("CreateContext called!");
	test_out.writeln(*context_init);
	test_out.flush();

	// alloc 1072 bytes?

	return cast(void*)new byte[1072];
}

void DeleteContext(RenderContext* context)
{
	test();
	context.destroy();
	context=null;
}

void Clear(Rect*, uint)
{
	//test();
	_renderer_inst.Clear();
}

bool Start3D()
{
	test();
	_is_in_3D=true;
	return true;
}

bool End3D()
{
	test();
	_is_in_3D=false;
	return true;
}

int IsIn3D()
{
	//test();
	return _is_in_3D;
}

int StartOptimized2D()
{
	test();
	return 0;
}

void EndOptimized2D()
{
	test();
	return;
}

int IsInOptimized2D()
{
	//test();
	return 0;
}

int RenderScene(SceneDesc*)
{
	test();
	return 0;
}

void RenderCommand(int argc, char** args)
{
	test();
}

uint GetHook(const char*)
{
	test();
	return 0;
}

void SwapBuffers()
{
	test();

	_renderer_inst.SwapBuffers();
}

int GetInfoFlags()
{
	test();
	return 0;
}

int GetBufferFormat() // bool function(out PFormat*)?
{
	//test();
	return 1;
}

SharedTexture* CreateSurface(int width, int height)
{
	test_out.writeln(width, ", ", height);
	test();

	//void* buffer=malloc(SharedTexture.sizeof);
	//memset(buffer, 0x69, SharedTexture.sizeof);

	SDL_Surface* temp_surf=SDL_CreateRGBSurfaceWithFormat(0, width, height, 32, SDL_PIXELFORMAT_RGB888);
	test_out.writeln(temp_surf);

	return cast(SharedTexture*)temp_surf; //buffer;
}

void DeleteSurface(SharedTexture* surface)
{
	SDL_Surface* trans_surf=cast(SDL_Surface*)surface;

	test();
	test_out.writeln(*trans_surf);
	//free(surface);
	//surface=null;
	SDL_FreeSurface(trans_surf);
}

void GetSurfaceInfo(SharedTexture* surface, out int width, out int height, out int pitch)
{
	if (!surface) return;

	SDL_Surface* trans_surf=cast(SDL_Surface*)surface;
	//test();

	/*width=surface.buf[1];
	height=surface.buf[2];
	pitch=surface.buf[3];*/
	width=trans_surf.w;
	height=trans_surf.h;
	pitch=trans_surf.pitch;
}

void* LockSurface(SharedTexture* texture)
{
	test_out.writeln(texture);
	test();

	SDL_Surface* surface=cast(SDL_Surface*)texture;

	if (surface is null)
		return null;

	test_out.writeln(*cast(ubyte[64]*)surface.pixels);

	return cast(void*)surface.pixels;
}

void UnlockSurface(SharedTexture* texture)
{
	test_out.writeln(texture);
	test();

	if (texture is null)
		return;

	SDL_Surface* surface=cast(SDL_Surface*)texture;
	test_out.writeln(*cast(byte[64]*)surface.pixels);
}

int OptimizeSurface(void*, uint)
{
	test();
	return 0;
}

void UnoptimizeSurface(void*)
{
	return;
}

int LockScreen()
{
	test();
	return 0;
}

void UnlockScreen()
{
	test();
	return;
}

void BlitToScreen(BlitRequest* blit_request)
{
	test_out.writeln(*blit_request);
	test_out.writeln(*cast(Rect*)blit_request.source_ptr);
	test_out.writeln(*cast(Rect*)blit_request.dest_ptr);

	SDL_Surface* surface=cast(SDL_Surface*)blit_request.surface_ptr;
	Rect* source_rect=cast(Rect*)blit_request.source_ptr;
	Rect* dest_rect=cast(Rect*)blit_request.dest_ptr;

	SDL_Rect src_rect=SDL_Rect(source_rect.x1, source_rect.y1, source_rect.x2-source_rect.x1, source_rect.y2-source_rect.y1);
	SDL_Rect dst_rect=SDL_Rect(dest_rect.x1, dest_rect.y1, dest_rect.x2-dest_rect.x1, dest_rect.y2-dest_rect.y1);

	SDL_BlitScaled(surface, &src_rect, _renderer_inst._surface_main, &dst_rect);

	test();
}

void MakeScreenShot(const char* screenshot_filename)
{
	writeln(screenshot_filename);
	test();
}

void ReadConsoleVariables()
{
	test_out.writeln("ReadConsoleVariables called!");
	test_out.flush();

	return;
}