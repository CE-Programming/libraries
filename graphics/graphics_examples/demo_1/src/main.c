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
#include <lib/ce/graphc.h>
#include "gfx/logo_gfx.h"
/* Put function prototypes here */

/* Put all your code here */
void main(void) {	
	/* Initialize the graphics */
	gc_InitGraph();
	
	/* Set the palette to the current group */
	gc_SetPalette(logo_gfx_pal, sizeof(logo_gfx_pal));
	
	/* Fill the screen */
	gc_FillScrn(logo_gfx_transpcolor_index);
	gc_SetTransparentColor(logo_gfx_transpcolor_index);
	
	/* Draw the logo in the center of the screen */
	gc_NoClipDrawScaledTransparentSprite(ubuntu,(320-ubuntu_width*3)/2,(240-ubuntu_height*3)/2,ubuntu_width,ubuntu_height, 3, 3);
	
	/* Wait for a key to be pressed -- Don't use this in your actual programs! */
	os_GetKey();
	
	/* Close the graphics and return to the OS */
	gc_CloseGraph();
	pgrm_CleanUp();
}

void rotateSprite(const char *str) {
}
