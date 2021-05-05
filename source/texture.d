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
	ushort mipmap_count; // or palette bbp?
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

struct RenderTexture
{
	Buffer buf;
}