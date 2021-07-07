module Objects.WorldModel;

import Objects.BaseObject;

import WorldBSP: WorldData;

import gl3n.linalg;

WorldModelObject* ToWorldModel(BaseObject* obj)
{
	return cast(WorldModelObject*)obj;
}

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