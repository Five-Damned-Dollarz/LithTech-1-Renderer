module Objects.WorldModel;

import Objects.BaseObject;

import WorldBsp : WorldBsp, WorldData;

import gl3n.linalg;

WorldModelObject* ToWorldModel(BaseObject* obj)
{
	return cast(WorldModelObject*)obj;
}

struct WorldModelObject
{
	alias base this;
	BaseObject base;
	
	WorldData* bsp_data;
	mat4 unknown_1;
	mat4 unknown_2;

	static assert(bsp_data.offsetof==296);
	static assert(this.sizeof>=428);
}

/+
 + Container might just be different functions operating on WorldModelObject rather than an extension? More research required!
 +/

ContainerObject* ToContainer(BaseObject* obj)
{
	return cast(ContainerObject*)obj;
}

struct ContainerObject
{
	alias base this;
	WorldModelObject base;

	short container_code;

	static assert(container_code.offsetof==428);
}