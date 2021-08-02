module LTCore;

import RendererTypes: DLink;

struct LTAllocation
{
	int buf0; // unknown, mirrors stride?
	int stride;
	int block_size;
	int block_count;
	int total_size;
	
	void* buf1; // actual allocation ptr, 8 byte header: [0] = address to next, [1] = size of allocation
	void* buf2; // unknown, possibly pointer to the next position this allocation will emplace to?

	static assert(this.sizeof==28);
}

enum LTFileType
{
	/+
	// from AppHeaders/de_codes.h:
	// File types.
	#define FT_MODEL		0
	#define FT_SPRITE		1
	#define FT_TEXTURE		2
	#define FT_SOUND		3
	+/

	// don't know why they're off-by-one
	Unknown=0,
	Model=1,
	Sprite=2,
	Texture=3,
	Sound=4,
}

struct LTFileStream
{
	void* ref_; // ref to owner object eg. SharedTexture*, ModelData*, etc.?
	DLink link; // data = LTFileStream*
	void* unknown_1;

	// would be unsurprised if this is "framecode" like in other objects
	short unknown_2; // -1
	short unknown_3; // observed range: 22-39

	LTFileType file_type;
	char* file_name; // rez relative path

	static assert(this.sizeof==32);
}