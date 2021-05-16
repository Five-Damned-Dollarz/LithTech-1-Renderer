module Bitmap;

struct BitmapFileHeader
{
align(1):
	ubyte[2] file_type=['B', 'M'];
	uint file_size;
	uint reserved=0;
	uint pixel_data_offset=BitmapFileHeader.sizeof+BitmapInfoHeader.sizeof;
}

struct BitmapInfoHeader
{
align(1):
	uint header_size=BitmapInfoHeader.sizeof;
	int image_width;
	int image_height;
	ushort planes=1;
	ushort bits_per_pixel=32;
	uint compression=0;
	uint image_size=0;
	int x_pixels_per_meter=0;
	int y_pixels_per_meter=0;
	uint colour_count=0;
	uint important_colours=0;
}

struct Bitmap
{
	BitmapFileHeader file_header;
	BitmapInfoHeader info_header;
	ubyte[] pixel_data;
}