#include "..\..\..\include\relocation.inc"
#include "ti84pce.inc"

 .libraryName		"GRAPHC"	                    ; Name of library
 .libraryVersion	1		                    ; Version information (1-255)
 
 .function "gc_InitGraph",_InitGraph
 .function "gc_CloseGraph",_CloseGraph
 .function "gc_SetColorIndex",_SetColorIndex
 .function "gc_SetDefaultPalette",_SetDefaultPalette
 .function "gc_SetPalette",_SetPalette
 .function "gc_FillScrn",_FillScrn
 .function "gc_SetPixel",_SetPixel
 .function "gc_GetPixel",_GetPixel
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
 
 .beginDependencies
 .endDependencies
 
;-------------------------------------------------------------------------------
; used throughout the library
lcdsize			        equ lcdwidth*lcdhheight*2
currentDrawingBuffer	equ mpLcdBase+4
;-------------------------------------------------------------------------------

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
	ld	a,lcdbpp8
_:	ld	(mpLcdCtrl),a
	ld	hl,vRAM
	ld	(currentDrawingBuffer),hl
	jr	_SetDefaultPalette
 
;-------------------------------------------------------------------------------
_CloseGraph:
; Closes the graphics library and sets up for the TI-OS
; Arguments:
;  None
; Returns:
;  None
	call	$000374
	ld	hl,vRAM
	ld	(mpLcdBase),hl
	ld	a,lcdbpp16
	jr	-_

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
	ld	bc,lcdWidth*lcdHeight
	ld	hl,(currentDrawingBuffer)
	jp	_memset
 
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
_GetPixel:
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
_SetPixel:
	pop	hl
	pop	bc
	pop	de
	push	de
	push	bc
	push	hl
_SetPixel_ASM:
	call	_PixelPtr_ASM \.r
	ret	c
color1 =$+1
	ld	(hl),0
	ret

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
	ld	d,lcdWidth/2
	mlt	de
	add.s	hl,de
	add	hl,de
	ld	de,(currentDrawingBuffer)
	add	hl,de
	dec.s	bc
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
	pop	ix
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
	jr	_MemSet_ASM
 
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
_RectOUtlineHoriz_ASM:
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
	inc	b
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
	ld	de,vRAM
	or	a,a 
	sbc	hl,de
	jr	nz,++_
_:	ld	de,vRAM+(lcdWidth*lcdHeight)
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
	ld	de,vRAM
	or	a,a
	sbc	hl,de
	jr	z,-_
	jr	--_
 
;-------------------------------------------------------------------------------
_SwapDraw:
; Safely swap the vRAM buffer pointers for double buffered output
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
	ld	hl,vRAM+(lcdWidth*lcdHeight)
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
_TextX:
; Gets the X position of the text cursor
; Arguments:
;  None
; Returns:
;  X Text cursor posistion
	ld	hl,(TextXPos_ASM) \.r
	ret
	
;-------------------------------------------------------------------------------
_TextY:
; Gets the Y position of the text cursor
; Arguments:
;  None
; Returns:
;  Y Text cursor posistion
	ld	a,(TextYPos_ASM) \.r
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
	ld	(TransparentSpriteColor),a \.r
	ld	a,d
	jp	(hl)
 
;-------------------------------------------------------------------------------
_SetTextColor:
; Sets the transparency text color for text routines
; Arguments:
;  __frame_arg0 : High 8 bits is background, Low 8 bits is foreground
;  These refer to color palette indexes
; Returns:
;  Previous text color palette indexes
	pop	hl
	pop	de
	push	de
	push	hl
	ld	hl,(TextColor_ASM) \.r
	ld	(TextColor_ASM),de \.r
	ret

;-------------------------------------------------------------------------------
_SetTextXY:
; Sets the transparency text color for text routines
; Arguments:
;  __frame_arg0 : Text X Pos
;  __frame_arg1 : Text Y Pos
; Returns:
;  None
	ld	hl,3
	add	hl,sp
	ld	de,TextXPos_ASM \.r
	ldi
	ldi
	inc	hl
	ld	a,(hl)
	ld	(TextYPos_ASM),a \.r
	ret
 
;-------------------------------------------------------------------------------
_PrintStringXY:
; Places a string at the given coordinates
; Arguments:
;  __frame_arg0 : Pointer to string
;  __frame_arg1 : Text X Pos
;  __frame_arg2 : Text Y Pos
; Returns:
;  None
	ld	hl,9
	add	hl,sp
	ld	a,(hl)
	ld	(TextYPos_ASM),a \.r
	dec	hl
	dec	hl
	ld	de,TextXPos_ASM+1 \.r
	ldd
	ldd
	dec	hl
	dec	hl
	ld	hl,(hl)
	jr	+_
 
;-------------------------------------------------------------------------------
_PrintString:
; Places a string at the current cursor position
; Arguments:
;  __frame_arg0 : Pointer to string
; Returns:
;  None
	pop	de
	pop	hl
	push	hl
	push	de
_:	ld	a,(hl)
	or	a,a
	ret	z
	call	_PrintChar_ASM \.r
	inc	hl
	jr	-_

;-------------------------------------------------------------------------------
_PrintChar:
; Places a character at the current cursor position
; Arguments:
;  __frame_arg0 : Character to draw
; Returns:
;  None
	pop	hl
	pop	bc
	ld	a,c
	push	bc
	push	hl
_PrintChar_ASM:
	push hl
TextXPos_ASM = $+1
	ld	bc,0
	push	af
	push	af
	push	bc
	push	af
	ld	a,(MonoFlag_ASM) \.r
	or	a,a
	ld	a,8
	pop	de
	jr	z,+_
	or	a,a
	sbc	hl,hl
	ld	l,d
	ld	de,(CharSpacing_ASM) \.r
	add	hl,de
	ld	a,(hl)
	inc	a
_:	ld	(charwidth),a \.r
	or	a,a
	sbc	hl,hl
	ld	l,a
	neg
	ld	(CharWidthDelta_ASM),a \.r
	add	hl,bc
	ld	(TextXPos_ASM),hl \.r
CharWidthDelta_ASM =$+1
	ld	de,$FFFFFF
	ld	hl,lcdWidth
	add	hl,de
	ld	(line_change),hl \.r
TextYPos_ASM = $+1
	ld	l,0
	ld	h,lcdWidth/2
	mlt	hl
	add	hl,hl
	ld	de,(currentDrawingBuffer)
	add	hl,de
	pop	de
	add	hl,de
	pop	af
	ex	de,hl
	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	bc,(TextData_ASM) \.r
	add	hl,bc
	ld	b,8
iloop:	push	bc
	ld	c,(hl)
charwidth =$+1
	ld	b,0
	ex	de,hl
	push	de
TextColor_ASM =$+1
	ld	de,$FF00
cloop:	ld	a,d
	rlc	c
	jr	nc,+_
	ld	a,e
TransparentTextColor =$+1
_:	cp	a,$FF
	jr	nz,+_
	ld	a,(hl)
_:	ld	(hl),a
	inc	hl
	djnz	cloop
line_change =$+1
	ld	bc,0
	add	hl,bc
	pop	de
	ex	de,hl
	inc	hl
	pop	bc
	djnz	iloop
	pop	af
	pop	hl
	ret

;-------------------------------------------------------------------------------
_PrintUnsignedInt:
; Places an unsigned int at the current cursor position
; Arguments:
;  __frame_arg0 : Number to print
;  __frame_arg1 : Number of characters to print
; Returns:
;  None
	pop	de
	pop	hl
	pop	bc
	push	bc
	push	hl
	push	de
_outuint_ASM:
	ld	a,8
	sub	a,c
	ret	c
	ld	c,a
	ld	b,8
	mlt	bc
	ld	a,c
	ld	(offset0),a \.r
offset0 =$+1
	jr	$
	ld	bc,-10000000
	call	Num1 \.r
	ld	bc,-1000000
	call	Num1 \.r
	ld	bc,-100000
	call	Num1 \.r
	ld	bc,-10000
	call	Num1 \.r
	ld	bc,-1000
	call 	Num1 \.r
	ld	bc,-100
	call	Num1 \.r
	ld	bc,-10
	call	Num1 \.r
	ld	bc,-1
Num1:	ld	a,'0'-1
Num2:	inc	a
	add	hl,bc
	jr	c,Num2
	sbc	hl,bc
	jp	_PrintChar_ASM \.r
 
;-------------------------------------------------------------------------------
_PrintInt:
; Places an int at the current cursor position
; Arguments:
;  __frame_arg0 : Number to print
;  __frame_arg1 : Number of characters to print
; Returns:
;  None
	pop	de
	pop	hl
	pop	bc
	push	bc
	dec	bc
	inc.s	bc
	ld	b,0
	push	hl
	push	de
	call	_SetAtoHLU
	bit	7,a
	jr	z,IsntNegative
	push	bc
	push	hl
	pop	bc
	or	a,a
	sbc	hl,hl
	sbc	hl,bc
	ld	a,'-'
	call	_PrintChar_ASM \.r
	pop	bc
IsntNegative:
	jp	_outuint_ASM \.r

;-------------------------------------------------------------------------------
_NoClipDrawSprite:
; Places an sprite on the screen as fast as possible
; Arguments:
;  __frame_arg0 : Pointer to sprite
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width
;  __frame_arg4 : Height
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg1)               ; X
	ld	c,(ix+__frame_arg2)                ; Y
	ex.s	de,hl
	ld	hl,(currentDrawingBuffer)
	add	hl,de
	ld	b,lcdWidth/2
	mlt	bc
	add	hl,bc
	add	hl,bc
	ex	de,hl
	ld	hl,lcdWidth
	ld	bc,0
	ld	c,(ix+__frame_arg3)
	ld	a,c
	sbc	hl,bc
	ld	(NoClipSprMoveAmt),hl \.r
	ld	(NoClipSprLineNext),a \.r
	ld	b,(ix+__frame_arg4)
	ld	hl,(ix+__frame_arg0)
	pop	ix
_:	push	bc
NoClipSprLineNext =$+1
	ld	bc,0
	ldir
	ex	de,hl
NoClipSprMoveAmt =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
	pop	bc
	djnz	-_
	ret
 
;-------------------------------------------------------------------------------
_NoClipGetSprite:
; Grabs the data from the current draw buffer and stores it in another buffer
; Arguments:
;  __frame_arg0 : Pointer to storage buffer
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width
;  __frame_arg4 : Height
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg1)
	ld	c,(ix+__frame_arg2)
	ex.s	de,hl
	ld	hl,(currentDrawingBuffer)
	add	hl,de
	ld	b,lcdWidth/2
	mlt	bc
	add	hl,bc
	add	hl,bc
	ex	de,hl
	ld	hl,lcdWidth
	ld	bc,0
	ld	c,(ix+__frame_arg3)
	ld	a,c
	sbc	hl,bc
	ld	(NoClipSprGrabMoveAmt),hl \.r
	ld	(NoClipSprGrabNextLine),a \.r
	ld	b,(ix+__frame_arg4)
	ld	hl,(ix+__frame_arg0)
	pop	ix
	ex	de,hl
_:	push	bc
NoClipSprGrabNextLine =$+1
	ld	bc,0
	ldir
NoClipSprGrabMoveAmt =$+1
	ld	bc,0
	add	hl,bc
	pop	bc
	djnz	-_
	ret
 
;-------------------------------------------------------------------------------
_NoClipDrawTransparentSprite:
; Draws a transparent sprite to the current buffer
; Arguments:
;  __frame_arg0 : Pointer to sprite
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width
;  __frame_arg4 : Height
; Returns:
;  None
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+__frame_arg1)
	ld	c,(ix+__frame_arg2)
	ex.s	de,hl
	ld	hl,(currentDrawingBuffer)
	add	hl,de
	ld	b,lcdWidth/2
	mlt	bc
	add	hl,bc
	add	hl,bc
	ex	de,hl
	ld	hl,lcdWidth
	ld	bc,0
	ld	c,(ix+__frame_arg3)
	ld	a,c
	sbc	hl,bc
	ld	(NoClipSprTransMoveAmt),hl \.r
	ld	(NoClipSprTransNextLine),a \.r
	ld	b,(ix+__frame_arg4)
	ld	hl,(ix+__frame_arg0)
	pop	ix
_:	push	bc
NoClipSprTransNextLine: =$+1
	ld	b,0
_:	ld	a,(hl)
TransparentSpriteColor =$+1
	cp	a,$FF
	jr	nz,+_
	ld	a,(de)
_:	ld	(de),a
	inc	de
	inc	hl
	djnz	--_
	ex	de,hl
NoClipSprTransMoveAmt: =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
	pop	bc
	djnz	---_
	ret
 
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
	jr	nc,_exit_loop
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
_exit_loop:
	pop	ix
	ret

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
	jr	nc,_exit_loop_filled
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
_exit_loop_filled:
	pop ix
	ret

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
	jr	z,+_
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
_:	ld	hl,8
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
;  __frame_arg0 : Boolean monospace flag
; Returns:
;  None
	pop	hl
	pop	de
	push	de
	push	hl
	ld	a,e
	or	a,a
	jr	z,+_
	xor	a,a
	jr	++_
_:	dec	a
_:	ld	(MonoFlag_ASM),a \.r
	ret
 
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
; Inner library data
;-------------------------------------------------------------------------------
 
MonoFlag_ASM:
	.db $FF
CharSpacing_ASM:
	.dl DefaultCharSpacing_ASM \.r
TextData_ASM:
	.dl DefaultTextData_ASM \.r
 
DefaultCharSpacing_ASM:
	;   0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
	.db 8,8,8,7,7,7,8,8,8,8,8,8,8,1,8,8
	.db 7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	.db 2,3,5,7,7,7,7,4,4,4,8,6,3,6,2,7
	.db 7,6,7,7,7,7,7,7,7,7,2,3,5,6,5,6
	.db 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
	.db 7,7,7,7,8,7,7,7,7,7,7,4,7,4,7,8
	.db 3,7,7,7,7,7,7,7,7,4,7,7,4,7,7,7
	.db 7,7,7,7,6,7,7,7,7,7,7,6,2,6,7,7
	.db 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
	.db 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
 
;-------------------------------------------------------------------------------
DefaultTextData_ASM:
Char000: .db $00,$00,$00,$00,$00,$00,$00,$00	; .
Char001: .db $7E,$81,$A5,$81,$BD,$BD,$81,$7E	; .
Char002: .db $7E,$FF,$DB,$FF,$C3,$C3,$FF,$7E	; .
Char003: .db $6C,$FE,$FE,$FE,$7C,$38,$10,$00	; .
Char004: .db $10,$38,$7C,$FE,$7C,$38,$10,$00	; .
Char005: .db $38,$7C,$38,$FE,$FE,$10,$10,$7C	; .
Char006: .db $00,$18,$3C,$7E,$FF,$7E,$18,$7E	; .
Char007: .db $00,$00,$18,$3C,$3C,$18,$00,$00	; .
Char008: .db $FF,$FF,$E7,$C3,$C3,$E7,$FF,$FF	; .
Char009: .db $00,$3C,$66,$42,$42,$66,$3C,$00	; .
Char010: .db $FF,$C3,$99,$BD,$BD,$99,$C3,$FF	; .
Char011: .db $0F,$07,$0F,$7D,$CC,$CC,$CC,$78	; .
Char012: .db $3C,$66,$66,$66,$3C,$18,$7E,$18	; .
Char013: .db $3F,$33,$3F,$30,$30,$70,$F0,$E0	; .
Char014: .db $7F,$63,$7F,$63,$63,$67,$E6,$C0	; .
Char015: .db $99,$5A,$3C,$E7,$E7,$3C,$5A,$99	; .
Char016: .db $80,$E0,$F8,$FE,$F8,$E0,$80,$00	; .
Char017: .db $02,$0E,$3E,$FE,$3E,$0E,$02,$00	; .
Char018: .db $18,$3C,$7E,$18,$18,$7E,$3C,$18	; .
Char019: .db $66,$66,$66,$66,$66,$00,$66,$00	; .
Char020: .db $7F,$DB,$DB,$7B,$1B,$1B,$1B,$00	; .
Char021: .db $3F,$60,$7C,$66,$66,$3E,$06,$FC	; .
Char022: .db $00,$00,$00,$00,$7E,$7E,$7E,$00	; .
Char023: .db $18,$3C,$7E,$18,$7E,$3C,$18,$FF	; .
Char024: .db $18,$3C,$7E,$18,$18,$18,$18,$00	; .
Char025: .db $18,$18,$18,$18,$7E,$3C,$18,$00	; .
Char026: .db $00,$18,$0C,$FE,$0C,$18,$00,$00	; .
Char027: .db $00,$30,$60,$FE,$60,$30,$00,$00	; .
Char028: .db $00,$00,$C0,$C0,$C0,$FE,$00,$00	; .
Char029: .db $00,$24,$66,$FF,$66,$24,$00,$00	; .
Char030: .db $00,$18,$3C,$7E,$FF,$FF,$00,$00	; .
Char031: .db $00,$FF,$FF,$7E,$3C,$18,$00,$00	; .
Char032: .db $00,$00,$00,$00,$00,$00,$00,$00	;  
Char033: .db $C0,$C0,$C0,$C0,$C0,$00,$C0,$00	; !
Char034: .db $D8,$D8,$D8,$00,$00,$00,$00,$00	; "
Char035: .db $6C,$6C,$FE,$6C,$FE,$6C,$6C,$00	; #
Char036: .db $18,$7E,$C0,$7C,$06,$FC,$18,$00	; $
Char037: .db $00,$C6,$CC,$18,$30,$66,$C6,$00	; %
Char038: .db $38,$6C,$38,$76,$DC,$CC,$76,$00	; &
Char039: .db $30,$30,$60,$00,$00,$00,$00,$00	; '
Char040: .db $30,$60,$C0,$C0,$C0,$60,$30,$00	; (
Char041: .db $C0,$60,$30,$30,$30,$60,$C0,$00	; )
Char042: .db $00,$66,$3C,$FF,$3C,$66,$00,$00	; *
Char043: .db $00,$30,$30,$FC,$FC,$30,$30,$00	; +
Char044: .db $00,$00,$00,$00,$00,$60,$60,$C0	; ,
Char045: .db $00,$00,$00,$FC,$00,$00,$00,$00	; -
Char046: .db $00,$00,$00,$00,$00,$C0,$C0,$00	; .
Char047: .db $06,$0C,$18,$30,$60,$C0,$80,$00	; /
Char048: .db $7C,$CE,$DE,$F6,$E6,$C6,$7C,$00	; 0
Char049: .db $30,$70,$30,$30,$30,$30,$FC,$00	; 1
Char050: .db $7C,$C6,$06,$7C,$C0,$C0,$FE,$00	; 2
Char051: .db $FC,$06,$06,$3C,$06,$06,$FC,$00	; 3
Char052: .db $0C,$CC,$CC,$CC,$FE,$0C,$0C,$00	; 4
Char053: .db $FE,$C0,$FC,$06,$06,$C6,$7C,$00	; 5
Char054: .db $7C,$C0,$C0,$FC,$C6,$C6,$7C,$00	; 6
Char055: .db $FE,$06,$06,$0C,$18,$30,$30,$00	; 7
Char056: .db $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	; 8
Char057: .db $7C,$C6,$C6,$7E,$06,$06,$7C,$00	; 9
Char058: .db $00,$C0,$C0,$00,$00,$C0,$C0,$00	; :
Char059: .db $00,$60,$60,$00,$00,$60,$60,$C0	; ;
Char060: .db $18,$30,$60,$C0,$60,$30,$18,$00	; <
Char061: .db $00,$00,$FC,$00,$FC,$00,$00,$00	; =
Char062: .db $C0,$60,$30,$18,$30,$60,$C0,$00	; >
Char063: .db $78,$CC,$18,$30,$30,$00,$30,$00	; ?
Char064: .db $7C,$C6,$DE,$DE,$DE,$C0,$7E,$00	; @
Char065: .db $38,$6C,$C6,$C6,$FE,$C6,$C6,$00	; A
Char066: .db $FC,$C6,$C6,$FC,$C6,$C6,$FC,$00	; B
Char067: .db $7C,$C6,$C0,$C0,$C0,$C6,$7C,$00	; C
Char068: .db $F8,$CC,$C6,$C6,$C6,$CC,$F8,$00	; D
Char069: .db $FE,$C0,$C0,$F8,$C0,$C0,$FE,$00	; E
Char070: .db $FE,$C0,$C0,$F8,$C0,$C0,$C0,$00	; F
Char071: .db $7C,$C6,$C0,$C0,$CE,$C6,$7C,$00	; G
Char072: .db $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00	; H
Char073: .db $7E,$18,$18,$18,$18,$18,$7E,$00	; I
Char074: .db $06,$06,$06,$06,$06,$C6,$7C,$00	; J
Char075: .db $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00	; K
Char076: .db $C0,$C0,$C0,$C0,$C0,$C0,$FE,$00	; L
Char077: .db $C6,$EE,$FE,$FE,$D6,$C6,$C6,$00	; M
Char078: .db $C6,$E6,$F6,$DE,$CE,$C6,$C6,$00	; N
Char079: .db $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00	; O
Char080: .db $FC,$C6,$C6,$FC,$C0,$C0,$C0,$00	; P
Char081: .db $7C,$C6,$C6,$C6,$D6,$DE,$7C,$06	; Q
Char082: .db $FC,$C6,$C6,$FC,$D8,$CC,$C6,$00	; R
Char083: .db $7C,$C6,$C0,$7C,$06,$C6,$7C,$00	; S
Char084: .db $FF,$18,$18,$18,$18,$18,$18,$00	; T
Char085: .db $C6,$C6,$C6,$C6,$C6,$C6,$FE,$00	; U
Char086: .db $C6,$C6,$C6,$C6,$C6,$7C,$38,$00	; V
Char087: .db $C6,$C6,$C6,$C6,$D6,$FE,$6C,$00	; W
Char088: .db $C6,$C6,$6C,$38,$6C,$C6,$C6,$00	; X
Char089: .db $C6,$C6,$C6,$7C,$18,$30,$E0,$00	; Y
Char090: .db $FE,$06,$0C,$18,$30,$60,$FE,$00	; Z
Char091: .db $F0,$C0,$C0,$C0,$C0,$C0,$F0,$00	; [
Char092: .db $C0,$60,$30,$18,$0C,$06,$02,$00	; \
Char093: .db $F0,$30,$30,$30,$30,$30,$F0,$00	; ]
Char094: .db $10,$38,$6C,$C6,$00,$00,$00,$00	; ^
Char095: .db $00,$00,$00,$00,$00,$00,$00,$FF	; _
Char096: .db $C0,$C0,$60,$00,$00,$00,$00,$00	; `
Char097: .db $00,$00,$7C,$06,$7E,$C6,$7E,$00	; a
Char098: .db $C0,$C0,$C0,$FC,$C6,$C6,$FC,$00	; b
Char099: .db $00,$00,$7C,$C6,$C0,$C6,$7C,$00	; c
Char100: .db $06,$06,$06,$7E,$C6,$C6,$7E,$00	; d
Char101: .db $00,$00,$7C,$C6,$FE,$C0,$7C,$00	; e
Char102: .db $1C,$36,$30,$78,$30,$30,$78,$00	; f
Char103: .db $00,$00,$7E,$C6,$C6,$7E,$06,$FC	; g
Char104: .db $C0,$C0,$FC,$C6,$C6,$C6,$C6,$00	; h
Char105: .db $60,$00,$E0,$60,$60,$60,$F0,$00	; i
Char106: .db $06,$00,$06,$06,$06,$06,$C6,$7C	; j
Char107: .db $C0,$C0,$CC,$D8,$F8,$CC,$C6,$00	; k
Char108: .db $E0,$60,$60,$60,$60,$60,$F0,$00	; l
Char109: .db $00,$00,$CC,$FE,$FE,$D6,$D6,$00	; m
Char110: .db $00,$00,$FC,$C6,$C6,$C6,$C6,$00	; n
Char111: .db $00,$00,$7C,$C6,$C6,$C6,$7C,$00	; o
Char112: .db $00,$00,$FC,$C6,$C6,$FC,$C0,$C0	; p
Char113: .db $00,$00,$7E,$C6,$C6,$7E,$06,$06	; q
Char114: .db $00,$00,$FC,$C6,$C0,$C0,$C0,$00	; r
Char115: .db $00,$00,$7E,$C0,$7C,$06,$FC,$00	; s
Char116: .db $30,$30,$FC,$30,$30,$30,$1C,$00	; t
Char117: .db $00,$00,$C6,$C6,$C6,$C6,$7E,$00	; u
Char118: .db $00,$00,$C6,$C6,$C6,$7C,$38,$00	; v
Char119: .db $00,$00,$C6,$C6,$D6,$FE,$6C,$00	; w
Char120: .db $00,$00,$C6,$6C,$38,$6C,$C6,$00	; x
Char121: .db $00,$00,$C6,$C6,$C6,$7E,$06,$FC	; y
Char122: .db $00,$00,$FE,$0C,$38,$60,$FE,$00	; z
Char123: .db $1C,$30,$30,$E0,$30,$30,$1C,$00	; {
Char124: .db $C0,$C0,$C0,$00,$C0,$C0,$C0,$00	; |
Char125: .db $E0,$30,$30,$1C,$30,$30,$E0,$00	; }
Char126: .db $76,$DC,$00,$00,$00,$00,$00,$00	; ~
Char127: .db $00,$10,$38,$6C,$C6,$C6,$FE,$00	; .

 .endLibrary