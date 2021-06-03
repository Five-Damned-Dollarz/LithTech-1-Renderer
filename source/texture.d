module Texture;

import RendererTypes: DLink, Buffer;

enum uint DTXVersion=-2;
enum DTXMipMapCount=4;

struct Colour
{
	ubyte a, r, g, b;

	static Colour From565(ushort colour_in)
	{
		return Colour(0xFF, (colour_in & 0xF800) >> 8, (colour_in & 0x07E0) >> 3, (colour_in & 0x001F) << 3);
	}
}

enum DTXFlags : uint
{
	FullBrite=0x1,
	AlphaMasks=0x2,
	Unknown1=0x4,
	Unknown2=0x8
}

struct DTXHeader
{
	int id;
	int version_;
	ushort width;
	ushort height;
	ushort mipmap_count;
	DTXFlags flags;
	uint flags_other; // defined by the game/object.lto
	short group;
	short mipmaps_used_count; // 0 = 4?
	short alpha_cutoff; // seems to be limited to [128-255]
	short alpha_average;
}

struct TextureData
{
	uint unknown_1; // maybe a type id?
	DTXHeader header;

	int unknown_2;
	DLink unknown_3;

	int unknown_4a; // size in memory?

	struct Palette
	{
		DLink link; // unknown
		void*[3] unknown;
		Colour[256] colours;
	}
	Palette* palette;

	void* unknown_4b;

	SharedTexture* texture_ref;

	int unknown_5;

	struct MipMapData
	{
		int width;
		int height;
		int stride;
		ubyte* pixels;
		ubyte* alpha;
	}
	MipMapData[DTXMipMapCount] mipmap_data;
}

struct SharedTexture
{
	Buffer* ref1; // unknown
	TextureData* engine_data;
	RenderTexture* render_data; // render_data; if null load new texture from engine_data?
	DLink link;

	// possibly functions here?

	// [32] = returns null if null
	// [40] = width
	// [44] = height
	// [48] = bbp
	// [56] is used somehow
	Buffer*[5] buf1;
	short width, height, bpp; // unsure
	Buffer*[34] buf2;

	//static assert(this.sizeof>=40); // 36 bytes cleared, 64/68?
}

/+
 + converts 8-bit indexed ARGB4888 to RGBA8888
 +/
ubyte[] TransitionTexturePixels(TextureData* texture, out int width, out int height, out int channels /+ bytes per pixel? +/, ubyte rotate=0)
{
	width=texture.header.width;
	height=texture.header.height;
	channels=4;

	size_t image_size=width*height*channels;
	// get pixels
	ubyte[] pixels=new ubyte[image_size];
	uint[] pixel_view=(cast(uint*)pixels.ptr)[0..(image_size/4)];
	foreach(i, pixel; texture.mipmap_data[0].pixels[0..(image_size/4)])
	{
		Colour pixel_colour=texture.palette.colours[pixel];
		ubyte pixel_alpha=0xFF;
		if (texture.header.flags & DTXFlags.AlphaMasks)
		{
			pixel_alpha=texture.mipmap_data[0].alpha[i/2];
			if (i & 1)
				pixel_alpha>>=2;
			pixel_alpha&=0xF;
			pixel_alpha|=pixel_alpha << 4;
		}

		uint final_mix=pixel_colour.b << 24 | pixel_colour.g << 16 | pixel_colour.r << 8 | pixel_alpha;

		if (rotate)
		{
			asm
			{
				mov CL, rotate;
				ror final_mix, CL;
			}
		}

		pixel_view[i]=final_mix;
	}
	return pixels;
}

import erupted;

class RenderTexture
{
	VkImage image;
	VkMappedMemoryRange memory;
	VkImageView image_view;

	VkDescriptorSet texture_descriptor;

	SharedTexture* texture_ref;

	public void DumpAsBMP(TextureData* data, ubyte[] pixels_)
	{
		int width, height, channels;
		ubyte[] pixels=TransitionTexturePixels(data, width, height, channels, 8);
		// SANITY CHECK: dump texture as bitmap
		import Bitmap;
		Bitmap bitmap_out;
		bitmap_out.pixel_data=pixels;
		bitmap_out.file_header.file_size=bitmap_out.file_header.pixel_data_offset+bitmap_out.pixel_data.length;
		bitmap_out.info_header.image_width=data.header.width;
		bitmap_out.info_header.image_height=-cast(int)(data.header.height);

		import std.stdio, std.string;
		File bmp_out;
		bmp_out.open("tex_dump/texture_%x.bmp".format(data), "wb");
		bmp_out.rawWrite((&bitmap_out.file_header)[0..1]);
		bmp_out.rawWrite((&bitmap_out.info_header)[0..1]);
		bmp_out.rawWrite(bitmap_out.pixel_data[]);
		bmp_out.close();
	}

	public size_t Create(SharedTexture* texture, TextureData* data)
		in(data!=null)
	{
		texture_ref=texture;
		texture.render_data=(cast(RenderTexture*)this);

		import Main: _renderer_inst;
		import VulkanRender;
		(cast(VulkanRenderer)_renderer_inst).CreateTextureImage(texture, image, memory);

		VkComponentMapping map=VkComponentMapping(VK_COMPONENT_SWIZZLE_IDENTITY, VK_COMPONENT_SWIZZLE_IDENTITY, VK_COMPONENT_SWIZZLE_IDENTITY, VK_COMPONENT_SWIZZLE_IDENTITY);
		image_view=(cast(VulkanRenderer)_renderer_inst).CreateImageView(image, VK_FORMAT_R8G8B8A8_SRGB, VK_IMAGE_ASPECT_COLOR_BIT, &map);

		(cast(VulkanRenderer)_renderer_inst).CreateTextureDescriptorSet(image_view, texture_descriptor);

		return 0;

		assert(0);
	}
}

class TextureManager
{
	public RenderTexture[] textures;

	RenderTexture CreateTexture(SharedTexture* texture, TextureData* data)
	{
		import Main: test_out;

		RenderTexture r_texture=new RenderTexture();
		r_texture.Create(texture, data);

		textures~=r_texture;

		return r_texture;
	}
}

__gshared TextureManager g_TextureManager=new TextureManager();