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

	//static assert(this.sizeof>=40); // 64/68?
}

/+
 + converts 8-bit indexed ARGB4888 to RGBA8888
 +/
ubyte[] TransitionTexturePixels(TextureData* texture, out int width, out int height, out int channels /+ bytes per pixel? +/)
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
		pixel_view[i]=pixel_colour.r << 24 | pixel_colour.g << 16 | pixel_colour.b << 8 | pixel_alpha;
	}
	return pixels;
}

import erupted;

class RenderTexture
{
	VkImage image;
	VkDeviceMemory memory;
	VkImageView image_view;

	SharedTexture* texture_ref;

	private void DumpAsBMP(TextureData* data, ubyte[] pixels)
	{
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
		in(data !is null)
	{
		texture_ref=texture;
		texture.render_data=cast(RenderTexture*)(this);

		int width, height, channels;

		// get pixels
		width=data.header.width;
		height=data.header.height;
		ubyte[] pixels=TransitionTexturePixels(data, width, height, channels);

		return pixels.length;

		/*assert(width>0);
		assert(height>0);
		assert(channels>0);
		assert(pixels.length==width*height*channels);*/

		/+size_t image_size=width*height*channels;

		VkBuffer staging_buffer;
		VkDeviceMemory staging_memory;

		CreateVkBuffer(image_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT, staging_buffer, staging_memory);

		void* data;
		vkMapMemory(_device, staging_memory, 0, image_size, 0, &data);
		import core.stdc.string: memcpy;
		memcpy(data, pixels.ptr, cast(size_t)image_size);
		vkUnmapMemory(_device, staging_memory);

		// free pixels
		pixels=null;

		CreateVkImage(width, height, VK_FORMAT_R8G8B8A8_SRGB, VK_IMAGE_TILING_OPTIMAL, VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_SAMPLED_BIT, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, image, memory);
		TransitionImageLayout(_texture_image, VK_FORMAT_R8G8B8A8_SRGB, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
		CopyBufferToImage(staging_buffer, _texture_image, width, height);
		TransitionImageLayout(_texture_image, VK_FORMAT_R8G8B8A8_SRGB, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

		vkDestroyBuffer(_device, staging_buffer, null);
		vkFreeMemory(_device, staging_memory, null);

		image_view=CreateImageView(image, VK_FORMAT_R8G8B8A8_SRGB, VK_IMAGE_ASPECT_COLOR_BIT);+/

		assert(0);
	}
}

import Main: test_out;

class TextureManager
{
	public RenderTexture[] textures;

	RenderTexture CreateTexture(SharedTexture* texture, TextureData* data)
	{
		RenderTexture r_texture=new RenderTexture();
		//test_out.writeln();
		r_texture.Create(texture, data);
		texture.render_data=&r_texture;

		g_TextureManager.textures~=r_texture;

		return r_texture;

		//(cast(VulkanRenderer)_renderer_inst).CreateTextureImage(texture, r_texture.image, r_texture.memory);

		//test_out.writeln(r_texture.image, " ", r_texture.memory);

		/*renderer.CreateTextureImage(texture);
		renderer.CreateTextureImageView();
		renderer.CreateTextureSampler();
		renderer.CreateDescriptorSets();*/
	}
}

__gshared TextureManager g_TextureManager=new TextureManager();