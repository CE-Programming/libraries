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
#include <fileioc.h>

void cleanUp();
void print(const char* string, uint8_t col, uint8_t row);

char appvarName[] = "AppVar";
    
/* Main Function */
void main(void)
{
    unsigned int index, file, i;
    unsigned char array[] = { 10,20,30 };
    
    /* Close all open file handles before we try any funny business */
    ti_CloseAll();
    
    /* Open a file for writting -- delete it if it already exists */
    file = ti_Open(appvarName, "w");
    
    if (file) {
         print("All good in the hood.",0 ,0 );
         if(ti_PutC('A',file) == 'A') {
             print("Wrote an 'A'",0 ,1 );
             
             /* Write the array to the file */
             ti_Write(&array, sizeof(unsigned char), sizeof(array)/sizeof(unsigned char), file);
             
             /* Move the offest to 0 */
             ti_Rewind(file);
             if(ti_GetC(file) == 'A') {
                print("Read an 'A'",0 ,2 );
                
                /* Reset the array */
                memset(&array, 0, sizeof(array));
                
                /* Read (Should be from offset 1) */
                ti_Read(&array, sizeof(unsigned char), sizeof(array)/sizeof(unsigned char), file);
                
                /* Check if we read the data back correctly */
                if( array[0] == 10 && array[1] == 20 && array[2] == 30 ) {
                    print("Read 10,20,30",0 ,3 );
                }
             }
         }
    } else {
        /* Print an error message */
        print("Bro, it broke.",0,0);
    }
    
    /* Don't use this routine */
    _OS( GetKey() );
    
    ti_CloseAll();
    cleanUp();
}

/* Other functions */

void print(const char* string, uint8_t xpos, uint8_t ypos)
{
    _OS( asm("LD HL,(IX+6)");
         asm("LD A,(IX+9)");
         asm("LD (curCol),A");
         asm("LD A,(IX+12)");
         asm("LD (curRow),A");
         asm("CALL _PutS");
       );
}

void cleanUp()
{
    // Clear/invalidate some RAM areas
    _OS( asm("CALL _DelRes");
         asm("CALL _ClrTxtShd");
         asm("CALL _ClrScrn");
         asm("SET  graphDraw,(iy+graphFlags)");
         asm("CALL _HomeUp");
         asm("CALL _DrawStatusBar");
       );
}

// D1A945