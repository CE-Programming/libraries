/**
 * @file    GRAPHC CE C Library
 * @version 1.0
 *
 * @section LICENSE
 *
 * Copyright (c) 2016, Matthew Waltz
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @section DESCRIPTION
 *
 * This library implements some fast graphical routines
 */

#ifndef H_GRAPHC
#define H_GRAPHC

#pragma asm "include "libheader.asm""
#pragma asm "include "GRAPHC.asm""
#pragma asm "segment code"

/**
 * Quickly set and get pixels.
 * No clipping is performed.
 */
#define gc_drawingBuffer                  (*(uint8_t**)(0xE30014))
#define gc_NoClipPixelPtr(x, y)           ((uint8_t*)(gc_drawingBuffer + x + y*320))
#define gc_NoClipSetPixelColor(x, y, c)   (*(gc_NoClipPixelPtr(x,y)) = c)
#define gc_NoClipGetPixel(x, y)           (*(gc_NoClipPixelPtr(x,y)))
#define gc_RGBTo1555(r,g,b)               ((unsigned short)(((unsigned char)(r) >> 3) << 10) | (((unsigned char)(g) >> 3) << 5) | ((unsigned char)(b) >> 3))
                            
/**
 * Sets the color index that drawing routines will use
 * This applies to lines, rectangles, etc
 * Returns the previous global color index
 */
unsigned char gc_SetColorIndex(unsigned char index);

/**
 * Initializes the graphics setup.
 * This includes setting the LCD into 8bpp mode and
 * loading the default palette
 */
void gc_InitGraph(void);

/**
 * Closes the graphics setup.
 * Restores the LCD to 16bpp prefered by the OS
 * and clears the screen
 */
void gc_CloseGraph(void);

/**
 * Sets up the default palette where high=low
 */
void gc_SetDefaultPalette(void);

/**
 * Sets up the palette; size is in bytes
 */
void gc_SetPalette(unsigned short *palette, unsigned short size);

/**
 * Fills the screen with the given palette index
 */
void gc_FillScrn(unsigned char color);

/**
 * Gets the 1555 color located at the given palette index.
 */
unsigned short gc_GetColor(unsigned char index);

/**
 * Sets the 1555 color located at the given palette index.
 */
void gc_SetColor(unsigned char index, unsigned short color);

/**
 * Sets the XY pixel measured from the top left origin of the screen to the
 * given palette index color. This routine performs clipping.
 */
void gc_ClipSetPixel(int x, int y);

/**
 * Gets the palette index color of the XY pixel measured from the top
 * left origin of the screen. This routine performs clipping.
 */
unsigned char gc_ClipGetPixel(int x, int y);

/**
 * Draws a line given the x,y,x,y coordinates measured from the top left origin.
 * No clipping is performed.
 */
void gc_NoClipLine(unsigned short x0, unsigned char y0, unsigned short x1, unsigned char y1);

/**
 * Draws a filled rectangle measured from the top left origin.
 * No clipping is performed.
 */
void gc_NoClipRectangle(unsigned short x, unsigned char y, unsigned short width, unsigned char height);

/**
 * Draws a rectangle outline measured from the top left origin.
 * No clipping is performed.
 */
void gc_NoClipRectangleOutline(unsigned short x, unsigned char y, unsigned short width, unsigned char height);

/**
 * Draws a fast horizontal line measured from the top left origin.
 * No clipping is performed.
 */
void gc_NoClipHorizLine(unsigned short x, unsigned char y, unsigned short length);

/**
 * Draws a fast vertical line measured from the top left origin.
 * No clipping is performed.
 */
void gc_NoClipVertLine(unsigned short x, unsigned char y, unsigned char length);

/**
 * Draws a filled circle measured from the top left origin.
 * No clipping is performed.
 * This routine disasbles interrupts
 */
void gc_NoClipCircle(unsigned short x, unsigned char y, unsigned short radius);

/**
 * Draws circle outline measured from the top left origin.
 * Clipping is performed.
 * This routine disasbles interrupts
 */
void gc_ClipCircleOutline(unsigned short x, unsigned char y, unsigned short radius);

/**
 * Forces all graphics routines to write to the offscreen buffer
 */
void gc_DrawBuffer(void);

/**
 * Forces all graphics routines to write to the visible screen
 */
void gc_DrawScreen(void);

/**
 * Swaps the buffer with the visible screen and vice versa.
 * The current drawing location remains the same.
 */
void gc_SwapDraw(void);

/**
 * Returns 0 if graphics routines are currently drawing to visible screen
 * The current drawing location remains the same.
 */
unsigned char gc_DrawState(void);

/**
 * Outputs a character at the current cursor position
 * No text clipping is performed.
 */
void gc_PrintChar(char c);

/**
 * Outputs a signed integer at the current cursor position.
 * No text clipping is performed.
 * Values range from: (-8388608-8388607)
 * length must be between 0-8
 */
void gc_PrintInt(int n, unsigned int length);

/**
 * Outputs an unsigned integer at the current cursor position.
 * No text clipping is performed.
 * Values range from: (0-16777215)
 * length must be between 0-8
 */
void gc_PrintUnsignedInt(unsigned int n, unsigned int length);

/**
 * Outputs a string at the current cursor position
 * No text clipping is performed.
 */
void gc_PrintString(char *string);

/**
 * Outputs a string at the given XY coordinates measured from the top left origin.
 * The current cursor position is updated.
 * No text clipping is performed.
 */
void gc_PrintStringXY(char *string, unsigned short x, unsigned char y);

/**
 * Returns the current text cursor X position
 */
unsigned short gc_TextX(void);

/**
 * Returns the current text cursor Y position
 */
unsigned char gc_TextY(void);

/**
 * Sets the text cursor XY position
 */
void gc_SetTextXY(unsigned short x, unsigned char y);

/**
 * Sets the current text color.
 * Low 8 bits represent the foreground color.
 * High 8 bits represent the background color.
 * Returns previous text color
 */
unsigned short gc_SetTextColor(unsigned short color);

/**
 * Sets the transparent color used in text and sprite functions
 * Default index transparency color is 0xFF
 * Returns the previous transparent color
 */
unsigned char gc_SetTransparentColor(unsigned char color);

/**
 * Draws a given sprite to the screen as fast as possible; no transparency, clipping, or anything of the sort.
 * Basically just a direct rectangular data dump onto vram.
 * Note: This routine disables interrupts.
 */
void gc_NoClipDrawSprite(unsigned char *data, unsigned short x, unsigned char y, unsigned char width, unsigned char height);

/**
 * Draws a given sprite to the screen using transparency set with gc_SetTransparentColor()
 * Not as fast as gc_NoClipDrawSprite(), but still performs pretty well.
 * Note: This routine disables interrupts.
 */
void gc_NoClipDrawTransparentSprite(unsigned char *data, unsigned short x, unsigned char y, unsigned char width, unsigned char height);

/**
 * Quickly grab the background behind a sprite (useful for transparency)
 * spriteBuffer must be pointing to a large enough buffer to hold width*height number of bytes
 * spriteBuffer is updated with the screen coordinates given.
 * A pointer to spriteBuffer is also returned for ease of use.
 * Note: This routine disables interrupts.
 */
unsigned char *gc_NoClipGetSprite(unsigned char *data, unsigned short x, unsigned char y, unsigned char width, unsigned char height);

/**
 * Set the font routines to use the provided font, formated 8x8
 */
void gc_SetCustomFontData(unsigned char *fontdata);

/**
 * Set the font routines to use the provided font spacing
 */
void gc_SetCustomFontSpacing(unsigned char *fontspacing);

/**
 * Call gc_SetFontMonospace(0) to set the font routine to not use monospace font
 */
void gc_SetFontMonospace(unsigned char monospace);

/**
 * Returns the width of the input sting
 * Takes into account monospacing flag
 */
unsigned int gc_StringWidth(char *string);

/**
 * Returns the width of the character
 * Takes into account monospacing flag
 */
unsigned int gc_CharWidth(char c);

#endif
