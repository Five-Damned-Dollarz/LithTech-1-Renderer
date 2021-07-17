module Objects.WorldModel;

import Objects.BaseObject;

import WorldBsp: WorldData;

import gl3n.linalg;

WorldModelObject* ToWorldModel(BaseObject* obj)
{
	return cast(WorldModelObject*)obj;
}

/+
 + Container might just be different functions operating on WorldModelObject rather than an extension? More research required!
 +/
struct WorldModelObject
{
	alias base this;
	BaseObject base;
	
	//
	WorldData* bsp_data;
	mat4 unknown_1;
	//mat4 unknown_2;

	static assert(bsp_data.offsetof==296);
}