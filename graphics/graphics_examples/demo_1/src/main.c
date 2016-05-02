/* Keep these headers */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>

/* Standard headers - it's recommended to leave them included */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Shared libraries */
#include <lib/ce/graphx.h>
#include "gfx/logo_gfx.h"

/* Put function prototypes here */

/* Put all your code here */
void main(void) {
	/* Decalre some variables */
	int x_pos;
	uint8_t y_pos;
	
	/* Seed the random numbers so they are different */
	srand( rtc_Time() );

	/* Initialize some random coordinates */
	x_pos = gfx_RandInt(0,250);
	y_pos = gfx_RandInt(0,170);
	
	/* Initialize the 8bpp graphics */
	gfx_Begin( gfx_8bpp );
	
	/* Set the text color where index 0 is transparent, and the forecolor is random */
	gfx_SetPalette(logo_gfx_pal, sizeof(logo_gfx_pal), 0);
	
	/* Draw a sprite randomly on the screen without clipping */
	gfx_Sprite_NoClip( ubuntu, x_pos, y_pos );
	
	/* Wait for a key to be pressed */
	while( !os_GetCSC() );
	
	/* Close the graphics and return to the OS */
	gfx_End();
	pgrm_CleanUp();
}
