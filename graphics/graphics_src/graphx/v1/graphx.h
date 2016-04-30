/**
 * @file    GRAPHX CE C Library
 * @version 1.0
 *
 * @section LICENSE
 *
 * Copyright (c) 2016
 * Matthew "MateoConLechuga" Waltz
 * Jacob "jacobly" Young
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

#include <stdint.h>
#include <stdbool.h>

/**
 * For transparent routines; index 0 shall represent the transparent color
 */

typedef struct gfx_sprite {
	uint8_t width;
	uint8_t height;
	uint8_t data[1];
} gfx_sprite_t;

gfx_sprite_t *gfx_AllocSprite(uint8_t width, uint8_t height);
#define gfx_TempSprite(name, width, height) uint8_t name[2 + (width) * (height)] = { (width), (height) }

typedef enum gfx_mode {
	gfx_8bpp = 0x27
} gfx_mode_t;

/**
 * Initializes the graphics setup 
 * Set LCD to 8bpp mode and loads the default palette
 */
int gfx_Begin(gfx_mode_t mode);

/**
 * Closes the graphics setup
 * Restores the LCD to 16bpp prefered by the OS and clears the screen
 */
void gfx_End(void);

/**
 * Used for accessing the palette directly
 * 256 is valid only for the 8 bpp mode
 */
uint16_t gfx_palette[256] _At 0xE30200;
/**
 * Array of the LCD VRAM
 */
uint8_t gfx_vram[2][240][320] _At 0xD40000;
#define gfx_vbuffer (*(uint8_t (*)[240][320])0xE30014)

/* Type for the clip region */
typedef struct gfx_region {
	int x_left, y_top, x_right, y_bottom;
} gfx_region_t;

/* Type for tilemap */
typedef struct gfx_tilemap {
	uint8_t *map;             /* pointer to indexed map array */
	uint8_t **tiles;          /* pointer to tiles */
	uint8_t tile_height;      /* individual tile height */
	uint8_t tile_width;       /* individual tile width */
	uint8_t draw_height;      /* number of rows to draw in the tilemap */
	uint8_t draw_width;       /* number of cols to draw tilemap */
	uint8_t type_width;       /* 2^type_width = tile_width */
	uint8_t type_height;      /* 2^type_height = tile_height */
	uint8_t height;           /* total number of rows in the tilemap */
	uint8_t width;            /* total number of cols in the tilemap */
	uint8_t y_loc;            /* y pixel location to begin drawing at */
	uint24_t x_loc;           /* x pixel location to begin drawing at */
} gfx_tilemap_t;

typedef enum gfx_tilemap_type {
	gc_tile_2_pixel = 1,      /* Set when using 2 pixel tiles */
	gc_tile_4_pixel,          /* Set when using 4 pixel tiles */
	gc_tile_8_pixel,          /* Set when using 8 pixel tiles */
	gc_tile_16_pixel,         /* Set when using 16 pixel tiles */
	gc_tile_32_pixel,         /* Set when using 32 pixel tiles */
	gc_tile_64_pixel,         /* Set when using 64 pixel tiles */
	gc_tile_128_pixel,        /* Set when using 128 pixel tiles */
} gfx_tilemap_type_t;

/**
 * Draws a tilemap given an initialized tilemap structure
 *  x_offset : offset in pixels from the of the tilemap
 *  y_offset : offset in pixels from the top of the tilemap
 */
void gfx_Tilemap(gfx_tilemap_t *tilemap, uint24_t x_offset, uint24_t y_offset);
void gfx_Tilemap_NoClip(gfx_tilemap_t *tilemap, uint24_t x_offset, uint24_t y_offset);

/**
 * Draws a transparent tilemap given an initialized tilemap structure
 *  x_offset : offset in pixels from the left left of the tilemap
 *  y_offset : offset in pixels from the top of the tilemap
 */
void gfx_TransparentTilemap(gfx_tilemap_t *tilemap, uint24_t x_offset, uint24_t y_offset);
void gfx_TransparentTilemap_NoClip(gfx_tilemap_t *tilemap, uint24_t x_offset, uint24_t y_offset);

/**
 * Tile Setting/Getting -- Uses absolute pixel offsets from the top left
 */
uint8_t *gfx_TilePtr(gfx_tilemap_t *tilemap, uint24_t x_offset, uint24_t y_offset);
#define gfx_SetTile(a,b,c,d)	(*(gfx_TilePtr(a, b, c)) = (uint8_t)d)
#define gfx_GetTile(a,b,c)	(*(gfx_TilePtr(a, b, c)))

/**
 * Tile Setting/Getting -- Uses a mapped offsets from the tile map itself
 */
uint8_t *gfx_TilePtrMapped(gfx_tilemap_t *tilemap, uint8_t x_offset, uint8_t y_offset);
#define gfx_SetTileMapped(a,b,c,d)	(*(gfx_TilePtrMapped(a, b, c)) = (uint8_t)d)
#define gfx_GetTileMapped(a,b,c)	(*(gfx_TilePtrMapped(a, b, c)))

/**
 * Decompress a block of data using an LZ77 decoder
 *  in  : Compressed buffer
 *  out : Decompressed buffer; must be large enough to hold decompressed data
 *  insize : Number of input bytes
 */
void gfx_LZDecompress(uint8_t *in, uint8_t *out, unsigned in_size);


// PuCrunch, the de-facto standard on the TI-68k series :)

/**
 * Sets the color index that drawing routines will use
 * This applies to lines, rectangles, etc
 * Returns the previous global color index
 */
uint8_t gfx_SetColor(uint8_t index);

/**
 * Sets up the default palette for the given mode
 */
void gfx_SetDefaultPalette(gfx_mode_t mode);

/**
 * Set entries 0-255 in the palette (index 0 is transparent for transparent routines)
 */
void gfx_SetPalette(uint16_t *palette, uint24_t size, uint8_t offset);

/**
 * Fills the screen with the given palette index
 */
void gfx_FillScreen(uint8_t color);
void gfx_FillScreenLines(uint8_t y_start, uint8_t color);

/**
 * Sets the XY pixel measured from the top left origin of the screen to the
 * given palette index color. This routine performs clipping.
 */
void gfx_SetPixel(uint24_t x, uint8_t y);

/**
 * Gets the palette index color of the XY pixel measured from the top
 * left origin of the screen. This routine performs clipping.
 */
uint8_t gfx_GetPixel(uint24_t x, uint8_t y);

/**
 * Draws a line given the x,y,x,y coordinates measured from the top left origin.
 */
void gfx_Line(int x0, int y0, int x1, int y1);
void gfx_Line_NoClip(uint24_t x0, uint8_t y0, uint24_t x1, uint8_t y1);

/**
 * Clips the points in a line region
 * Returns false if offscreen
 */
bool gfx_CohenSutherlandClip(int *x0, int *y0, int *x1, int *y1);

/**
 * Draws a horizontal line measured from the top left origin.
 */
void gfx_HorizLine(int x, int y, int length);
void gfx_HorizLine_NoClip(uint24_t x, uint8_t y, uint24_t length);

/**
 * Draws a vertical line measured from the top left origin.
 */
void gfx_VertLine(int x, int y, int length);
void gfx_VertLine_NoClip(uint24_t x, uint8_t y, uint24_t length);

/**
 * Draws a vertical line measured from the top left origin.
 */
void gfx_PolyLine(int *points);
void gfx_PolyLine_NoClip(int *points);

/**
 * Draws a rectangle measured from the top left origin.
 */
void gfx_Rectangle(int x, int y, int width, int height);
void gfx_Rectangle_NoClip(uint24_t x, uint8_t y, uint24_t width, uint8_t height);
void gfx_FillRectangle(int x, int y, int width, int height);
void gfx_FillRectangle_NoClip(uint24_t x, uint8_t y, uint24_t width, uint8_t height);

/**
 * Draws a rectangle with rounded corners of given radius, measured from the top left origin.
 * Code example: github.com/adriweb/BetterLuaAPI-for-TI-Nspire/blob/master/BetterLuaAPI.lua#L198-L222
 */
void gfx_RoundRectangle(int x, int y, unsigned width, unsigned height, unsigned radius);
void gfx_RoundRectangle_NoClip(uint24_t x, uint8_t y, unsigned width, unsigned height, unsigned radius);
void gfx_FillRoundRectangle(int x, int y, unsigned width, unsigned height, unsigned radius);
void gfx_FillRoundRectangle_NoClip(uint24_t x, uint8_t y, unsigned width, unsigned height, unsigned radius);

/**
 * Draws a filled circle measured from the top left origin.
 */
void gfx_Circle(int x, int y, unsigned radius);
void gfx_Circle_NoClip(uint24_t x, uint8_t y, uint8_t radius);
void gfx_FillCircle(int x, int y, unsigned radius);
void gfx_FillCircle_NoClip(uint24_t x, uint8_t y, uint8_t radius);


/**
 * Draws an arc measured from the top left origin
 */
void gfx_Arc(int x, int y, unsigned width, unsigned height, int start_angle, int end_angle);
void gfx_Arc_NoClip(uint24_t x, uint8_t y, uint24_t width, uint24_t height, int24_t start_angle, int24_t end_angle);
void gfx_FillArc(int x, int y, unsigned width, unsigned height, int start_angle, int end_angle);
void gfx_FillArc_NoClip(uint24_t x, uint8_t y, uint24_t width, uint24_t height, int24_t start_angle, int24_t end_angle);

/**
 * Draws a triangle measured from the top left origin
 */
void gfx_Triangle(int *points);
void gfx_Triangle_NoClip(int *points);
void gfx_FillTriangle(int *points);
void gfx_FillTriangle_NoClip(int *points);

/**
 * Forces all graphics routines to write to either the offscreen buffer or the screen
 */
void gfx_SetDrawState(uint8_t buffer);
#define gfx_screen 0
#define gfx_buffer 1
#define gfx_DrawToBuffer() gfx_SetDrawState(gfx_buffer)
#define gfx_DrawToScreen() gfx_SetDrawState(gfx_screen)

/**
 * Swaps the buffer with the visible screen and vice versa.
 * The current drawing location remains the same.
 */
void gfx_SwapDraw(void);

/**
 * Copies the input buffer to the opposite buffer
 * Arguments:
 *  gfx_screen: copies screen to buffer
 *  gfx_buffer: copies buffer to screen
 */
void gfx_Blit(uint8_t buffer);
void gfx_BlitLines(uint8_t buffer, uint8_t y_loc, uint8_t num_lines);
void gfx_BlitArea(uint8_t buffer, uint24_t x, uint8_t y, uint24_t width, uint24_t height);
// Blit rectangular area ?

/**
 * Returns false if graphics routines are currently drawing to visible screen
 * The current drawing location remains the same.
 */
uint8_t gfx_GetDrawState(void);

/**
 * Outputs a character at the current cursor position
 * No text clipping is performed.
 */
void gfx_PrintChar(const char c);

/**
 * Outputs a signed integer at the current cursor position.
 * No text clipping is performed.
 * Values range from: (-8388608 - 8388607)
 * length must be between 0-8
 */
void gfx_PrintInt(int n, uint8_t length);

/**
 * Outputs an unsigned integer at the current cursor position.
 * No text clipping is performed.
 * Values range from: (0-16777215)
 * length must be between 0-8
 */
void gfx_PrintUInt(unsigned n, uint8_t length);

/**
 * Outputs a string at the current cursor position
 * No text clipping is performed.
 */
void gfx_PrintString(const char *string);

/**
 * Outputs a string at the given XY coordinates measured from the top left origin.
 * The current cursor position is updated.
 * No text clipping is performed.
 */
void gfx_PrintStringXY(const char *string, uint24_t x, uint8_t y);

/**
 * Returns the current text cursor X position
 */
uint24_t gfx_GetTextX(void);

/**
 * Returns the current text cursor Y position
 */
uint8_t gfx_GetTextY(void);

/**
 * Sets the text cursor XY position
 */
void gfx_SetTextXY(uint24_t x, uint8_t y);

/**
 * Sets the current text color.
 * Low 8 bits represent the foreground color.
 * High 8 bits represent the background color.
 * Returns previous text color
 */
uint8_t gfx_SetTextFGColor(uint8_t color);
uint8_t gfx_SetTextBGColor(uint8_t color);

/**
 * Draws a given sprite to the screen
 */
void gfx_Sprite(gfx_sprite_t *data, int x, int y); ///< int24_t, int24_t ?
void gfx_Sprite_NoClip(gfx_sprite_t *data, uint24_t x, uint8_t y);

/**
 * Draws a given sprite to the screen using transparency
 */
void gfx_TransparentSprite(gfx_sprite_t *data, int x, int y); ///< int24_t, int24_t ?
void gfx_TransparentSprite_NoClip(gfx_sprite_t *data, uint24_t x, uint8_t y);

/**
 * Quickly grab the background behind a sprite (useful for transparency)
 * sprite_buffer must be pointing to a large enough buffer to hold width*height number of bytes
 * A pointer to sprite_buffer is also returned for ease of use.
 * sprite_buffer is updated with the screen coordinates given.
 */
gfx_sprite_t *gfx_GetSprite_NoClip(gfx_sprite_t *sprite_buffer, uint24_t x, uint8_t y);
#define gfx_GetSprite gfx_GetSprite_NoClip

/**
 * Unclipped scaled sprite routines
 * Scaling factors must be greater than or equal to 1, and an integer factor
 * Useable with gfx_GetSprite in order to create clipped versions
 */
void gfx_ScaledSprite_NoClip(gfx_sprite_t *data, int24_t x, int24_t y, uint8_t width_scale, uint8_t height_scale);
void gfx_ScaledTransparentSprite_NoClip(gfx_sprite_t *data, int24_t x, int24_t y, uint8_t width_scale, uint8_t height_scale);

/**
 * Sprite flipping and rotating routines
 * sprite_in and sprite_out cannot be the same buffer
 * sprite_out must be as large as sprite_in
 * Returns a pointer to sprite_out
 */
gfx_sprite_t *gfx_FlipSpriteX(gfx_sprite_t *sprite_in, gfx_sprite_t *sprite_out);
gfx_sprite_t *gfx_FlipSpriteY(gfx_sprite_t *sprite_in, gfx_sprite_t *sprite_out);
gfx_sprite_t *gfx_FlipSpriteDiag(gfx_sprite_t *sprite_in, gfx_sprite_t *sprite_out);
gfx_sprite_t *gfx_FlipSpriteOffDiag(gfx_sprite_t *sprite_in, gfx_sprite_t *sprite_out);
gfx_sprite_t *gfx_RotateSpriteC(gfx_sprite_t *sprite_in, gfx_sprite_t *sprite_out);
gfx_sprite_t *gfx_RotateSpriteCC(gfx_sprite_t *sprite_in, gfx_sprite_t *sprite_out);
gfx_sprite_t *gfx_RotateSpriteHalf(gfx_sprite_t *sprite_in, gfx_sprite_t *sprite_out);

/**
 * Set the font routines to use the provided font, formated 8x8
 */
void gfx_SetFontData(uint8_t *fontdata);

/**
 * Set the font routines to use the provided font spacing
 */
void gfx_SetFontSpacing(uint8_t *fontspacing);

/**
 * To disable monospaced font, gfx_SetFontMonospace(0)
 * Otherwise, send the width int pixels you wish all characters to be
 */
void gfx_SetMonospaceFont(uint8_t monospace);

/**
 * Returns the width of the input string
 * Takes into account monospacing flag
 */
unsigned int gfx_GetStringWidth(const char *string);

/**
 * Returns the width of the character
 * Takes into account monospacing flag
 */
unsigned int gfx_GetCharWidth(const char c);
#define gfx_GetCharHeight(c) 8
#define gfx_FontHeight() 8

/**
 * Sets the clipping window for clipped routines
 * This routine is inclusive
 */
void gfx_SetClipRegion(int xmin, int ymin, int xmax, int ymax); ///< Do negative values make sense ?

/**
 * Clips an arbitrary region to fit within the defined bounds
 * Returns false if offscreen, true if onscreen
 */
bool gfx_GetClipRegion(gfx_region_t *region);

/**
 * Screen shifting routines that operate within the clipping window
 * Note that the data left over is undefined (Must be drawn over)
 */
void gfx_ShiftDown(uint24_t pixels);
void gfx_ShiftUp(uint24_t pixels);
void gfx_ShiftLeft(uint24_t pixels);
void gfx_ShiftRight(uint24_t pixels);

/**
 * Produces a random integer value
 */
#define gfx_RandInt(min, max) ((unsigned)rand() % ((max) - (min) + 1) + (min))

/**
 * Checks if we are currently in a rectangular hotspot area
 */
#define gfx_CheckRectangleHotspot(master_x, master_y, master_width, master_height, test_x, test_y, test_width, test_height) \
	   (((test_x) < ((master_x) + (master_width))) && \
	   (((test_x) + (test_width)) > (master_x)) && \
	   ((test_y) < ((master_y) + (master_height))) && \
	   (((test_y) + (test_height)) > (master_y)))

/**
 * Converts an RGB value to a palette color
 * Conversion is not 100% perfect, but is quite close
 */
#define gfx_RGBTo1555(r,g,b)	((uint16_t)(((uint8_t)(r) >> 3) << 10) | \
				(((uint8_t)(g) >> 3) << 5) | \
				((uint8_t)(b) >> 3))

#define gfx_lcdWidth		320
#define gfx_lcdHeight		240

/**
 * Some simple color definitions using the standard palette
 */
#define gfx_black	0x00
#define gfx_red		0xE0
#define gfx_orange	0xE3
#define gfx_green	0x03
#define gfx_blue	0x10
#define gfx_purple	0x50
#define gfx_pink	0xF0

#endif
