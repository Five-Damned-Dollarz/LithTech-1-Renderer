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
import WorldBsp: WorldBsp, MainWorld, Node;
import Texture;
import Objects.BaseObject;

extern(Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
	switch (ulReason)
	{
		case DLL_PROCESS_ATTACH:
			test_out.open("test.txt", "w");
			test_out.writeln("Process Attach:");

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

__gshared bool g_IsIn3D=false;

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
	renderer.DeoptimizeSurface=&DeoptimizeSurface;
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

	void* windowed_cvar=_renderer.GetConsoleVar("windowed");
	const char* windowed_str=_renderer.GetVarValueString(windowed_cvar);
	test_out.writeln(windowed_cvar, windowed_str);

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

	struct SoftSky
	{
		Buffer*[6] buf;

		static assert(this.sizeof==24);
	}

	debug test_out.writeln(*cast(SoftSky*)textures);
}

void BindTexture(SharedTexture* texture, int unknown)
	in(texture!=null)
{
	//test();

	if (texture.render_data !is null)
	{
		RenderTexture render_texture=texture.render_data;
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
		texture.render_data=r_texture;

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

	test_out.writeln(*g_RenderContext.main_world);

	WorldBsp* bsp=g_RenderContext.main_world.world_bsp;
	test_out.writeln(*bsp);
	test_out.writeln(*bsp.owner_obj);

	ObjectList* current=bsp.world_model_root.prev;
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
					test_out.writeln(_renderer.GetAttachmentObject(current.data, attach_current));
					attach_current=attach_current.next;
					test_out.writeln(attach_current);
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

	//TraverseNode(bsp.root_node);

	(cast(VulkanRenderer)_renderer_inst).CreateBspVertexBuffer(g_RenderContext.main_world.world_bsp);

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

	g_IsIn3D=true;
	return true;
}

int End3D() // vkEndCommandBuffer
{
	test();

	g_IsIn3D=false;
	return true;
}

int IsIn3D()
{
	return g_IsIn3D;
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

extern(D)
void PrintDList(ref DLink head, void delegate(DLink*) callback=(DLink* link) { test_out.writeln(link, ": ", *link); })
{
	DLink* next_link=head.prev;
	while(next_link!=&head)
	{
		callback(next_link);
		next_link=next_link.prev;
	}
}

int RenderScene(SceneDesc* scene_desc)
	in(scene_desc!=null)
{
	test();

	test_out.writeln(*_renderer);
	test_out.writeln(*_renderer.palette_list);

	/+foreach(ref DLink link; _renderer.palette_list.palettes)
	{
		PrintDList(link, (DLink* link) { test_out.writeln(link, ": ", *cast(DEPalette*)link.data); });
	}+/

	foreach(pan; _renderer.global_pans)
	{
		if (pan.texture_ref)
			test_out.writeln(*pan.texture_ref);
	}
	test_out.flush();

	WorldBsp* bsp=g_RenderContext.main_world.world_bsp;
	test_out.writeln(*bsp);

	Node* root_node=bsp.root_node;

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

	struct TempColour16
	{
		ushort colour;

		@property ubyte red() const
		{
			return (colour & 0xFC0000) >> 10;
		}

		@property ubyte green() const
		{
			return (colour & 0x7E) >> 5;
		}

		@property ubyte blue() const
		{
			return (colour & 0x1F);
		}

		string toString()
		{
			import std.format;
			return format("(%d, %d, %d)", red, green, blue);
		}
	}

	foreach(poly; bsp.polygons[0..bsp.polygon_count])
	{
		test_out.writeln(*poly);
		if (poly.lightmap_data!=null)
		{
			test_out.writeln(poly.DiskVerts()[]);

			import WorldBsp: SurfaceFlags;
			if (poly.surface.flags & SurfaceFlags.LightMap)
			{
				ubyte[] dims=(cast(ubyte*)poly.lightmap_data)[0..2];
				uint length=dims[0]*dims[1];

				test_out.writeln(dims, ": ", (cast(TempColour16*)poly.lightmap_data)[0..length]);
			}
		}

		if (poly.next!=null)
		{
			test_out.writeln("Poly.next: ", *(cast(Buffer*)poly.next));
		}

		if (poly.lightmap_page!=null)
		{
			test_out.writeln("Poly.lightmap_page: ", *(cast(Buffer*)poly.lightmap_page));
		}
	}

	void ProcessNode(Node* node)
	{
		test_out.writeln("//////////");
		test_out.writeln(*node);
		test_out.writeln("---");

		ObjectList* obj_cur;

		if (node.objects==null) goto SKIP;

		import Codes;
		obj_cur=node.objects.prev;

		while(obj_cur!=node.objects)
		{
			auto object_inst=obj_cur.data;
			test_out.writeln(*object_inst);

			if (auto class_=object_inst.class_)
			{
				test_out.writeln("-- class begin\n", *class_);
				if (class_.object_instance)
				{
					import std.string: fromStringz;

					test_out.writeln(object_inst);
					test_out.writeln(*class_.object_instance);

					PrintDList(class_.link,
						(DLink* link)
						{
							test_out.writeln(link, ": ", *link);
							test_out.writeln("data: ", link.data, " ", *cast(InterObjectLink*)link.data);
							test_out.flush();

							auto link_dat=cast(InterObjectLink*)link.data;
							test_out.writeln(*cast(Buffer*)link_dat.link_ref, " ", *cast(Buffer*)link_dat.link_ref2);
						}
					);

					if (class_.unknown_flags) test_out.writeln(*cast(BaseObject*)class_.unknown_flags);

					auto temp_aggr=class_.object_instance.m_pFirstAggregate;
					while(temp_aggr)
					{
						test_out.writeln("aggr: ", temp_aggr, " ", *temp_aggr);
						temp_aggr=temp_aggr.m_pNextAggregate;
					}

					test_out.writeln(*class_.class_definition);
					test_out.writeln(class_.class_definition.m_ClassName.fromStringz);

					foreach(prop; class_.class_definition.Properties)
					{
						test_out.writeln(prop.m_PropName.fromStringz);
						test_out.writeln(prop);
						if (prop.m_PropType==PropertyType.String && prop.m_DefaultValueString)
							test_out.writeln(prop.m_DefaultValueString.fromStringz);
					}

					test_out.writeln("--- class end");
				}
			}

			import std.string: fromStringz;
			import Objects.Model;
			if (object_inst.type_id==ObjectType.Model)
			{
				Objects.Model.ModelObject* obj_=object_inst.ToModel();

				test_out.writeln(*obj_);

				test_out.TraverseModel(obj_.model_data.unknown_5);

				PrintDList(obj_.link, (DLink* link) { if (link.data) test_out.writeln(link, ": ", *cast(Buffer*)link.data); test_out.flush(); });
				PrintDList(obj_.link_unknown, (DLink* link) { if (cast(int)link.data>0xFFFF) test_out.writeln(link, ": ", *cast(BaseObject*)link.data); });

				test_out.writeln("Cur anims: ", obj_.keyframes[0].animation.name.fromStringz, " ", obj_.keyframes[1].animation.name.fromStringz);

				test_out.writeln("Texture: ", cast(void*)obj_.texture);
				if (obj_.texture)
				{
					test_out.writeln("Texture: ", *obj_.texture);

					if (obj_.texture.file_stream)
					{
						import LTCore;
						LTFileStream* stream=obj_.texture.file_stream;
						test_out.writeln("fstream?: ", *stream);
						test_out.writeln("1: ", (cast(Buffer*)stream.unknown_1)[0..4]);
						test_out.writeln("5: ", stream.file_name.fromStringz);

						PrintDList(stream.link, (DLink* link) { if (link.data) test_out.writeln(link, ": ", *cast(LTFileStream*)link.data, "\n", (cast(LTFileStream*)link.data).file_name.fromStringz); });
					}
				}

				//if (obj_.unknown_nodes)
				//	test_out.writeln(*cast(Buffer*)obj_.unknown_nodes);

				if (auto attach=object_inst.attachments)
				{
					while(attach!=null)
					{
						auto attach_obj=_renderer.GetAttachmentObject(object_inst, attach);

						if (attach_obj)
						{
							if (attach_obj.class_)
							{
								ObjectString* model_filename=*attach_obj.class_.model_filename;
								if (model_filename!=null)
									test_out.writeln(model_filename.ToString);
							}
						}

						attach=attach.next;
					}
				}

				/*if (Buffer* buf=cast(Buffer*)obj_.buf[3])
				{
					test_out.writeln(*buf);
				}

				if (Buffer* buf=cast(Buffer*)obj_.unknown)
				{
					test_out.writeln(*buf);
				}*/

				test_out.writeln(*obj_.keyframes[0].frame_data);
				test_out.writeln(*obj_.keyframes[1].frame_data);

				if (auto model=obj_.model_data)
				{
					test_out.writeln(*model);

					test_out.writeln(model.unknown_5[0..model.unknown_5_count]);

					foreach(i, node_; model.nodes[0..model.node_count])
					{
						test_out.writeln(i, " [", node_, "]: ", node_.name.fromStringz, " ", *node_);

						if (node_.deform_vertices && node_.deform_vertex_count)
							test_out.writeln("dverts: ", node_.deform_vertices[0..node_.deform_vertex_count]);
					}

					test_out.writeln(model.animations[0]);
					test_out.writeln(model.animations[0].Keyframes());

					//test_out.writeln(model.vertices[0..model.unknown_9_count]);

					test_out.writeln(model.node_matrices[0..model.node_matrix_count]);

					//test_out.writeln(*cast(Buffer*)model.unknown_3);

					test_out.writeln(model.uvs[0..6]);
					test_out.writeln((cast(float*)model.unknown_10)[0..10000]);
				}
			}
			else if (object_inst.type_id==ObjectType.WorldModel || object_inst.type_id==ObjectType.Container)
			{
				import Objects.WorldModel;
				BaseObject* temp_obj=ToWorldModel(object_inst).bsp_data.objs[0].owner_obj;
				test_out.writeln("WorldModel/Container obj: ", temp_obj);
				if (temp_obj)
					test_out.writeln(*temp_obj);
			}
			else if (object_inst.type_id==ObjectType.ParticleSystem)
			{
				import Objects.ParticleSystem;
				ParticleSystemObject* part_sys=object_inst.ToParticleSystem();
				test_out.writeln(*part_sys);
				/+test_out.writeln(&part_sys.null_particle, " ", part_sys.null_particle);
				test_out.writeln(part_sys.null_particle.m_pNext, " ", part_sys.null_particle.m_pNext[0..4]);
				test_out.writeln(part_sys.null_particle.prev, " ", part_sys.null_particle.prev[0..4]);+/
				/+test_out.writeln(*part_sys.particles_alloc);
				test_out.writeln((cast(Buffer*)part_sys.particles_alloc.buf1)[0..1]);
				test_out.writeln((cast(Buffer*)part_sys.particles_alloc.buf2)[0..1]);+/
				test_out.writeln(part_sys.unknown_ref[0..1]);
				test_out.writeln((cast(SharedTexture*)part_sys.unknown_ref)[0..1]);
				test_out.writeln(*cast(Buffer*)(cast(SharedTexture*)part_sys.unknown_ref).render_data);
			}
			else if (object_inst.type_id==ObjectType.Sprite)
			{
				import Objects.Sprite;
				SpriteObject* obj_=object_inst.ToSprite();
				test_out.writeln(*obj_);

				if (obj_.texture_ref)
				{
					test_out.writeln(**obj_.texture_ref);
					test_out.writeln(cast(void*)((**obj_.texture_ref).render_data));
					//TextureData* texture_data=_renderer.GetTexture(*obj_.texture_ref, null);
					//if (texture_data) test_out.writeln(*texture_data);
					//_renderer.FreeTexture(*obj_.texture_ref);
				}
			}
			else if (object_inst.type_id==ObjectType.LineSystem)
			{
				import Objects.LineSystem;
				LineSystemObject* obj_=object_inst.ToLineSystem();
				test_out.writeln(*obj_);
			}
			else if (object_inst.type_id==ObjectType.Camera)
			{
				import Objects.Camera;
				CameraObject* obj_=object_inst.ToCamera();
				test_out.writeln(*obj_);
			}

			if (object_inst.type_id==ObjectType.Model && object_inst.class_!=null)
			{
				import Objects.BaseObject : ObjectCreateStruct;
				test_out.writeln(*object_inst.class_);
				//test_out.writeln(*cast(ObjectCreateStruct*)(cast(ObjectClass_*)object_inst.class_).create_struct);

				if (object_inst.class_.object_name!=null)
				{
					ObjectString* obj_class=*object_inst.class_.object_name;
					test_out.writeln("obj name: ", (cast(char*)(&obj_class.name))[0..obj_class.name_length]);
				}

				if (object_inst.class_.model_filename!=null)
				{
					ObjectString* model_filename=*object_inst.class_.model_filename;
					if (model_filename!=null)
						test_out.writeln(model_filename.ToString);
				}

				if (object_inst.class_.texture_filename!=null)
				{
					ObjectString* skin_filename=*object_inst.class_.texture_filename;
					if (skin_filename!=null)
						test_out.writeln(skin_filename.ToString);
				}
			}

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

		/+{
			if (scene_desc.obj_count>0)
			{
				void*[] obj_list=scene_desc.obj_list_head[0..scene_desc.obj_count];

				test_out.writeln(obj_list);

				foreach(obj; obj_list)
				{
					if (obj.type_id!=ObjectType.Polygrid) continue;

					import Polygrid;
					test_out.writeln(*(cast(Polygrid*)obj));
				}
			}
		}+/

		//test_out.flush();

		_renderer_inst.RenderScene(scene_desc);
		return 1;
	}

	return 0;
}

void RenderCommand(int argc, const char** args) // this is for RCom console command
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

void DeoptimizeSurface(void*)
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
	test_out.writeln(*blit_request);
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