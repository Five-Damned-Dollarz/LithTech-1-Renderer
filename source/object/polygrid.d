module Objects.Polygrid;

import Objects.BaseObject;

PolygridObject* ToPolygrid(BaseObject* obj)
{
	return cast(PolygridObject*)obj;
}

struct PolygridObject
{
	alias base this;
	BaseObject base;

	void* polygrid_data;

	void*[17] buf;

	float polygrid_width;
	float polygrid_height;
	float[4] polygrid_colours;
	
	static assert(polygrid_data.offsetof==296);
	static assert(polygrid_width.offsetof==368); // for type_id=Polygrid
	static assert(polygrid_height.offsetof==372); // for type_id=Polygrid
	static assert(polygrid_colours.offsetof==376); // for type_id=Polygrid
}