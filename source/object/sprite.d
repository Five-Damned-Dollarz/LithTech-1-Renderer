module Objects.Sprite;

import Objects.BaseObject;

SpriteObject* ToSprite(BaseObject* obj)
{
	return cast(SpriteObject*)obj;
}

struct SpriteObject
{
	alias base this;
	BaseObject base;
	
	//static assert(???.offsetof==316); // for type_id=Sprite, init to 0xFFFFFFFF
	//static assert(sprite_control.offsetof==320); // for type_id=Sprite, in-place? interface in AppHeaders/SpriteControl.h
	//static assert(???.offsetof==324); // for type_id=Sprite, self ref
}