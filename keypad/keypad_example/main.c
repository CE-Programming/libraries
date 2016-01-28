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

/* CE Keypad C Library */
#include <keypadc.h>

/* Some LCD defines */
#define lcd_size 320*240*2
#define lcd_buf  (uint16_t*)0xD40000
void fillScreen(unsigned char color);

/* Main Function */
void main()
{
    /* Key varaible */
    unsigned char key;
    
    /* Loop until 2nd is pressed */
    while(kb_ScanGroup(kb_group_1) != kb_2nd) {
        key = kb_ScanGroup(kb_group_7);
        
        switch(key) {
            case kb_Down:           /* Change screen color to black */
                fillScreen(0x00);
                break;
            case kb_Right:          /* Change screen color to red */
                fillScreen(0xE0);
                break;
            case kb_Up:             /* Change screen color to white */
                fillScreen(0xFF);
                break;
            case kb_Left:           /* Change screen color to a different red */
                fillScreen(0xC0);
                break;
            default:
                break;
        }
    }
    kb_Reset();
}

/* Simple way to fill the screen with a given color */
void fillScreen(unsigned char color) {
    memset(lcd_buf, color, lcd_size);
}