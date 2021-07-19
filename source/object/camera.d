module Objects.Camera;

import Objects.BaseObject;

import RendererTypes: Rect;

CameraObject* ToCamera(BaseObject* obj)
{
	return cast(CameraObject*)obj;
}

struct CameraObject
{
	alias base this;
	BaseObject base;
	
	Rect view_rect;
	float fov_x;
	float fov_y;
	bool fullscreen;

	void*[3] unknown; // init to 0, are sent to SceneDesc.camera_unknown[0..3] in ClientDE.RenderCamera(cam_obj)
	
	static assert(this.sizeof==336);
	static assert(view_rect.offsetof+view_rect.x1.offsetof==296);
	static assert(view_rect.offsetof+view_rect.x2.offsetof==304);
	static assert(fov_x.offsetof==312);
	static assert(fullscreen.offsetof==320);
	static assert(unknown.offsetof==324);
}