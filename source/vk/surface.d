module vk.Surface;

struct ImageSurface
{
	bool is_locked;
	int width, height, bpp, stride;
	ubyte[] pixels;

	this(uint w, uint h)
	{
		is_locked=false;

		width=w;
		height=h;
		bpp=2; // hardcoded since we /know/ LT1 only blits in 16-bit (555 or 565)
		stride=w*bpp;

		pixels=new ubyte[stride*height];
	}
}