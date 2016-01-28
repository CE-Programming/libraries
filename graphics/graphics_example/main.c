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
    unsigned int x,y,r;
    unsigned char color = 0;
    gc_InitGraph();
    
    for(y=0;y<128;y+=16) {
        for(x=0;x<128;x+=16) {
            gc_NoClipRectangle(x,y,16,16, color);
            color++;
        }
        color+=24;
    }
    
    gc_PrintStringXY("Palette Test",150,10);
    
    _OS( GetKey() );
    
    gc_FillScrn(0x00);
    
    for(r=0;r<120;r+=2) {
        gc_ClipCircleOutline(160,120,r,r);
        gc_ClipCircleOutline(160,0,r,r);
        gc_ClipCircleOutline(319,120,r,r);
        gc_ClipCircleOutline(0,120,r,r);
        gc_ClipCircleOutline(160,239,r,r);
    }
    
    _OS( GetKey() );
    
    gc_FillScrn(0xFF);
    
    for(x=0;x<320;x++) {
        gc_NoClipLine(160,0,x,120,x);
        gc_NoClipLine(160,239,x,120,x);
    }
    
    _OS( GetKey() );
    
    gc_SwapDraw();
    
    gc_DrawScreen();
    
    gc_FillScrn(0xFF);
    
    for(y=0;y<240;y++) {
        gc_NoClipLine(0,120,160,y,y+8);
        gc_NoClipLine(319,120,160,y,y+8);
    }
    
    _OS( GetKey() );
    
    gc_SwapDraw();
    
    _OS( GetKey() );
    
    gc_CloseGraph();
}