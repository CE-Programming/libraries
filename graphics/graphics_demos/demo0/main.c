/* Keep these headers */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <ti84pce.h>
 
/* Standard headers - it's recommended to leave them included */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* CE Graphics C Library */
#include <graphc.h>

/* Main Function */
void main(void)
{
    /* Some variable intialization */
    unsigned int x,y,r;
    unsigned char color = 0;

    gc_InitGraph();
    
    /* Draw an 8x8 palette */
    for(y=0;y<128;y+=16) {
        for(x=0;x<128;x+=16) {
            gc_SetColorIndex(color);
            gc_NoClipRectangle(x,y,16,16);
            color++;
        }
        color+=24;
    }
    
    /* Print a string of stuff */
    gc_PrintStringXY("Palette Test",150,10);
    
    /* This is a really bad function to use. Don't use it in actual things */
    _OS( GetKey() );

    /* Close the graphics canvas and return to the OS */
    gc_CloseGraph();
}