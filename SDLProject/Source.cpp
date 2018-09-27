/*
todo:
save and load sets of velocities
key to only change colors
let the user resize the window as it's going
*/

#include <stdlib.h>
#include <stdio.h>
#include <SDL.h>
#include <time.h>

#define MAX_BOUNCERS 1000

struct Bouncer 
{
	int r, g, b, a;
	float x, y, xs, ys;
};

Bouncer bouncers[MAX_BOUNCERS];

void init_bouncer(int i, int w, int h)
{
	bouncers[i].r = rand() % 256;
	bouncers[i].g = rand() % 256;
	bouncers[i].b = rand() % 256;

	//printf("%d %d %d\n", bouncers[i].r, bouncers[i].g, bouncers[i].b);

	bouncers[i].a = 255;
	bouncers[i].x = rand() / float(RAND_MAX) * w;
	bouncers[i].y = rand() / float(RAND_MAX) * h;
	bouncers[i].xs = rand() / float(RAND_MAX) * 2 - 1;
	bouncers[i].ys = rand() / float(RAND_MAX) * 2 - 1;
}

void init_bouncers(int num_bouncers, int w, int h)
{
	for (int i = 0; i < num_bouncers; i++)
	{
		init_bouncer(i, w, h);
	}
}

int main(int argc, char * argv[]) {
	SDL_Event event;
	SDL_Renderer *renderer;
	SDL_Window *window;
	SDL_DisplayMode dm;
	int num_bouncers = 3;
	int iters;
	srand(time(NULL));
	SDL_Init(SDL_INIT_VIDEO);

	if (SDL_GetDesktopDisplayMode(0, &dm) != 0) {
		SDL_Log("SDL_GetDesktopDisplayMode failed: %s", SDL_GetError());
		return 1;
	}
	iters = dm.w;
	init_bouncers(num_bouncers, dm.w, dm.h);

	SDL_CreateWindowAndRenderer(dm.w, dm.h, 0, &window, &renderer);
	SDL_RenderPresent(renderer);
	while (1) {
		for (int c = 0; c < iters; c++)
		{
			for (int i = 0; i < num_bouncers; i++)
			{
				bouncers[i].x += bouncers[i].xs;
				if (bouncers[i].x >= dm.w || bouncers[i].x < 0) {
					bouncers[i].x -= bouncers[i].xs;
					bouncers[i].xs = -bouncers[i].xs;
				}
				bouncers[i].y += bouncers[i].ys;
				if (bouncers[i].y >= dm.h || bouncers[i].y < 0) {
					bouncers[i].y -= bouncers[i].ys;
					bouncers[i].ys = -bouncers[i].ys;
				}
				SDL_SetRenderDrawColor(renderer, bouncers[i].r, bouncers[i].g, bouncers[i].b, bouncers[i].a);
				//SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
				SDL_RenderDrawPoint(renderer, int(bouncers[i].x), int(bouncers[i].y));
				//printf("%d %d %d %d", bouncers[i].r, bouncers[i].g, bouncers[i].b, bouncers[i].a);
				//printf("%d, %d\n", int(bouncers[i].x), int(bouncers[i].y));
			}
		}
		SDL_RenderPresent(renderer);
		if (SDL_PollEvent(&event))
		{
			switch (event.type)
			{
			case SDL_KEYUP:
				switch (event.key.keysym.sym)
				{
			//	case SDLK_f: 
			//		SDL_RestoreWindow(window); //Incase it's maximized...
			//		SDL_SetWindowSize(window, dm.w, dm.h);
			//		SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
			//		break;
				case SDLK_r: //reset
					init_bouncers(num_bouncers, dm.w, dm.h);
					break;
				case SDLK_RIGHTBRACKET:
					init_bouncer(num_bouncers, dm.w, dm.h);
					if(num_bouncers < MAX_BOUNCERS) num_bouncers++;
					break;
				case SDLK_LEFTBRACKET:
					if(num_bouncers > 0) num_bouncers--;
					break;
				case SDLK_ESCAPE:
					SDL_DestroyRenderer(renderer);
					SDL_DestroyWindow(window);
					SDL_Quit();
					return EXIT_SUCCESS;
				}
				break;
			}
		}
	}
}

