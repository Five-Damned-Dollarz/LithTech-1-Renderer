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

	void*[3] buf; // init to 0
	
	static assert(this.sizeof==336);
	static assert(view_left.offsetof==296);
	static assert(camera_width.offsetof==304);
	static assert(fov_x.offsetof==312);
	static assert(fullscreen.offsetof==320);
	//static assert(unknown.offsetof==332);
}