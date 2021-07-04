module Objects.Sprite;

import Objects.BaseObject;
import RendererTypes: DLink;

SpriteObject* ToSprite(BaseObject* obj)
{
	return cast(SpriteObject*)obj;
}

/+ 010 Template for LT1 .spr files:
struct Header
{
	uint frame_count;
	uint frame_rate; // in fps
	uint unknown[3];
} header;

struct DString
{
	ushort count;
	char str[count];
} strings[header.frame_count] <optimize=false>;
+/

package struct SpriteData
{
	DLink link;
	SpriteRaw* data; // 60 byte stride
	uint is_init; // unsure

	static assert(this.sizeof==20);
}

package struct SpriteRaw // engine should fail and return null for creation of this struct if there's more than 999 textures in a sprite
{
	char[32] name;
	void** frame_textures; // SharedTexture**
	uint frame_count;
	uint loop_duration; // 1000/frame_rate[file_start+4]*frame_count
	uint[4] unknown;

	static assert(this.sizeof==60);
	static assert(frame_textures.offsetof==0x20);
}

// Sprite control flags.  Default flags for a sprite are SC_PLAY|SC_LOOP.
enum SpriteControlFlags
{
	Play=(1<<0),
	Loop=(1<<1),
}

extern(C++, class) abstract class SpriteControl // from AppHeaders/SpriteControl.h
{
public:
	int GetNumAnims(ref int nAnims);
	int GetNumFrames(int iAnim, ref int nFrames);

	int GetCurPos(ref int iAnim, ref int iFrame);
	int SetCurPos(int iAnim, int iFrame);

	int GetFlags(ref int flags);
	int SetFlags(int flags);
};

struct SpriteObject
{
	alias base this;
	BaseObject base;

	SpriteData* sprite_data;

	void*[5] buf;
	SpriteControl* sprite_control;
	void* self_ref;
	
	static assert(sprite_data.offsetof==296); // probably the actual sprite data: texture list, etc.
	//static assert(???.offsetof==316); // init to 0xFFFFFFFF
	static assert(sprite_control.offsetof==320); // in-place? interface in AppHeaders/SpriteControl.h
	static assert(self_ref.offsetof==324); // self ref
}