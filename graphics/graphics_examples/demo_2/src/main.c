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

/* Put function prototypes here */

/* Put all your code here */
void main(void) {
	
	/* Seed the random numbers */
	srand(rtc_Time());
	
	/* Initialize the graphics */
	gc_InitGraph();
	
	while(!os_GetCSC()) {
		gc_SetColorIndex(gc_RandInt(0,255));
		gc_ClipLine(gc_RandInt(-640,640), gc_RandInt(-480,480), gc_RandInt(-640,640), gc_RandInt(-480,480));	
	}
	
	/* Close the graphics and return to the OS */
	gc_CloseGraph();
	pgrm_CleanUp();
}
