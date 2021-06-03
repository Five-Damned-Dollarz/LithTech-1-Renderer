module Objects.Camera;

import Objects.BaseObject;

CameraObject* ToCamera(BaseObject* obj)
{
	return cast(CameraObject*)obj;
}

struct CameraObject
{
	alias base this;
	BaseObject base;
	
	float view_left;
	float view_top;
	float camera_width;
	float camera_height;
	float fov_x;
	float fov_y;
	bool fullscreen;
	
	static assert(view_left.offsetof==296); // for type_id=Camera
	static assert(camera_width.offsetof==304); // for type_id=Camera
	static assert(fov_x.offsetof==312); // for type_id=Camera
	static assert(fullscreen.offsetof==320); // for type_id=Camera
}