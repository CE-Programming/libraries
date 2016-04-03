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
void printStringCentered(const char *str);

/* Put all your code here */
void main(void) {
	/* Seed the random numbers */
	srand(rtc_Time());
	
	/* Initialize the graphics */
	gc_InitGraph();
	
	/* Fill the screen black */
	gc_FillScrn(0x00);
	
	/* Set the text color where index 0 is transparent, and the forecolor is random */
	gc_SetTextColor(rand()%255);
	
	/* Print a string; centered on the screen */
	printStringCentered("Hello World!");

	/* Wait for a key to be pressed -- Don't use this in your actual programs! */
	os_GetKey();
	
	/* Close the graphics and return to the OS */
	gc_CloseGraph();
	pgrm_CleanUp();
}

void printStringCentered(const char *str) {
	gc_PrintStringXY(str, (gc_lcdWidth-gc_StringWidth(str))/2,(gc_lcdHeight-gc_fontHeight())/2);
}
