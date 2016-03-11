#include "..\..\..\include\relocation.inc"
#include "ti84pce.inc"

 .libraryName		"GRAPHC"	                ; Name of library
 .libraryVersion	3		                    ; Version information (1-255)
 
;-------------------------------------------------------------------------------
; v1 functions -- No longer able to insert or move (Can optimize/fix though)
;-------------------------------------------------------------------------------
 .function "gc_InitGraph",_InitGraph
 .function "gc_CloseGraph",_CloseGraph
 .function "gc_SetColorIndex",_SetColorIndex
 .function "gc_SetDefaultPalette",_SetDefaultPalette
 .function "gc_SetPalette",_SetPalette
 .function "gc_FillScrn",_FillScrn
 .function "gc_ClipSetPixel",_ClipSetPixel
 .function "gc_ClipGetPixel",_ClipGetPixel
 .function "gc_GetColor",_GetColor
 .function "gc_SetColor",_SetColor
 .function "gc_NoClipLine",_NoClipLine
 .function "gc_NoClipRectangle",_NoClipRectangle
 .function "gc_NoClipRectangleOutline",_NoClipRectangleOutline
 .function "gc_NoClipHorizLine",_NoClipHorizLine
 .function "gc_NoClipVertLine",_NoClipVertLine
 .function "gc_NoClipCircle",_NoClipCircle
 .function "gc_ClipCircleOutline",_ClipCircleOutline
 .function "gc_DrawBuffer",_DrawBuffer
 .function "gc_DrawScreen",_DrawScreen
 .function "gc_SwapDraw",_SwapDraw
 .function "gc_DrawState",_DrawState
 .function "gc_PrintChar",_PrintChar
 .function "gc_PrintInt",_PrintInt
 .function "gc_PrintUnsignedInt",_PrintUnsignedInt
 .function "gc_PrintString",_PrintString
 .function "gc_PrintStringXY",_PrintStringXY
 .function "gc_StringWidth",_StringWidthC
 .function "gc_CharWidth",_CharWidth
 .function "gc_TextX",_TextX
 .function "gc_TextY",_TextY
 .function "gc_SetTextXY",_SetTextXY
 .function "gc_SetTextColor",_SetTextColor
 .function "gc_SetTransparentColor",_SetTransparentColor
 .function "gc_NoClipDrawSprite",_NoClipDrawSprite
 .function "gc_NoClipDrawTransparentSprite",_NoClipDrawTransparentSprite
 .function "gc_NoClipGetSprite",_NoClipGetSprite
 .function "gc_SetCustomFontData",_SetCustomFontData
 .function "gc_SetCustomFontSpacing",_SetCustomFontSpacing
 .function "gc_SetFontMonospace",_SetFontMonospace
;-------------------------------------------------------------------------------
; v2 functions
;-------------------------------------------------------------------------------
 .function "gc_SetClipWindow",_SetClipWindow
 .function "gc_ClipRegion",_ClipRegion
 .function "gc_ShiftWindowDown",_ShiftWindowDown
 .function "gc_ShiftWindowUp",_ShiftWindowUp
 .function "gc_ShiftWindowLeft",_ShiftWindowLeft
 .function "gc_ShiftWindowRight",_ShiftWindowRight
 .function "gc_ClipRectangle",_ClipRectangle
 .function "gc_ClipRectangleOutline",_ClipRectangleOutline
 .function "gc_ClipHorizLine",_ClipHorizLine
 .function "gc_ClipVertLine",_ClipVertLine
 .function "gc_ClipDrawSprite",_ClipDrawSprite
 .function "gc_ClipDrawTransparentSprite",_ClipDrawTransparentSprite
 .function "gc_NoClipDrawScaledSprite",_NoClipDrawScaledSprite
 .function "gc_NoClipDrawScaledTransparentSprite",_NoClipDrawScaledTransparentSprite
;-------------------------------------------------------------------------------

 .beginDependencies
 .endDependencies
 
;-------------------------------------------------------------------------------
; Used throughout the library
lcdSize                 equ lcdWidth*lcdHeight
currentDrawingBuffer    equ mpLcdCursorImg+1024-3
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
_SetClipWindow:
; Sets the clipping window for clipped routines
; Arguments:
;  __frame_arg0 : Xmin
;  __frame_arg1 : Ymin
;  __frame_arg2 : Xmax
;  __frame_arg3 : Ymax
;  Must be within (0,0,319,239)
; Returns:
;  None
	call	_SetFullScreenClipping_ASM \.r
	push	ix
	ld	ix,6
	add	ix,sp
	call	_ClipRectangularRegion_ASM \.r
	lea	hl,ix
	pop	ix
	ret	c
	ld	de,_xmin \.r
	ld	bc,12
	ldir
	ret

;-------------------------------------------------------------------------------
_SetColorIndex:
; Sets the global color index for all routines
; Arguments:
;  __frame_arg0 : Color Index
; Returns:
;  Previous global color index
	pop	hl
	pop	de
	push	de
	push	hl
	ld	a,(color1) \.r
	ld	d,a
	ld	a,e
	ld	(color1),a \.r
	ld	(color2),a \.r
	ld	(color3),a \.r
	ld	(color4),a \.r
	ld	(color5),a \.r
	ld	(color6),a \.r
	ld	(color7),a \.r
	ld	a,d
	ret

;-------------------------------------------------------------------------------
_InitGraph:
; Sets up the graphics canvas (8bpp, default palette)
; Arguments:
;  None
; Returns:
;  None
	call	$000374
	call	_SetFullScreenClipping_ASM \.r
	ld	hl,currentDrawingBuffer
	ld	a,lcdBpp8
_:	ld	de,vRam
	ld	(hl),de
	ld	hl,mpLcdCtrl
	ld	(hl),a
	ld	l,mpLcdIcr&$FF
	ld	(hl),4
	jr	_SetDefaultPalette
 
;-------------------------------------------------------------------------------
_CloseGraph:
; Closes the graphics library and sets up for the TI-OS
; Arguments:
;  None
; Returns:
;  None
	ld	hl,mpLcdBase
	ld	a,lcdBpp16
	jr	-_
 
;-------------------------------------------------------------------------------
_SetDefaultPalette:
; Sets up the default palette where H=L
; Arguments:
;  None
; Returns:
;  None
	ld	de,mpLcdPalette
	ld	b,e
_:	ld	a,b
	rrca
	xor	a,b
	and	a,%11100000
	xor	a,b
	ld	(de),a
	inc	de
	ld	a,b
	rra
	ld	(de),a
	inc	de
	inc	b
	jr	nz,-_
	ret
 
;-------------------------------------------------------------------------------
_FillScrn:
; Fills the screen with the specified color index
; Arguments:
;  __frame_arg0 : Color Index
; Returns:
;  None
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a,c
	ld	bc,lcdSize
	ld	hl,(currentDrawingBuffer)
	jp	_memset
	
;-------------------------------------------------------------------------------
_SetPalette:
; Sets the palette starting at 0x00 index and onward
; Arguments:
;  __frame_arg0 : Pointer to palette
;  __frame_arg1 : Size of palette in bytes
; Returns:
;  None
	pop	de
	pop	hl
	pop	bc
	push	bc
	push	hl
	push	de
	ld	de,mpLcdPalette
	ldir
	ret

;-------------------------------------------------------------------------------
_GetColor:
; Gets the color of a given pallete entry
; Arguments:
;  __frame_arg0 : Color index
; Returns:
;  16 bit color palette entry
	ld	hl,3
	add	hl,sp
	ld	de,mpLcdPalette/2
	ld	e,(hl)
	ex	de,hl
	add	hl,hl
	ld	hl,(hl)
	ret
 
;-------------------------------------------------------------------------------
_SetColor:
; Sets the color of a given pallete entry
; Arguments:
;  __frame_arg0 : Palette index
;  __frame_arg1 : 1555 color entry
; Returns:
;  None
	ld	hl,3
	add	hl,sp
	ld	de,mpLcdPalette/2
	ld	e,(hl)
	inc	hl
	inc	hl
	inc	hl
	ex	de,hl
	add	hl,hl
	ex	de,hl
	ldi
	ldi
	ret

;-------------------------------------------------------------------------------
_ClipGetPixel:
; Gets the color index of a pixel
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
; Returns:
;  Color index of X,Y Coord
	pop	hl
	pop	bc
	pop	de
	push	de
	push	bc
	push	hl
	xor	a,a
getPixel_ASM:
	call	_PixelPtr_ASM \.r
	ret	c
	ld	a,(hl)
	ret

;-------------------------------------------------------------------------------
; Sets the color pixel to the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
; Returns:
;  None
_ClipSetPixel:
	pop	hl
	pop	bc
	pop	de
	push	de
	push	bc
	push	hl
_ClipSetPixel_ASM:
	call	_PixelPtr_ASM \.r
	ret	c
color1 =$+1
	ld	(hl),0
	ret

;-------------------------------------------------------------------------------
_ClipRectangle:
; Draws an unclipped rectangle with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Width
;  __frame_arg3 : Height
; Returns:
;  None
	push	ix
	ld	ix,6
	add	ix,sp
	ld	hl,(ix+6)
	ld	de,(ix)
	add	hl,de
	ld	(ix+6),hl
	ld	hl,(ix+9)
	ld	de,(ix+3)
	add	hl,de
	ld	(ix+9),hl
	call	_ClipRectangularRegion_ASM \.r
	jp	c,_ReturnRestoreIX_ASM \.r
	ld	de,(ix)
	push	de
	ld	hl,(ix+6)
	or	a,a
	sbc	hl,de
	ld	b,h
	ld	c,l
	ld	de,(ix+3)
	ld	hl,(ix+9)
	or	a,a
	sbc	hl,de
	ld	a,l
	pop	hl
	pop	ix
	jp	_NoClipRectangle_ASM \.r

;-------------------------------------------------------------------------------
_NoClipRectangle:
; Draws an unclipped rectangle with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Width
;  __frame_arg3 : Height
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)
	ld	e,(ix+__frame_arg1)
	ld	bc,(ix+__frame_arg2)
	ld	a,(ix+__frame_arg3)
	or	a,a
	pop	ix
	ret	z
	cp	240
	ret	nc
_NoClipRectangle_ASM:
	ld	d,lcdWidth/2
	mlt	de
	add.s	hl,de
	add	hl,de
	ld	de,(currentDrawingBuffer)
	add	hl,de
	dec.s	bc
	ret	c
FillRectangle_Loop:
color2 =$+1
	ld	(hl),0
	push	hl
	pop	de
	inc	de
	push	bc
	ldir
	pop	bc
	ld	de,lcdWidth
	add	hl,de
	sbc	hl,bc
	dec	a
	jr	nz,FillRectangle_Loop
	ret
 
;-------------------------------------------------------------------------------
_ClipRectangleOutline:
; Draws an unclipped rectangle outline with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Width
;  __frame_arg3 : Height
; Returns:
;  None
; Comments:
;  Because I am lazy, I'm just going to send it to the clipped line routines
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)
	ld	de,(ix+__frame_arg1)
	ld	bc,(ix+__frame_arg2)
	pop	ix
	push	bc
	push	de
	push	hl
	call	_ClipHorizLine \.r
	pop	hl
	pop	de
	pop	bc
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)
	ld	de,(ix+__frame_arg1)
	ld	bc,(ix+__frame_arg3)
	pop	ix
	push	bc
	push	de
	push	hl
	call	_ClipVertLine \.r
	pop	hl
	pop	de
	pop	bc
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)
	ld	de,(ix+__frame_arg1)
	ld	bc,(ix+__frame_arg2)
	add	hl,bc
	dec	hl
	ld	bc,(ix+__frame_arg3)
	pop	ix
	push	bc
	push	de
	push	hl
	call	_ClipVertLine \.r
	pop	hl
	pop	de
	pop	bc
	push	ix
	ld	ix,0
	add	ix,sp
	ld	de,(ix+__frame_arg0)
	ld	hl,(ix+__frame_arg1)
	ld	bc,(ix+__frame_arg3)
	add	hl,bc
	dec	hl
	ld	bc,(ix+__frame_arg2)
	pop	ix
	push	bc
	push	hl
	push	de
	call	_ClipHorizLine \.r
	pop	de
	pop	hl
	pop	bc
	ret
	
;-------------------------------------------------------------------------------
_NoClipRectangleOutline:
; Draws an unclipped rectangle outline with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Width
;  __frame_arg3 : Height
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)
	ld	e,(ix+__frame_arg1)
	ld	bc,(ix+__frame_arg2)
	ld	d,(ix+__frame_arg3)
	pop	ix
	push	bc
	push	hl
	push	de
	call	_RectOutlineHoriz_ASM \.r
	pop	bc
	push	bc
	call	_RectOutlineVert_ASM \.r
	pop	bc
	pop	hl
	ld	e, c
	call	_RectOutlineVert_ASM_2 \.r
	pop	bc
	inc	bc
	dec.s	bc
	jp	_MemSet_ASM \.r
	
;-------------------------------------------------------------------------------
_ClipHorizLine:
; Draws an clipped horizontal line with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Length
; Returns:
;  None
	push	ix
	ld	ix,6
	add	ix,sp
	ld	de,(_ymin) \.r
	ld	hl,(ix+3)
	call	_SignedCompare_ASM \.r
	jp	c,_ReturnRestoreIX_ASM \.r
	ld	hl,(_ymax) \.r
	ld	de,(ix+3)
	dec	hl
	call	_SignedCompare_ASM \.r
	jp	c,_ReturnRestoreIX_ASM \.r
	ld	hl,(ix+6)
	ld	de,(ix)
	add	hl,de
	ld	(ix+6),hl
	ld	hl,(_xmin) \.r
	call	_Max_ASM \.r
	ld	(ix),hl
	ld	hl,(_xmax) \.r
	ld	de,(ix+6)
	call	_Min_ASM \.r
	ld	(ix+6),hl
	ld	de,(ix)
	call	_SignedCompare_ASM \.r
	jp	c,_ReturnRestoreIX_ASM \.r
	ld	de,(ix)
	push	de
	ld	hl,(ix+6)
	or	a,a
	sbc	hl,de
	ld	b,h
	ld	c,l
	ld	e,(ix+3)
	pop	hl
	pop	ix
	jr	_RectOutlineHoriz_ASM
	
;-------------------------------------------------------------------------------
_NoClipHorizLine:
; Draws an unclipped horizontal line with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Length
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)
	ld	e,(ix+__frame_arg1)
	ld	bc,(ix+__frame_arg2)
	pop	ix
_RectOutlineHoriz_ASM:
	inc	bc
	dec.s	bc
	ld	a,b
	or	a,c
	ret	z
	ld	d,lcdWidth/2
	mlt	de
	add.s	hl,de
	add	hl,de
	ld	de,(currentDrawingBuffer)
	add	hl,de
color3 =$+1
	ld	a,0
_MemSet_ASM:
	ld	(hl),a
	push	hl
	cpi
	ex	de,hl
	pop	hl
	ret	po
	ldir
	ret
 
;-------------------------------------------------------------------------------
_ClipVertLine:
; Draws an clipped horizontal line with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Length
; Returns:
;  None
	push	ix
	ld	ix,6
	add	ix,sp
	ld	hl,(_xmax) \.r
	ld	de,(ix)
	push	de
	dec	de
	call	_SignedCompare_ASM \.r
	pop	hl
	jp	c,_ReturnRestoreIX_ASM \.r
	ld	de,(_xmin) \.r
	call	_SignedCompare_ASM \.r
	jp	c,_ReturnRestoreIX_ASM \.r
	ld	hl,(ix+6)
	ld	de,(ix+3)
	add	hl,de
	ld	(ix+6),hl
	ld	hl,(_ymin) \.r
	call	_Max_ASM \.r
	ld	(ix+3),hl
	ld	hl,(_ymax) \.r
	ld	de,(ix+6)
	call	_Min_ASM \.r
	ld	(ix+6),hl
	ld	de,(ix+3)
	call	_SignedCompare_ASM \.r
	jp	c,_ReturnRestoreIX_ASM \.r
	ld	hl,(ix+6)
	ld	de,(ix+3)
	or	a,a
	sbc	hl,de
	ld	b,l
	inc	b
	ld	hl,(ix)
	pop	ix
	jr	_RectOutlineVert_ASM_2

;-------------------------------------------------------------------------------
_NoClipVertLine:
; Draws an unclipped vertical line with the global color index
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Length
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)		; x
	ld	e,(ix+__frame_arg1)		; y
	ld	b,(ix+__frame_arg2)		; length
	pop	ix
_RectOutlineVert_ASM_2:
	dec	b
	ret	z
	ld	d,lcdWidth/2
	mlt	de
	add.s	hl,de
	add	hl,de
	ld	de,(currentDrawingBuffer)
	add	hl,de
_RectOutlineVert_ASM:
	ld	de,lcdWidth
color4 =$+1
_:	ld	(hl),0
	add	hl,de
	djnz	-_
	ret
 
;-------------------------------------------------------------------------------
_DrawBuffer:
; Forces drawing routines to operate on the offscreen buffer
; Arguments:
;  None
; Returns:
;  None
	ld	hl,(mpLcdBase)
	ld	de,vRam
	or	a,a 
	sbc	hl,de
	jr	nz,++_
_:	ld	de,vRam+lcdSize
_:	ld	(currentDrawingBuffer),de
	ret

;-------------------------------------------------------------------------------
_DrawScreen:
; Forces drawing routines to operate on the visible screen
; Arguments:
;  None
; Returns:
;  None
	ld	hl,(mpLcdBase)
	ld	de,vRam
	or	a,a
	sbc	hl,de
	jr	z,-_
	jr	--_
 
;-------------------------------------------------------------------------------
_SwapDraw:
; Safely swap the vRam buffer pointers for double buffered output
; Arguments:
;  None
; Returns:
;  None
	ld	hl,vRAM
	ld	de,(mpLcdBase)
	or	a,a
	sbc	hl,de
	add	hl,de
	jr	nz,+_
	ld	hl,vRAM+lcdSize
_:	ld	(currentDrawingBuffer),de
	ld	(mpLcdBase),hl
	ld	hl,mpLcdIcr
	set	2,(hl)
	ld	hl,mpLcdRis
_:	bit	2,(hl)
	jr	z,-_
	ret
 
;-------------------------------------------------------------------------------
_DrawState:
; Gets the current drawing state
; Arguments:
;  None
; Returns:
;  Returns 0 if drawing on the visible screen
	ld	hl,(currentDrawingBuffer)
	ld	de,(mpLcdBase)
	xor	a,a
	sbc	hl,de
	ret	z
	inc	a
	ret
 
;-------------------------------------------------------------------------------
_SetTransparentColor:
; Sets the transparency color for routines
; Arguments:
;  __frame_arg0 : Transparent color index
; Returns:
;  Previous transparent color index
	pop	hl
	pop	de
	push	de
	ld	a,(TransparentTextColor) \.r
	ld	d,a
	ld	a,e
	ld	(TransparentTextColor),a \.r
	ld	(NoClipSprTransColor),a \.r
	ld	(ClipSprTransColor),a \.r
	ld	(ClipSprScaledTransColor),a \.r
	ld	a,d
	jp	(hl)
 
;-------------------------------------------------------------------------------
_ClipCircleOutline:
; Draws a clipped circle outline
; Note: Disables interrupts
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Radius
; Returns:
;  None
	di
	push	ix
	ld	ix,0
	add	ix,sp
	ld	de,(ix+__frame_arg0)
	ld	hl,(ix+__frame_arg1)
	ex.s	de,hl
	ld	d,0
	ld	bc,(ix+__frame_arg2)
	dec	bc
	inc.s	bc
	push	hl
	push	de
	exx
	pop	de
	pop	hl
	exx
	push	bc
	push	bc
	pop	de
	pop	hl
	add	hl,hl
	push	hl
	pop	bc
	ld	hl,3
	or	a,a
	sbc	hl,bc
	push	hl
	pop	ix
	or	a,a
	sbc	hl,hl
drawCircle_Loop:
	or	a,a
	sbc	hl,de
	add	hl,de
	jp	nc,_ReturnRestoreIX_ASM \.r
	ld	c,ixh
	bit	7,c
	jr	z,_dc_else
	push	hl
	add	hl,hl
	add 	hl,hl
	ld	bc,6
	add	hl,bc
	push	hl 
	pop	bc
	add	ix,bc
	pop	hl
	jr	_dc_end
_dc_else:
	push	hl
	or	a,a
	sbc	hl,de
	add	hl,hl
	add	hl,hl
	ld	bc,10
	add	hl,bc
	push	hl
	pop	bc
	add	ix,bc
	pop	hl
	dec	de
_dc_end: 
	call	drawCircleSection \.r
	inc	hl
	jr	drawCircle_Loop

drawCircleSection: 
	call	drawCirclePoints \.r
	ex	de,hl
	call	drawCirclePoints \.r
	ex	de,hl
	ret
drawCirclePoints: 
	push	hl
	exx
	pop	bc
	push	hl
	add	hl,bc
	exx
	push	de
	exx
	pop	bc
	ex	de,hl
	push	hl
	add	hl,bc
	ex	de,hl
	call	_DrawPixelCircle_ASM \.r
	pop	de
	pop	hl
	exx
	push	hl
	exx
	pop	bc
	push	hl
	or	a,a
	sbc	hl,bc
	exx
	push	de
	exx
	pop	bc
	ex	de,hl
	push	hl
	add	hl,bc
	ex	de,hl
	call	_DrawPixelCircle_ASM \.r
	pop	de
	pop	hl
	exx
	push	hl
	exx
	pop	bc
	push	hl
	add	hl,bc
	exx
	push	de
	exx
	pop	bc
	ex	de,hl
	push	hl
	or	a,a
	sbc	hl,bc
	ex	de,hl
	call	_DrawPixelCircle_ASM \.r
	pop	de
	pop	hl
	exx
	push	hl
	exx
	pop	bc
	push	hl
	or	a,a
	sbc	hl,bc
	exx
	push	de
	exx
	pop	bc
	ex 	de,hl
	push	hl
	or	a,a
	sbc	hl,bc
	ex	de,hl
	call	_DrawPixelCircle_ASM \.r
	pop	de
	pop	hl
	exx
	ret

_DrawPixelCircle_ASM:
	bit	7,h
	ret	nz
	bit	7,d
	ret	nz
	push	bc
	ld	bc,lcdWidth
	or	a,a
	sbc	hl,bc
	add	hl,bc
	pop	bc
	ret	nc
	ex	de,hl
	push	bc
	ld	bc,lcdHeight
	or	a,a
	sbc	hl,bc
	add	hl,bc
	pop	bc
	ret	nc
	ld	h,lcdWidth/2 
	mlt	hl
	add	hl,hl
	add	hl,de
	ld	de,(currentDrawingBuffer)
	add	hl,de
color5 =$+1
	ld	(hl),0
	ret

;-------------------------------------------------------------------------------
_NoClipCircle:
; Draws an unclipped circle
; Note: Disables interrupts
; Arguments:
;  __frame_arg0 : X Coord
;  __frame_arg1 : Y Coord
;  __frame_arg2 : Radius
; Returns:
;  None
	di
	push	ix
	ld	ix,0
	add	ix,sp
	ld	de,(ix+__frame_arg0)
	ld	hl,(ix+__frame_arg1)
	ex.s	de,hl
	ld	d,0
	ld	bc,(ix+__frame_arg2)
	dec	bc
	inc.s	bc
	push	hl
	push	de
	exx
	pop	de
	pop	hl
	exx
	ld	e,c
	ld	d,b
	ld	l,c
	ld	h,b
	add	hl,hl
	ld	c,l
	ld	b,h
	ld	hl,3
	or	a,a
	sbc	hl,bc
	push	hl
	pop	ix
	or	a,a
	sbc	hl,hl
drawFilledCircle_Loop:
	or	a,a
	sbc	hl,de
	add	hl,de
	jp	nc,_ReturnRestoreIX_ASM \.r
	ld	a,ixh
	bit	7,a
	jr	z,_dfc_else
	push	hl
	add	hl,hl
	add	hl,hl
	ld	bc,6
	add	hl,bc
	ld	c,l
	ld	b,h
	add	ix,bc
	pop	hl
	jr	_dfc_end
_dfc_else:
	push	hl
	or	a,a
	sbc	hl,de
	add	hl,hl
	add	hl,hl
	ld	bc,10
	add	hl,bc
	ld	c,l
	ld	b,h
	add	ix,bc
	pop	hl
	dec	de
_dfc_end:
	call	drawFilledCircleSection \.r
	inc	hl
	jr	drawFilledCircle_Loop
	
drawFilledCircleSection:
	call	drawFilledCirclePoints \.r
	ex	de,hl
	call	drawFilledCirclePoints \.r
	ex	de,hl
	ret
drawFilledCirclePoints:
	push	ix
	push	hl
	push	de
	push	hl
	exx
	pop	bc
	push	hl
	or	a,a
	sbc	hl,bc
	push	hl
	add	hl,bc
	add	hl,bc
	push	hl
	pop	ix
	pop	hl
	exx
	push	de
	exx
	pop	bc
	push	de
	ex	de,hl
	add	hl,bc
	ex	de,hl
	push	de
	push	de
	pop	bc
	ex	de,hl
	push	ix
	pop	hl
	pop	ix
	push	bc
	ld	b,ixl
	call	_NoClipLine_ASM \.r
	pop	bc
	pop	de
	pop	hl
	exx
	pop	de
	pop	hl
	pop	ix
	push	ix
	push	hl
	push	de
	push	hl
	exx
	pop	bc
	push	hl
	or	a,a
	sbc	hl,bc
	push	hl
	add	hl,bc
	add	hl,bc
	push	hl
	pop	ix
	pop	hl
	exx
	push	de
	exx
	pop	bc
	push	de
	ex	de,hl
	or	a,a
	sbc	hl,bc
	ex	de,hl
	push	de
	push	de
	pop	bc
	ex	de,hl
	push	ix
	pop	hl
	pop	ix
	push	bc
	ld	b,ixl
	call	_NoClipLine_ASM \.r
	pop	bc
	pop	de
	pop	hl
	exx
	pop	de
	pop	hl
_ReturnRestoreIX_ASM:
	pop	ix
	ret

;-------------------------------------------------------------------------------
_NoClipLine:
; Draws an unclipped arbitrary line
; Arguments:
;  __frame_arg0 : X0 Coord
;  __frame_arg1 : Y0 Coord
;  __frame_arg2 : X1 Coord
;  __frame_arg3 : Y1 Coord
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg0)
	ld	de,(ix+__frame_arg2)
	ex.s	de,hl
	ld	b,(ix+__frame_arg1)
	ld	c,(ix+__frame_arg3)
	pop	ix
_NoClipLine_ASM:
	ld	a,c
	ld	(y1),a \.r
	push	de
	push	hl
	push	bc    
	or	a,a 
	sbc	hl,de 
	ld	a,$03 
	jr	nc,+_ 
	ld	a,$0B
_:	ld	(xStep),a \.r
	ld	(xStep2),a \.r
	ex	de,hl
	or	a,a 
	sbc	hl,hl
	sbc	hl,de
	jp	p,+_ \.r
	ex	de,hl
_:	ld	(dx),hl \.r
	push	hl
	add	hl,hl 
	ld	(dx1),hl \.r
	ld	(dx12),hl \.r
	or	a,a
	sbc	hl,hl
	ex	de,hl
	sbc	hl,hl
	ld	e,b
	ld	l,c
	or	a,a 
	sbc	hl,de
	ld	a,$3C
	jr	nc,+_
	inc	a
_:	ld	(yStep),a \.r
	ld	(yStep2),a \.r
	ex	de,hl 
	or	a,a 
	sbc	hl,hl 
	sbc	hl,de 
	jp	p,+_ \.r
	ex	de,hl
_:	ld	(dy),hl \.r
	push	hl
	add	hl,hl
	ld	(dy1),hl \.r
	ld	(dy12),hl \.r
	pop	hl
	pop	de
	pop	af
	or	a,a
	sbc	hl,de
	pop	de
	pop	bc
	ld	hl,0
	jr	nc,changeYLoop 
changeXLoop:
	push	hl 
	ld	l,a 
	ld	h,lcdWidth/2 
	mlt	hl
	add	hl,hl
	add	hl,bc
	push	bc
	ld	bc,(currentDrawingBuffer)
	add	hl,bc 
color6 =$+1
	ld	(hl),0
	pop	bc
	push	bc
	pop	hl
	or	a,a 
	sbc	hl,de 
	pop	hl 
	ret	z 
xStep:	nop
	push	de
dy1 =$+1 
	ld	de,0 
	or	a,a
	adc	hl,de
	jp	m,+_ \.r
dx =$+1
	ld	de,0
	or	a,a
	sbc	hl,de 
	add	hl,de 
	jr	c,+_
yStep: 	nop
dx1 =$+1 
	ld	de,0
	sbc	hl,de 
_:	pop	de
	jr	changeXLoop

changeYLoop:
	push	bc 
	push	hl
	ld	l,a 
	ld	h,lcdWidth/2 
	mlt	hl
	add	hl,hl 
	add	hl,bc 
	ld	bc,(currentDrawingBuffer)
	add	hl,bc 
color7 =$+1
	ld	(hl),0 
	pop	hl
	pop	bc
y1 =$+1
	cp	a,0
	ret	z
yStep2:	nop
	push	de
dx12 =$+1
	ld	de,0
	or	a,a
	adc	hl,de
	jp	m,+_ \.r
dy =$+1
	ld	de,0
	or	a,a
	sbc	hl,de
	add	hl,de
	jr	c,+_
xStep2:	nop
dy12 =$+1
	ld	de,0
	sbc	hl,de
_:	pop	de
	jr	changeYLoop
 
;-------------------------------------------------------------------------------
_StringWidthC:
; Gets the width of a string
; Arguments:
;  __frame_arg0 : Pointer to string
; Returns:
;  Width of string in pixels
	pop	de
	pop	hl
	push	hl
	push	de
	ld	bc,0
_:	ld	a,(hl)
	or	a,a
	jr	z,+_
	push	hl
	call	_CharWidth_ASM \.r
	pop	hl
	inc	hl
	jr	-_
_:	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------	
_CharWidth:
; Gets the width of a character
; Arguments:
;  __frame_arg0 : Character
; Returns:
;  Width of character in pixels
	pop	de
	pop	hl
	push	hl
	push	de
	ld	bc,0
	ld	a,l
_CharWidth_ASM:
	ld	l,a
	ld	a,(MonoFlag_ASM)
	or	a,a
	jr	nz,+_
	ld	a,l
	or	a,a
	sbc	hl,hl
	ld	l,a
	ld	de,(CharSpacing_ASM) \.r
	add	hl,de
	ld	a,(hl)
	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	push	hl
	pop	bc
	ret
_:	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	ret
 
;-------------------------------------------------------------------------------
_SetCustomFontData:
; Sets the font to be custom
; Arguments:
;  __frame_arg0 : Pointer to font data
;  Set Pointer to NULL to use default font
; Returns:
;  None
	pop	de
	pop	hl
	push	hl
	push	de
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz,+_
	ld	hl,Char000 \.r
_:	ld	(TextData_ASM),hl \.r
	ret

;-------------------------------------------------------------------------------
_SetCustomFontSpacing:
; Sets the font to be custom spacing
; Arguments:
;  __frame_arg0 : Pointer to font spacing
;  Set Pointer to NULL to use default font spacing
; Returns:
;  None
	pop	de
	pop	hl
	push	hl
	push	de
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz,+_
	ld	hl,DefaultCharSpacing_ASM \.r
_:	ld	(CharSpacing_ASM),hl \.r
	ret

 ;-------------------------------------------------------------------------------
_SetFontMonospace:
; Sets the font to be monospace
; Arguments:
;  __frame_arg0 : Monospace spacing amount
; Returns:
;  None
	pop	hl
	pop	de
	push	de
	push	hl
	ld	a,e
	ld	(MonoFlag_ASM),a \.r
	ret

;-------------------------------------------------------------------------------
_ShiftWindowDown:
; Shifts whatever is in the clip window down by some pixels
; Arguments:
;  __frame_arg0 : Amount to shift by
; Returns:
;  None
	call	_DownRightShiftCalculate_ASM \.r
	ex	de,hl
	ld	hl,3
	add	hl,sp
	ld	l,(hl)
	ld	h,lcdWidth/2
	mlt	hl
	add	hl,hl
	add	hl,de
	ex	de,hl
	jr	+_
;-------------------------------------------------------------------------------
_ShiftWindowRight:
; Shifts whatever is in the clip window right by some pixels
; Arguments:
;  __frame_arg0 : Amount to shift by
; Returns:
;  None
	call	_DownRightShiftCalculate_ASM \.r
	pop	de
	pop	bc
	push	bc
	push	de
	push	hl
	pop	de
	sbc	hl,bc
	dec	hl
	dec	de
	inc	a
XDeltaDownRight_ASM =$+1
_:	ld	bc,0
	lddr
PosOffsetDownRight_ASM =$+1
	ld	bc,0
	sbc	hl,bc
	ex	de,hl
	or	a,a
	sbc	hl,bc
	ex	de,hl
	dec	a
	jr	nz,-_
	ret
	
;-------------------------------------------------------------------------------
_ShiftWindowUp:
; Shifts whatever is in the clip window up by some pixels
; Arguments:
;  __frame_arg0 : Amount to shift by
; Returns:
;  None
	call	_UpLeftShiftCalculate_ASM \.r
	ex	de,hl
	ld	hl,3
	add	hl,sp
	ld	l,(hl)
	ld	h,lcdWidth/2
	mlt	hl
	add	hl,hl
	add	hl,de
	jr	+_
;-------------------------------------------------------------------------------
_ShiftWindowLeft:
; Shifts whatever is in the clip window left by some pixels
; Arguments:
;  __frame_arg0 : Amount to shift by
; Returns:
;  None
	call	_UpLeftShiftCalculate_ASM \.r
	pop	de
	pop	bc
	push	bc
	push	de
	push	hl
	pop	de
	add	hl,bc
	dec	hl
	dec	de
	inc	a
XDeltaUpLeft_ASM =$+1
_:	ld	bc,0
	ldir
PosOffsetUpLeft_ASM =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	dec	a
	jr	nz,-_
	ret

;-------------------------------------------------------------------------------
_ClipRegion:
; Arguments:
;  Pointer to struct
; Returns:
;  False if offscreen
	pop	hl
	ex	(sp),ix
	push	hl
	call	_ClipRectangularRegion_ASM
	sbc	a,a
	inc	a
	pop	hl
	ex	(sp),ix
	jp	(hl)

;-------------------------------------------------------------------------------
; Inner library routines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
_PixelPtr_ASM:
; Gets the address of a pixel
; Inputs:
;  BC=X
;   E=Y
; Outputs:
;  HL->address of pixel
	ld	hl,(_xmax)
	ld	hl,-lcdWidth
	add	hl,bc
	ret	c
	ld	hl,-lcdHeight
	add	hl,de
	ret	c
	ld	hl,(currentDrawingBuffer)
	add	hl,bc
	ld	d,lcdWidth/2
	mlt	de
	add	hl,de
	add	hl,de
	ret
 
;-------------------------------------------------------------------------------
_UpLeftShiftCalculate_ASM:
; Calcualtes the position to shift the window for up/left
; Inputs:
;  None
; Outputs:
;  HL->Place to draw
	ld	hl,(_xmax) \.r
	ld	de,(_xmin) \.r
	push	de
	or	a,a
	sbc	hl,de
	ld	(XDeltaUpLeft_ASM),hl \.r
	ex	de,hl
	ld	hl,lcdWidth
	or	a,a
	sbc	hl,de
	ld	(PosOffsetUpLeft_ASM),hl \.r
	ld	a,(_ymin) \.r
	ld	c,a
	ld	a,(_ymax) \.r
	ld	l,c
_:	sub	a,c
	ld	h,lcdwidth/2
	mlt	hl
	add	hl,hl
	pop	de
	add	hl,de
	ld	de,vRam
	add	hl,de
	ret
;-------------------------------------------------------------------------------
_DownRightShiftCalculate_ASM:
; Calcualtes the position to shift the window for dowm/right
; Inputs:
;  None
; Outputs:
;  HL->Place to draw
	ld	hl,(_xmax) \.r
	ld	de,(_xmin) \.r
	push	hl
	or	a,a
	sbc	hl,de
	ld	(XDeltaDownRight_ASM),hl \.r
	ex	de,hl
	ld	hl,lcdWidth
	or	a,a
	sbc	hl,de
	ld	(PosOffsetDownRight_ASM),hl \.r
	ld	a,(_ymin) \.r
	ld	c,a
	ld	a,(_ymax) \.r
	ld	l,a
	jr	-_
	
;-------------------------------------------------------------------------------
_Max_ASM:
; Calculate the resut of a signed comparison
; Inputs:
;  DE,HL=numbers
; Oututs:
;  HL=max number
	or	a,a
	sbc	hl,de
	add	hl,de
	jp	p,+_ \.r
	ret	pe
	ex	de,hl
_:	ret	po
	ex	de,hl
	ret
	
;-------------------------------------------------------------------------------
_Min_ASM:
; Calculate the resut of a signed comparison
; Inputs:
;  DE,HL=numbers
; Oututs:
;  HL=min number
	or	a,a
	sbc	hl,de
	ex	de,hl
	jp	p,_ \.r
	ret	pe
	add	hl,de
_:	ret	po
	add	hl,de
	ret

;-------------------------------------------------------------------------------
_ClipRectangularRegion_ASM:
; Calcualtes the new coordinates given the clip window and inputs
; Inputs:
;  None
; Outputs:
;  Modifies data registers
;  Sets C flag if offscreen
	ld	hl,(_xmin) \.r
	ld	de,(ix)
	call	_Max_ASM \.r
	ld	(ix),hl
	ld	hl,(_xmax) \.r
	ld	de,(ix+6)
	call	_Min_ASM \.r
	ld	(ix+6),hl
	ld	de,(ix)
	call	_SignedCompare_ASM \.r
	ret	c
	ld	hl,(_ymin) \.r
	ld	de,(ix+3)
	call	_Max_ASM \.r
	ld	(ix+3),hl
	ld	hl,(_ymax) \.r
	ld	de,(ix+9)
	call	_Min_ASM \.r
	ld	(ix+9),hl
	ld	de,(ix+3)
_SignedCompare_ASM:
	or	a,a
	sbc	hl,de
	add	hl,hl
	ret	po
	ccf	
	ret
	
;-------------------------------------------------------------------------------
_SetFullScreenClipping_ASM:
; Sets the clipping window to the entire screen
; Inputs:
;  None
; Outputs:
;  HL=0
	ld	hl,lcdWidth
	ld	(_xmax),hl \.r
	ld	hl,lcdHeight
	ld	(_ymax),hl \.r
	ld	l,0
	ld	(_xmin),hl \.r
	ld	(_ymin),hl \.r
	ret

#include "sprite_lib.asm"
#include "text_lib.asm"

;-------------------------------------------------------------------------------
; Inner library data
;-------------------------------------------------------------------------------
 
_xmin:
	.dl 0
_ymin:
	.dl 0
_xmax:
	.dl lcdWidth
_ymax:
	.dl lcdHeight

 .endLibrary