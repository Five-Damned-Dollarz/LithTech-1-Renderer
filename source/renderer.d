module RendererMain;

import bindbc.sdl;

import RendererTypes;
import Texture;

class Renderer
{
public:
	void InitFrom(void* window)
	{
		//SDL_Init(SDL_INIT_VIDEO);
		_window=SDL_CreateWindowFrom(window);
		SDL_SetWindowSize(_window, 640, 480);
		//SDL_SetWindowFullscreen(_window, SDL_WINDOW_FULLSCREEN_DESKTOP);

		_surface_main=SDL_CreateRGBSurfaceWithFormat(0, 640, 480, 16, SDL_PIXELFORMAT_RGB565);

		_renderer=SDL_CreateRenderer(_window, -1, SDL_RENDERER_ACCELERATED);
		SDL_RenderSetLogicalSize(_renderer, 640, 480);
		SDL_SetRenderDrawColor(_renderer, 100, 149, 237, 255);
	}

	void RenderScene(SceneDesc* scene_desc)
	{
		//
	}

	void SwapBuffers()
	{
		/+
		// check for keys to rotate selected texture
		// splat a texture here
		+/

		SDL_Texture* buffer=SDL_CreateTextureFromSurface(_renderer, _surface_main);
		SDL_RenderCopy(_renderer, buffer, null, null);
		SDL_DestroyTexture(buffer);
		SDL_RenderPresent(_renderer);
	}

	void Clear()
	{
		SDL_RenderClear(_renderer);
	}

	void Destroy()
	{
		SDL_FreeSurface(_surface_main);
		SDL_DestroyRenderer(_renderer);
		//SDL_DestroyWindow(_window);
		//SDL_Quit();
	}

	void* CreateSurface(const int width, const int height)
	{
		return SDL_CreateRGBSurfaceWithFormat(0, width, height, 16, SDL_PIXELFORMAT_RGB565);
	}

	void DeleteSurface(void* surface)
	{
		SDL_FreeSurface(cast(SDL_Surface*)surface);
	}

	void* LockSurface(void* texture)
	{
		SDL_Surface* surface=cast(SDL_Surface*)texture;

		if (surface is null)
			return null;

		if (SDL_LockSurface(surface))
			return null;

		return cast(void*)surface.pixels;
	}

	void UnlockSurface(void* texture)
	{
		if (texture is null)
			return;

		SDL_Surface* surface=cast(SDL_Surface*)texture;
		SDL_UnlockSurface(surface);
	}

	void GetSurfaceInfo(void* surface, int* width, int* height, int* pitch)
	{
		if (surface is null) return;

		SDL_Surface* trans_surf=cast(SDL_Surface*)surface;

		*width=trans_surf.w;
		*height=trans_surf.h;
		*pitch=trans_surf.pitch;
	}

	int LockScreen(int left, int top, int right, int bottom, void** pixels, int* pitch)
	{
		if (SDL_LockSurface(_surface_main)==0)
		{
			void* start_byte=_surface_main.pixels;
			start_byte+=(top*_surface_main.pitch)+(left << 1);
			if (pixels!=null)
				*pixels=start_byte;
			if (pitch!=null)
				*pitch=_surface_main.pitch;

			return 1;
		}

		return 0;
	}

	void UnlockScreen()
	{
		SDL_UnlockSurface(_surface_main);
	}

	void BlitToScreen(BlitRequest* blit_request)
	{
		SDL_Surface* surface=cast(SDL_Surface*)blit_request.surface_ptr;
		SDL_Surface* conv_surf=SDL_ConvertSurface(surface, _surface_main.format, 0);

		Rect* source_rect=cast(Rect*)blit_request.source_rect;
		Rect* dest_rect=cast(Rect*)blit_request.dest_rect;

		SDL_Rect src_rect=SDL_Rect(source_rect.x1, source_rect.y1, source_rect.x2-source_rect.x1, source_rect.y2-source_rect.y1);
		SDL_Rect dst_rect=SDL_Rect(dest_rect.x1, dest_rect.y1, dest_rect.x2-dest_rect.x1, dest_rect.y2-dest_rect.y1);

		if (blit_request.flags & BlitRequestFlags.ColourKey)
		{
			SDL_SetColorKey(conv_surf, SDL_TRUE, blit_request.colour_key);
		}

		SDL_BlitScaled(conv_surf, &src_rect, _surface_main, &dst_rect);

		SDL_FreeSurface(conv_surf);
	}

private:
	SDL_Window* _window;
	SDL_Renderer* _renderer;
	public SDL_Surface* _surface_main;
}