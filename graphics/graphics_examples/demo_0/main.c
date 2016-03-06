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
#include <graphc.h>

/* Other available headers */
// stdarg.h, setjmp.h, assert.h, ctype.h, float.h, iso646.h, limits.h, errno.h

/* Put function prototypes here */
void waitSeconds(uint8_t seconds);

/* Put all your code here */
void main(void) {
    gc_InitGraph();
    
    /* Fill the screen white */
    gc_FillScrn(0xFF);
    
    /* Wait for 2 seconds */
    waitSeconds(2);
    
    gc_CloseGraph();
    pgrm_CleanUp();
}

/* Wait for a specified about of seconds between 0 and 60 */
void waitSeconds(uint8_t seconds) {
    /* Set the inital seconds to 0 */
    rtc_SetSeconds(0);
    
    /* Load the 0 seconds into the clock */
    rtc_LoadSetTime();
    
    /* Wait until we reach the second needed */
    while(rtc_GetSeconds() != seconds+1);
}