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

/* Sprite file */
#include "mushroomsprite.h"

/* Main Function */
void main(void)
{
    /* Some variable intialization */
    unsigned int x,y,r;
    unsigned char color = 0;
    unsigned char *mushroombuffer = malloc(sizeof mushroomsprite);
    
    gc_InitGraph();
    
    /* Draw an 8x8 palette */
    for(y=0;y<128;y+=16) {
        for(x=0;x<128;x+=16) {
            gc_NoClipRectangle(x,y,16,16, color);
            color++;
        }
        color+=24;
    }
    
    /* Print a string of stuff */
    gc_PrintStringXY("Palette Test",150,10);
    
    /* This is a really bad function to use. Don't use it in actual things */
    _OS( GetKey() );
    
    /* Fill the screen with blackness */
    gc_FillScrn(0x00);
    
    /* Draw a whole bunch of circles */
    for(r=0;r<120;r+=2) {
        gc_ClipCircleOutline(160,120,r,r);
        gc_ClipCircleOutline(160,0,r,r);
        gc_ClipCircleOutline(319,120,r,r);
        gc_ClipCircleOutline(0,120,r,r);
        gc_ClipCircleOutline(160,239,r,r);
    }
    
    /* This is a really bad function to use. Don't use it in actual things */
    _OS( GetKey() );
    
    /* Fill the screen with lightness */
    gc_FillScrn(0xFF);
    
    for(x=0;x<320;x++) {
        gc_NoClipLine(160,0,x,120,x);
        gc_NoClipLine(160,239,x,120,x);
    }
    
    /* This is a really bad function to use. Don't use it in actual things */
    _OS( GetKey() );
    
    /* Fill the screen with darkness */
    gc_FillScrn(0xFF);
    
    /* Set only the palette we need of mushroomsprite */
    gc_SetPalette(mushroomsprite_pal, sizeof mushroomsprite_pal);
    
    /* Mushroom sprite uses that pink color as its transparent color. That is set to
       index 0 in the color table */
    gc_SetTransparentColor(0x00);
    
    /* Place a whole buch of mushrooms onscreen */
    for(x=16;x<320-48;x+=48) {
        for(y=16;y<120;y+=48) {
            gc_NoClipDrawTransparentSprite(mushroomsprite,x,y,32,32);
        }
    }
    
    /* Change the color of the green to red */
    for(x=0;x<sizeof(mushroomsprite);x++) {
        if(mushroomsprite[x] == 0x02) {
            mushroomsprite[x] = 0xE0;
        }
    }
    
    /* Grab one of the green mushrooms */
    gc_NoClipGetSprite(mushroombuffer,16,16,32,32);
    
    /* Turn the grabbed mushroom blue because we can */
    for(x=0;x<sizeof(mushroomsprite);x++) {
        if(mushroombuffer[x] == 0x02) {
            mushroombuffer[x] = 0x1A;
        }
    }
    
    /* Place our fancy blue mushroom */
    gc_NoClipDrawSprite(mushroombuffer,16,160,32,32);
    
    /* Draw some more mushrooms */
    for(x=64;x<320-48;x+=48) {
        gc_NoClipDrawTransparentSprite(mushroomsprite,x,160,32,32);
    }
    
    /* This is a really bad function to use. Don't use it in actual things */
    _OS( GetKey() );
    
    /* Free the buffer */
    free(mushroombuffer);
    
    /* Close the graphics canvas and return to the OS */
    gc_CloseGraph();
}