module RendererMain;

import bindbc.sdl;

class Renderer
{
public:
	void InitFrom(void* window)
	{
		SDL_Init(SDL_INIT_VIDEO);

		_window=SDL_CreateWindowFrom(window);
		SDL_SetWindowSize(_window, 640, 480);

		_surface_main=SDL_GetWindowSurface(_window);

		_renderer=SDL_CreateRenderer(_window, -1, cast(SDL_RendererFlags)0);
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
		SDL_DestroyRenderer(_renderer);
		SDL_DestroyWindow(_window);
		SDL_Quit();
	}

private:
	SDL_Window* _window;
	SDL_Renderer* _renderer;
	public SDL_Surface* _surface_main;
}