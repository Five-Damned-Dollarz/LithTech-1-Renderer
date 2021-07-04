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

	byte* polygrid_data; // byte[width*height]
	uint* vert_index_data; // triangle_count*6; every 3 indices = 3 vertex indices to make a triangle

	void*[6] buf1;
	void* environment_map; // SharedTexture*
	float texture_pan_x;
	float texture_pan_y;
	float texture_scale_x;
	float texture_scale_y;

	uint triangle_count; // (2-half_tris)*(height-1)*(width-1)
	uint vertex_count; // triangle_count*3, sad...
	void*[3] buf2;

	float polygrid_width;
	float polygrid_height;
	float[4] polygrid_colours;
	
	static assert(polygrid_data.offsetof==296);
	static assert(vert_index_data.offsetof==300);
	static assert(environment_map.offsetof==328);
	static assert(texture_pan_x.offsetof==332);
	static assert(triangle_count.offsetof==348);
	static assert(vertex_count.offsetof==352);
	static assert(polygrid_width.offsetof==368);
	static assert(polygrid_height.offsetof==372);
	static assert(polygrid_colours.offsetof==376);
}