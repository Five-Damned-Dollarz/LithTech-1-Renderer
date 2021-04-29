import core.sys.windows.windows;
import core.sys.windows.dll;

//import std.string;
import std.stdio;
import core.stdc.stdlib;
import core.stdc.stdio;
import core.stdc.string;

import RendererTypes;
import RendererMain;
import WorldBSP;

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

			SDL_Init(SDL_INIT_VIDEO);

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

void DumpRaw(void* head, uint length)
{
	test_out.writeln(cast(void*[])head[0..length]);
	test_out.writeln(cast(float[])head[0..length]);
	test_out.writeln(cast(int[])head[0..length]);
	test_out.writeln(cast(short[])head[0..length]);
	test_out.writeln(cast(ubyte[])head[0..length]);
	test_out.writeln(cast(char[])head[0..length]);
}

extern(C):

__gshared HINSTANCE g_hInst;

__gshared RenderDLL* _renderer;
__gshared HWND _window_main;
__gshared Renderer _renderer_inst;

__gshared File test_out;
//__gshared ConVar[110] _convars;

__gshared bool _is_in_3D=false;

export Mode* GetSupportedModes()
{
	test();

	import std.string;
	import core.stdc.string;

	//SDL_Init(SDL_INIT_VIDEO);

	int mode_count=1; //SDL_GetNumDisplayModes(0);
	Mode[] modes=(cast(Mode*)calloc(mode_count, Mode.sizeof))[0..mode_count]; //new Mode[mode_count];

	immutable string renderer_filename="d_ren.ren";
	immutable string driver_name="primary"; //SDL_GetCurrentVideoDriver();
	immutable string display_name="Primary Video Thing"; //SDL_GetDisplayName(0);

	foreach(int i, ref mode; modes)
	{
		//SDL_DisplayMode sdl_mode;
		//SDL_GetDisplayMode(0, i, &sdl_mode);

		mode.is_hardware=1;
		strcpy(mode.filename.ptr, renderer_filename.toStringz);
		strcpy(mode.driver_name.ptr, driver_name.toStringz);
		strcpy(mode.display_name.ptr, display_name.toStringz);
		mode.width=640; //sdl_mode.w;
		mode.height=480; //sdl_mode.h;
		mode.depth=16; //(sdl_mode.format >> 8) & 0xFF;

		//if (i<mode_count-1)
		//	mode.next=&modes[i+1];
		mode.next=null;
	}

	return modes.ptr;
}

export void FreeModeList(Mode* modes_head)
{
	test();

	free(modes_head);
	modes_head=null;
}

export void RenderDLLSetup(RenderDLL* renderer)
{
	test();

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

	test_out.writeln(*_renderer);
	test_out.flush();
}

int Init(RenderStructInit* init_struct)
{
	test();

	//init_struct.mode.is_hardware=1;

	//SDL_Init(SDL_INIT_VIDEO);

	test_out.writeln(*init_struct);
	test_out.flush();

	_window_main=init_struct.main_window;
	_renderer.screen_width=init_struct.mode.width;
	_renderer.screen_height=init_struct.mode.height;

	_renderer_inst=new Renderer;
	_renderer_inst.InitFrom(_window_main);

	//_renderer.screen_depth=init_struct.mode.depth;
	//_renderer.window_flags=0x2; // 0x80000002 = fullscreen

	//CreateConVars();

	return 0;
}

/*void CreateConVars()
{
	import std.string;

	foreach(ref ConVar cvar; g_ConVars)
	{
		void* cvar_handle=_renderer.GetConsoleVar(cvar.name.toStringz);

		if (cvar_handle is null)
		{
			import std.string;
			string buffer=format!`%s %f`(cvar.name.toStringz, cvar.default_value);
			_renderer.RunConsoleString(buffer.toStringz);
			cvar_handle=_renderer.GetConsoleVar(cvar.name.toStringz);
		}

		cvar.engine_cvar=cvar_handle;

		test_out.writeln(cvar);
	}
}*/

void Term()
{
	test();

	_renderer_inst.Destroy();
	_renderer_inst.destroy();
	_renderer_inst=null;
}

void SetSoftSky(SharedTexture** textures)
{
	test();

	test_out.writeln(*textures);
	if (*textures !is null) // obviously this isn't a surface we've created
		test_out.writeln(*cast(SDL_Surface*)*textures);
	test_out.flush();

	test_out.writeln(*_renderer);
	test_out.writeln("Renderer unknown array:");
	test_out.writeln(_renderer.unknown_8[0..30]);
	test_out.flush();
}

void BindTexture(SharedTexture* texture, int unknown) // SharedTexture here is NOT the same as a surface
{
	//test();

	//test_out.writeln(texture);
	//test_out.writeln(cast(int)unknown);
	//test_out.flush();
}

void UnbindTexture(SharedTexture*)
{
	//test();
}

int QueryDeletePalette(DEPalette*)
{
	test();
	return 1;
}

int SetMasterPalette(SharedTexture* unknown)
{
	test();
	test_out.writeln(cast(int[32]*)unknown);
	return 0;
}

void* CreateContext(RenderContextInit* context_init)
{
	test();

	test_out.writeln(*context_init);

	RenderContext* temp=cast(RenderContext*)calloc(1, RenderContext.sizeof);
	temp.main_world=cast(MainWorld*)context_init.main_world;

	import WorldBSP;
	test_out.writeln(*temp.main_world);
	//test_out.writeln(*cast(Buffer*)temp.main_world.unknown_1);
	//test_out.writeln(*cast(Buffer*)(cast(Buffer*)temp.main_world.unknown_1).buf[1]); // drops you in the middle of main_bsp's surfaces?

	test_out.writeln(*temp.main_world.world_bsp);
	/*foreach(poly; temp.main_world.world_bsp.polygons[0..temp.main_world.world_bsp.polygon_count])
	{
		test_out.writeln(*poly);
	}*/
	//test_out.writeln(temp.main_world.world_bsp.unknown_1[0..16]);
	//test_out.writeln(*cast(Buffer*)temp.main_world.world_bsp.unknown_1[0].buf[0]);

	/*test_out.writeln(temp.main_world.world_bsp.nodes);
	test_out.writeln(*temp.main_world.world_bsp.nodes);
	test_out.writeln(temp.main_world.world_bsp.nodes.next);
	test_out.writeln(*temp.main_world.world_bsp.nodes.next);
	test_out.writeln(temp.main_world.world_bsp.nodes.next.next);
	test_out.writeln(*temp.main_world.world_bsp.nodes.next.next);*/

	/*WorldBSP* bsp=temp.main_world.world_bsp;
	foreach(node; bsp.nodes[0..bsp.node_count])
	{
		test_out.writeln("--- New Node! ---");
		Node* cur_node=&node;
		while(cur_node.next !is null)
		{
			test_out.writeln(*cur_node);
			cur_node=cur_node.next;
		}
	}*/

	//DumpRaw(temp.main_world.world_bsp.unknown_1, 128);
	//DumpRaw(temp.main_world.world_bsp.unknown_11[0], 128);
	//DumpRaw(temp.main_world.world_bsp.unknown_11[1], 128);

	test_out.flush();

	return temp; // softlocks at load screen if this returns null
}

void DeleteContext(RenderContext* context)
{
	test();
	//test_out.writeln(context);
	//test_out.writeln(*context);
	free(context);
}

void Clear(Rect*, uint)
{
	_renderer_inst.Clear();
}

int Start3D()
{
	_is_in_3D=true;
	return true;
}

int End3D()
{
	_is_in_3D=false;
	return true;
}

int IsIn3D()
{
	return _is_in_3D;
}

int StartOptimized2D()
{
	return 0;
}

void EndOptimized2D()
{
	return;
}

int IsInOptimized2D()
{
	return 0;
}

int RenderScene(SceneDesc* scene_desc)
{
	test();

	if (_renderer.is_init!=0)
	{
		test_out.writeln(*scene_desc);
		test_out.flush();
		return 1;
	}

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
	_renderer_inst.SwapBuffers();
}

int GetInfoFlags()
{
	test();
	return 0;
}

int GetBufferFormat()
{
	//test();
	return 0; // 0 for 565, 1 for 555?
}

SharedTexture* CreateSurface(int width, int height)
{
	SDL_Surface* temp_surf=SDL_CreateRGBSurfaceWithFormat(0, width, height, 16, SDL_PIXELFORMAT_RGB565);
	return cast(SharedTexture*)temp_surf;
}

void DeleteSurface(SharedTexture* surface)
{
	SDL_FreeSurface(cast(SDL_Surface*)surface);
}

void GetSurfaceInfo(SharedTexture* surface, int* width, int* height, int* pitch)
{
	if (surface is null) return;

	SDL_Surface* trans_surf=cast(SDL_Surface*)surface;

	*width=trans_surf.w;
	*height=trans_surf.h;
	*pitch=trans_surf.pitch;
}

void* LockSurface(SharedTexture* texture)
{
	SDL_Surface* surface=cast(SDL_Surface*)texture;

	if (surface is null)
		return null;

	if (SDL_LockSurface(surface))
		return null;

	return cast(void*)surface.pixels;
}

void UnlockSurface(SharedTexture* texture)
{
	if (texture is null)
		return;

	SDL_Surface* surface=cast(SDL_Surface*)texture;
	SDL_UnlockSurface(surface);
}

int OptimizeSurface(void*, uint)
{
	test();
	return 0;
}

void UnoptimizeSurface(void*)
{
	test();
}

int LockScreen(int left, int top, int right, int bottom, void** pixels, int* pitch)
{
	if (SDL_LockSurface(_renderer_inst._surface_main)==0)
	{
		void* start_byte=_renderer_inst._surface_main.pixels;
		start_byte+=(top*_renderer_inst._surface_main.pitch)+(left << 1);
		if (pixels !is null)
			*pixels=start_byte;
		if (pitch !is null)
			*pitch=_renderer_inst._surface_main.pitch;

		return 1;
	}

	return 0;
}

void UnlockScreen()
{
	SDL_UnlockSurface(_renderer_inst._surface_main);
}

void BlitToScreen(BlitRequest* blit_request)
{
	SDL_Surface* surface=cast(SDL_Surface*)blit_request.surface_ptr;
	SDL_Surface* conv_surf=SDL_ConvertSurface(surface, _renderer_inst._surface_main.format, 0);

	Rect* source_rect=cast(Rect*)blit_request.source_ptr;
	Rect* dest_rect=cast(Rect*)blit_request.dest_ptr;

	SDL_Rect src_rect=SDL_Rect(source_rect.x1, source_rect.y1, source_rect.x2-source_rect.x1, source_rect.y2-source_rect.y1);
	SDL_Rect dst_rect=SDL_Rect(dest_rect.x1, dest_rect.y1, dest_rect.x2-dest_rect.x1, dest_rect.y2-dest_rect.y1);

	SDL_BlitScaled(conv_surf, &src_rect, _renderer_inst._surface_main, &dst_rect);

	SDL_FreeSurface(conv_surf);
}

void MakeScreenShot(const char* screenshot_filename)
{
	test();
	writeln(screenshot_filename);
}

void ReadConsoleVariables()
{
	test();

	/+foreach(ref ConVar cvar; g_ConVars)
	{
		if (cvar.int_cache is null)
		{
			if (cvar.float_cache!=0f)
			{
				cvar.float_cache=_renderer.GetVarValueFloat(cvar.engine_cvar);
			}
		}
		else
		{
			*cvar.int_cache=cast(int)_renderer.GetVarValueFloat(cvar.engine_cvar);
			test_out.writeln(*cvar.int_cache);
		}

		test_out.writeln(cvar);
	}+/
}