module Objects.Light;

import Objects.BaseObject;

LightObject* ToLight(BaseObject* obj)
{
	return cast(LightObject*)obj;
}

struct LightObject
{
	alias base this;
	BaseObject base;
	
	float radius;
	
	static assert(radius.offsetof==296); // for type_id=Light
}