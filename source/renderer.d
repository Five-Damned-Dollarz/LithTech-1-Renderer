module RendererMain;

import bindbc.sdl;

import RendererTypes;

class Renderer
{
public:
	void InitFrom(void* window)
	{
		//import core.sys.windows.winuser: UpdateWindow, ShowWindow, SW_SHOW;
		//ShowWindow(window, SW_SHOW);
		//UpdateWindow(window);

		//SDL_Init(SDL_INIT_VIDEO);

		_window=SDL_CreateWindowFrom(window);
		SDL_SetWindowSize(_window, 640, 480);
		//SDL_SetWindowFullscreen(_window, SDL_WINDOW_FULLSCREEN_DESKTOP);

		_surface_main=SDL_CreateRGBSurfaceWithFormat(0, 640, 480, 16, SDL_PIXELFORMAT_RGB565);

		_renderer=SDL_CreateRenderer(_window, -1, SDL_RENDERER_ACCELERATED);
		SDL_RenderSetLogicalSize(_renderer, 640, 480);
		SDL_SetRenderDrawColor(_renderer, 100, 149, 237, 255);
	}

	void SwapBuffers()
	{
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

private:
	SDL_Window* _window;
	SDL_Renderer* _renderer;
	public SDL_Surface* _surface_main;
}