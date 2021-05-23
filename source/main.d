module Main;

import core.sys.windows.windows;
import core.sys.windows.dll;

//import std.string;
import std.stdio;
import core.stdc.stdlib;
import core.stdc.stdio;
import core.stdc.string;

import RendererTypes;
import RendererMain;
import VulkanRender;
import WorldBSP;
import Texture;

import bindbc.sdl;
import erupted.vulkan_lib_loader;

extern(Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
	switch (ulReason)
	{
		case DLL_PROCESS_ATTACH:
			test_out.open("test.txt", "w");
			test_out.writeln("Process Attach:");

			auto ret=loadSDL();

			loadGlobalLevelFunctions(test_out.getFP());

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

void DumpRaw(void* head, size_t length)
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
__gshared RenderContext* g_RenderContext;

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

	init_struct.mode.is_hardware=1;

	test_out.writeln(*init_struct);
	test_out.flush();

	_window_main=init_struct.main_window;
	_renderer.screen_width=init_struct.mode.width;
	_renderer.screen_height=init_struct.mode.height;

	_renderer_inst=new VulkanRenderer;
	//_renderer_inst=new Renderer;
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

	/+foreach(i, texture; g_TextureManager.textures)
	{
		char[256] test;
		auto tex_data=_renderer.GetTexture(texture.texture_ref, test.ptr);

		int width, height, channels;
		ubyte[] pixels=TransitionTexturePixels(tex_data, width, height, channels, 8);

		// SANITY CHECK: dump texture as bitmap
		import Bitmap;
		Bitmap bitmap_out;
		bitmap_out.pixel_data=pixels;
		bitmap_out.file_header.file_size=bitmap_out.file_header.pixel_data_offset+bitmap_out.pixel_data.length;
		bitmap_out.info_header.image_width=width;
		bitmap_out.info_header.image_height=-height;

		import std.stdio, std.string;
		File bmp_out;
		bmp_out.open("tex_dump/texture_%d.bmp".format(i), "wb");
		bmp_out.rawWrite((&bitmap_out.file_header)[0..1]);
		bmp_out.rawWrite((&bitmap_out.info_header)[0..1]);
		bmp_out.rawWrite(bitmap_out.pixel_data[]);
		bmp_out.close();

		_renderer.FreeTexture(texture.texture_ref);
	}+/

	/+if (g_RenderContext)
	{
		WorldBSP* bsp=g_RenderContext.main_world.world_bsp;
		test_out.writeln(*bsp);
		foreach(model; g_RenderContext.main_world.world_models[0..g_RenderContext.main_world.world_model_count])
		{
			test_out.writeln(*model);
			test_out.writeln(*model.objs[0]);
			//test_out.writeln();
			foreach(surface; model.objs[0].surfaces[0..model.objs[0].surface_count])
			{
				test_out.writeln(surface);
			}
			//const char** textures; // array of indexes to texture_string
			//uint texture_count;
			foreach(texture; model.objs[0].textures[0..model.objs[0].texture_count])
			{
				import std.string;
				test_out.writeln(texture.fromStringz());
			}
		}
	}+/
	/+//if (*textures!=null)
	//	test_out.writeln((*textures)[0..30]);

	test_out.writeln(*_renderer);
	test_out.writeln("Renderer unknown array:");
	test_out.writeln(_renderer.unknown_8[0..30]);

	foreach(ref list; _renderer.unknown_8[0..30])
	{
		auto buf=list.prev;
		auto cur=&list;
		while(buf!=cur)
		{
			test_out.writeln(*(cast(DEPalette*)buf.data));
			buf=buf.prev;
		}

		test_out.writeln("---");
	}

	test_out.flush();+/
}

void BindTexture(SharedTexture* texture, int unknown)
	in(texture!=null)
{
	//test();

	if (texture.render_data!=null)
	{
		RenderTexture* render_texture=texture.render_data;
		TextureData* texture_data=_renderer.GetTexture(texture, null);

		if (texture_data!=null)
		{
			// upload?
			//test_out.writeln(*texture_data);
			//test_out.writeln(*render_texture);
		}

		_renderer.FreeTexture(texture);
	}
	else
	{
		// create a new RenderTexture
		TextureData* texture_data=_renderer.GetTexture(texture, null);

		RenderTexture r_texture=g_TextureManager.CreateTexture(texture, texture_data);
		texture.render_data=cast(RenderTexture*)r_texture;

		_renderer.FreeTexture(texture);
	}
}

void UnbindTexture(SharedTexture*)
{
	test();
	// delete SharedTexture.render_data here?
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
	in(context_init!=null)
{
	test();

	test_out.writeln(*context_init);

	g_RenderContext=cast(RenderContext*)calloc(1, RenderContext.sizeof);
	g_RenderContext.main_world=context_init.main_world;

	import WorldBSP;
	test_out.writeln(*g_RenderContext.main_world);

	WorldBSP* bsp=g_RenderContext.main_world.world_bsp;
	test_out.writeln(*bsp);

	UnknownList* current=bsp.world_model_root.prev;
	while(current!=bsp.world_model_root)
	{
		test_out.writeln(*current);
		test_out.writeln(*current.data);

		current=current.prev;
	}

	/+foreach(poly; bsp.polygons[0..bsp.polygon_count])
	{
		test_out.writeln(*poly);
		if (poly.lightmap_data!=null)
		{
			import Model: SurfaceFlags;
			if (poly.surface.flags & SurfaceFlags.LightMap)
			{
				ubyte[] dims=(cast(ubyte*)poly.lightmap_data)[0..2];
				uint length=dims[0]*dims[1];

				test_out.writeln(dims, ": ", (cast(ushort*)poly.lightmap_data)[0..length]);
			}
		}
	}+/

	void TraverseNode(Node* node) // move this somewhere else!
	{
		test_out.writeln(*node);

		// do objects
		if (node.objects)
		{
			auto current=node.objects.prev;
			while(current!=(node.objects))
			{
				test_out.writeln(*current);
				test_out.writeln(*current.data);

				auto attach_current=current.data.attachments;
				while(attach_current!=null)
				{
					struct AttachmentList
					{
						Buffer*[10] buf;

						static assert(this.sizeof==40);
					}
					test_out.writeln((cast(AttachmentList*)attach_current)[0..2]);
					test_out.writeln(_renderer.AttachmentSomething(current.data, attach_current));
					attach_current=attach_current.buf[9];
					test_out.writeln(attach_current);
					test_out.flush();
				}
				current=current.prev;
			}
		}

		if (node.next[0].flags & 8)
		{
			TraverseNode(node.next[0]);
		}

		if (node.next[1].flags & 8)
		{
			TraverseNode(node.next[1]);
		}
	}

	//TraverseNode(bsp.node_root);

	(cast(VulkanRenderer)_renderer_inst).CreateBSPVertexBuffer(g_RenderContext.main_world.world_bsp);

	return g_RenderContext; // softlocks at load screen if this returns null
}

void DeleteContext(RenderContext* context)
{
	test();
	//test_out.writeln(context);
	//test_out.writeln(*context);
	free(context);
}

void Clear(Rect* rect, ClearFlags flags)
{
	test_out.writeln(*rect, " ", flags);
	_renderer_inst.Clear();
}

int Start3D() // vkBeginCommandBuffer
{
	test();

	_is_in_3D=true;
	return true;
}

int End3D() // vkEndCommandBuffer
{
	test();

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
	in(scene_desc!=null)
{
	test();

	WorldBSP* bsp=g_RenderContext.main_world.world_bsp;
	test_out.writeln(*bsp);

	Node* root_node=bsp.node_root;

	// display all world model lists
	/+foreach(ref model; bsp.world_models[0..bsp.world_models_count])
	{
		test_out.writeln(model);
		auto cur=model.prev;
		while(cur!=&model)
		{
			//test_out.writeln(*cur);
			test_out.writeln(*cur.data);
			cur=cur.prev;
		}
	}+/

	void ProcessNode(Node* node)
	{
		test_out.writeln("//////////");
		test_out.writeln(*node);
		test_out.writeln("---");
		test_out.flush();

		UnknownList* obj_cur;
		if (node.objects==null) goto SKIP;

		import Codes;

		LTResult GetNextModelNode(UnknownObject* obj, uint node, out uint next)
		{
			if ((obj != null) && (obj.type_id == 1))
			{
				uint node_count=*cast(uint*)((cast(uint)obj.model_nodes) + 0x84);
				test_out.writeln(obj, " node_count: ", node_count);

				if (node_count <= node + 1u) // model_nodes + 0x84 = node_count
				{
					return LTResult.DE_FINISHED;
				}
				next = node + 1u;
				return LTResult.LT_OK;
			}

			return LTResult.DE_INVALIDPARAMS;
		}

		/// doesn't work for some reason
		LTResult GetModelNodeName(UnknownObject* obj, uint node, char* name, int max_length)
		{
		  if ((node == 0) || (max_length == 0) || (obj == null) || (obj.type_id != 1))
		  {
		    return LTResult.DE_ERROR;
		  }
		  else
		  {
		  	uint node_count=*cast(uint*)((cast(uint)obj.model_nodes) + 0x84);
		    if (node < node_count)
		    {
		    	char** node_name_list=*cast(char***)(cast(uint)obj.model_nodes + 0x80);
		    	test_out.writeln(node_name_list[0..node_count]);
		    	import std.string: fromStringz;
		    	test_out.writeln(node_name_list[node][0..32]);
		      strncpy(name, node_name_list[node], max_length - 1);
		      return LTResult.LT_OK;
		    }
		  }

		  return LTResult.DE_INVALIDPARAMS;
		}

		int GetModelAnimation(UnknownObject* obj)
		{
		  if ((obj != null) && (obj.type_id == 1))
		  {
		  	test_out.writeln(*cast(int*)(cast(int)obj + 348));
		  	test_out.writeln(*cast(int*)(cast(int)obj.model_nodes + 0xf4));
		  	test_out.writeln(*cast(int*)(cast(int)obj + 348) - *cast(int*)(cast(int)obj.model_nodes + 0xf4));
		  	test_out.writeln((*cast(int*)(cast(int)obj + 348) - *cast(int*)(cast(int)obj.model_nodes + 0xf4)) / 0x74);

		    return (*cast(int*)(cast(int)obj + 348) - *cast(int*)(cast(int)obj.model_nodes + 0xf4)) / 0x74;
		  }
		  return -1;
		}

		bool GetModelLooping(UnknownObject* obj)
		{
		  if ((obj != null) && (obj.type_id == 1)) {
		    return cast(bool)(*cast(int*)(cast(int)obj + 328) >> 1 & 1);
		  }
		  return 0;
		}

		obj_cur=node.objects.prev;
		while(obj_cur!=node.objects)
		{
			test_out.writeln(*obj_cur);

			auto object_inst=obj_cur.data;
			test_out.writeln(*object_inst);

			import std.string: fromStringz;
			import Model: ObjectType;

			uint next_node;
			test_out.writeln(GetNextModelNode(object_inst, 0, next_node));
			//char[64] test_name;
			//test_out.writeln(GetModelNodeName(object_inst, 1, test_name.ptr, 64));

			test_out.writeln("GetModelAnimation: ", GetModelAnimation(object_inst));
			test_out.writeln("GetModelLooping: ", GetModelLooping(object_inst));

			/+if (object_inst.type_id==ObjectType.Model && object_inst.class_!=null)
			{
				test_out.writeln(*object_inst.class_);
				//test_out.flush();

				import Object.BaseObject;
				test_out.writeln(*(cast(ObjectCreateStruct*)object_inst.list));
				test_out.writeln(*(cast(ObjectClass*)object_inst.class_));
				test_out.writeln(*(cast(ObjectClass*)object_inst.class_).create_struct);

				struct ObjectClass
				{
				align(2):
					Buffer*[5] buf1;
					ushort name_length;
					char[64] name; // in place char array

					static assert(name_length.offsetof==0x14);
					static assert(name.offsetof==0x16);
				}

				if (object_inst.class_.buf[3]!=null)
				{
					ObjectClass* obj_class=cast(ObjectClass*)object_inst.class_.buf[3];
					test_out.writeln(*obj_class);
					test_out.writeln((cast(char*)(&obj_class.name))[0..obj_class.name_length]);
					//test_out.flush();
				}

				if (object_inst.class_.buf[12]!=null)
				{
					ObjectClass* model_filename=cast(ObjectClass*)((cast(uint)object_inst.class_)+0x30);
					//test_out.writeln((cast(char*)(&model_filename.name))[0..model_filename.name_length]);
					test_out.writeln(*model_filename);
				}

				if (object_inst.class_.buf[13]!=null)
				{
					ObjectClass* model_filename=cast(ObjectClass*)((cast(uint)object_inst.class_)+0x34);
					test_out.writeln(*model_filename);
					//test_out.writeln((cast(char*)(&model_filename.name))[0..model_filename.name_length]);
				}
			}

			if (object_inst.type_id==ObjectType.Model && object_inst.model_nodes!=null)
			{
				test_out.writeln(object_inst.model_nodes[0..2]);

				char** node_name_list=cast(char**)object_inst.model_nodes[1].buf[0];
				test_out.writeln(object_inst.model_nodes[1].buf[1]);
				test_out.writeln(node_name_list[0..32]);
			}

			test_out.flush();+/

			obj_cur=obj_cur.prev;
		}

		SKIP:
		if (node.next[0].flags & 8)
			ProcessNode(node.next[0]);
		if (node.next[1].flags & 8)
			ProcessNode(node.next[1]);
	}

	//ProcessNode(root_node);

	if (_renderer.is_init!=0)
	{
		test_out.writeln(*scene_desc);

		{
			if (scene_desc.obj_count>0)
			{
				void*[] obj_list=scene_desc.obj_list_head[0..scene_desc.obj_count];

				test_out.writeln(obj_list);

				foreach(obj; obj_list)
				{
					import Polygrid;
					test_out.writeln(*(cast(Polygrid*)obj));
				}
			}
		}

		test_out.flush();

		_renderer_inst.RenderScene(scene_desc);
		return 1;
	}

	return 0;
}

void RenderCommand(int argc, char** args) // this is for RCom console command
{
	test();

	import std.conv;

	foreach(arg; args[0..argc])
		test_out.writeln(to!string(arg));
}

void* GetHook(const char*)
{
	test();
	return null;
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

LTPixelFormat GetBufferFormat()
{
	//test();
	return LTPixelFormat.RGB_565; // 0 for 565, 1 for 555?
}

import vk.Surface;

ImageSurface* CreateSurface(const int width, const int height)
{
	//ImageSurface* new_surface=new ImageSurface(width, height);
	//return new_surface;

	return cast(ImageSurface*)_renderer_inst.CreateSurface(width, height);
}

void DeleteSurface(ImageSurface* surface)
{
	/*surface.pixels.destroy();
	surface.pixels=null;
	surface.destroy();
	surface=null;*/
	_renderer_inst.DeleteSurface(surface);
}

void GetSurfaceInfo(ImageSurface* surface, int* width, int* height, int* pitch)
	in(surface!=null)
{
	/+*width=surface.width;
	*height=surface.height;
	*pitch=surface.stride;+/

	_renderer_inst.GetSurfaceInfo(surface, width, height, pitch);
}

void* LockSurface(ImageSurface* surface)
{
	return _renderer_inst.LockSurface(surface);
}

void UnlockSurface(ImageSurface* surface)
{
	_renderer_inst.UnlockSurface(surface);
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
	return _renderer_inst.LockScreen(left, top, right, bottom, pixels, pitch);

	/+if (!screen_surface.is_locked)
	{
		void* start_byte=screen_surface.pixels.ptr;
		start_byte+=(top*screen_surface.stride)+(left << 1);
		if (pixels!=null)
			*pixels=start_byte;
		if (pitch!=null)
			*pitch=screen_surface.stride;
		return 1;
	}

	return 0;+/
}

void UnlockScreen()
{
	_renderer_inst.UnlockScreen();
}

void BlitToScreen(BlitRequest* blit_request)
{
	_renderer_inst.BlitToScreen(blit_request);

	/+auto real_surface=blit_request.surface_ptr;

	SDL_Surface* conv_surf=SDL_CreateRGBSurfaceFrom(real_surface.pixels.ptr, real_surface.width, real_surface.height, 16, real_surface.stride, 0x1F, 0x7E0, 0xF800, 0x00);
	//SDL_Surface* conv_surf=SDL_ConvertSurface(surface, screen_surface.format, 0);
	Rect* source_rect=cast(Rect*)blit_request.source_ptr;
	Rect* dest_rect=cast(Rect*)blit_request.dest_ptr;
	SDL_Rect src_rect=SDL_Rect(source_rect.x1, source_rect.y1, source_rect.x2-source_rect.x1, source_rect.y2-source_rect.y1);
	SDL_Rect dst_rect=SDL_Rect(dest_rect.x1, dest_rect.y1, dest_rect.x2-dest_rect.x1, dest_rect.y2-dest_rect.y1);
	SDL_BlitScaled(conv_surf, &src_rect, screen_surface, &dst_rect);
	SDL_FreeSurface(conv_surf);+/
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