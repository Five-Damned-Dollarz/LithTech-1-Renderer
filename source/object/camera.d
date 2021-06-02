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
	
	void*[2] buf;
	
	float camera_width;
	float camera_height;
	float fov_x;
	float fov_y;
	
	static assert(camera_width.offsetof==304); // for type_id=Camera
	static assert(fov_x.offsetof==312); // for type_id=Camera
}