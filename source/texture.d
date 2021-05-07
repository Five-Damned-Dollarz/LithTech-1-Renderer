module Texture;

import RendererTypes: DLink, Buffer;

enum uint DTXVersion=-2;
enum DTXMipMapCount=4;

struct Colour
{
	ubyte a, r, g, b;
}

enum DTXFlags : uint
{
	FullBrite=1,
	AlphaMasks=2,
	Unknown1=4,
	Unknown2=8
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
	RenderTexture* ref2; // render_data; if null load new texture?
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

	//static assert(this.sizeof>=40); // 64/68?
}

ubyte[] TransitionTexturePixels(TextureData* texture, out int width, out int height, out int channels)
{
	width=texture.header.width;
	height=texture.header.height;
	channels=4; // in this project we know DTX is always indexed A8R8G8B8

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
		pixel_view[i]=pixel_colour.r << 24 | pixel_colour.g << 16 | pixel_colour.b << 8 | pixel_alpha;
	}
	return pixels;
}

import erupted;

class RenderTexture
{
	public VkImage image;
	public VkDeviceMemory memory;
	VkImageView[VkFormat] image_view;

	SharedTexture* texture_ref;
}

class TextureManager
{
	public RenderTexture[] textures;
}

__gshared TextureManager g_TextureManager=new TextureManager();