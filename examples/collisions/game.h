/*
 *  game.h
 *  iminib3d
 *
 *  Created by Simon Harrison.
 *  Copyright Si Design. All rights reserved.
 *
 */

#ifndef GAME_H
#define GAME_H

#include "iminib3d.h"

class Game{

public:

	Pivot* piv;
	Camera* cam;
	Light* light;

	Mesh* mesh[6];

	Game(){

		piv=NULL;
		cam=NULL;
		light=NULL;

	}
	
	void Init();
	void Run();
	void End();

};

#endif