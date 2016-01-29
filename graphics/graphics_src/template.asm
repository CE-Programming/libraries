#include "ti84pce.inc"
#include "..\\..\\include\\relocation.inc"
 
; stack locations
#define arg0 6
#define arg1 9
#define arg2 12
#define arg3 15
#define arg4 18
#define arg5 21

lcdsize			        equ lcdwidth*lcdhheight*2
currentDrawingBuffer	equ silentLinkHookPtr		; since it isn't used anyway, may as well

 .libraryName		"GRAPHC"	                    ; Name of library
 .libraryVersion	1		                        ; Version information (1-255)
 
 .function "void","gc_InitGraph","void",_initgraph
 .function "void","gc_CloseGraph","void",_closegraph
 .function "void","gc_SetDefaultPalette","void",_setdefaultpal
 .function "void","gc_SetPalette","unsigned short *palette, unsigned short size",_setPal
 .function "void","gc_FillScrn","unsigned char color",_fillscrn
 .function "void","gc_SetPixel","unsigned short x, unsigned char y, unsigned char color",_setpixel
 .function "unsigned char","gc_GetPixel","unsigned short x, unsigned char y",_getpixel
 .function "unsigned short","gc_GetColor","unsigned char index",_getcolor
 .function "void","gc_SetColor","unsigned char index, unsigned short color",_setcolor
 .function "void","gc_NoClipLine","unsigned short x0, unsigned char y0, unsigned short x1, unsigned char y1, unsigned char color",_line
 .function "void","gc_NoClipRectangle","unsigned short x, unsigned char y, unsigned short width, unsigned char height, unsigned char color",_rectangle
 .function "void","gc_NoClipRectangleOutline","unsigned short x, unsigned char y, unsigned short width, unsigned char height, unsigned char color",_rectangleoutline
 .function "void","gc_NoClipHorizLine","unsigned short x, unsigned char y, unsigned short length, unsigned char color",_horizline
 .function "void","gc_NoClipVertLine","unsigned short x, unsigned char y, unsigned char length, unsigned char color",_vertline
 .function "void","gc_NoClipCircle","unsigned short x, unsigned char y, unsigned short radius, unsigned char color",_circle
 .function "void","gc_ClipCircleOutline","unsigned short x, unsigned char y, unsigned short radius, unsigned char color",_circleoutline
 .function "void","gc_DrawBuffer","void",_drawbuffer
 .function "void","gc_DrawScreen","void",_drawscreen
 .function "void","gc_SwapDraw","void",_swapbuffer
 .function "unsigned char","gc_DrawState","void",_getbufferstatus
 .function "void","gc_PrintChar","char c",_outchar
 .function "void","gc_PrintString","char *string",_outtext
 .function "void","gc_PrintStringXY","char *string, unsigned short x, unsigned char y",_outtextxy
 .function "unsigned short","gc_TextX","void",_textx
 .function "unsigned char","gc_TextY","void",_texty
 .function "void","gc_SetTextXY","unsigned short x, unsigned char y",_settextxy
 .function "void","gc_SetTextColor","unsigned short color",_textcolor
 .function "unsigned char","gc_SetTransparentColor","unsigned char color",_transparentcolor
 .function "void","gc_NoClipDrawSprite","unsigned char *sprite, unsigned short x, unsigned char y, unsigned char width, unsigned char height",_drawsprite
 .function "void","gc_NoClipDrawTransparentSprite","unsigned char *sprite, unsigned short x, unsigned char y, unsigned char width, unsigned char height",_drawTransparentSprite
 .function "void","gc_NoClipGetSprite","unsigned char *spriteBuffer, unsigned short x, unsigned char y, unsigned char width, unsigned char height",_getsprite
 
 .beginDependencies
 .endDependencies
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sets the LCD to 8bpp mode for sweet graphics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_initgraph:
 call $000374			    ; clears screen
 ld a,lcdbpp8
setLCDcontrol:
 ld (mpLcdCtrl),a
 ld hl,vram
 ld (currentDrawingBuffer),hl	; set the draw
 jr _setdefaultpal
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sets the LCD to the default 16bpp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_closegraph:
 call $000374	    ; clears screen
 ld hl,vram
 ld (mpLcdBase),hl
 ld a,lcdbpp16
 jr setLCDcontrol		; save some bytes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fills the screen with a specified color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_fillscrn:
 di
 pop hl
  pop bc
  push bc
 push hl
 ld a,c
 ld bc,lcdWidth*lcdHeight
 ld hl,(currentDrawingBuffer)
 jp _memset
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set the default pallete of LOW==HIGH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_setdefaultpal:
 ld de,mpLcdPalette
 ld b,l
_1555loop:
 ld a,b
 rrca
 xor a,b
 and a,%11100000
 xor a,b
 ld (de),a
 inc de
 ld a,b
 rra
 ld (de),a
 inc de
 inc b
 jr nz,_1555loop
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set the palette (ptr, size)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_setPal:
 push ix
  ld ix,0
  add ix,sp
  ld hl,(ix+arg0)
  ld bc,(ix+arg1)
 pop ix
 ld de,mpLcdPalette
 ldir
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gets the color of a given pallete entry
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_getcolor:
 push ix
  ld ix,0
  add ix,sp
  ld l,(ix+arg0)
  ld a,(ix+arg1)
 pop ix
 ld h,2
 mlt hl
 ld de,mpLcdPalette
 add hl,de
 ld e,(hl)
 inc hl
 ld d,(hl)
 or a,a \ sbc hl,hl	; clear the upper byte HLU
 ld h,d
 ld l,e
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sets the color of a given pallete entry (unsigned char, unsigned short)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_setcolor:
 push ix
  ld ix,0
  add ix,sp
  ld l,(ix+arg0)
  ld a,(ix+arg1)
  ld h,2
  mlt hl
  ld de,mpLcdPalette
  add hl,de
  ld (hl),a
  inc hl
  ld a,(ix+arg1+1)
  ld (hl),a
 pop ix
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gets the color index of a pixel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_getpixel:
 push ix
  ld bc,0
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)		; DE=X
  ld l,(ix+arg1)		; L=Y
 pop ix
 ld a,l
 cp a,lcdHeight
 ret nc				; return if offscreen
 ex de,hl
  ld bc,lcdWidth
  or a,a \ sbc hl,bc
  add hl,bc
  ret nc			; return if offscreen
 ex de,hl
 ld h,lcdWidth/2
 mlt hl
 add hl,hl
 add hl,de
 ld de,(currentDrawingBuffer)
 add hl,de
 ld a,(hl)
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets a pixel to a color (x,y,color)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_setpixel:
 push ix
  ld bc,0
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)   ; DE=X
  ld a,(ix+arg2)    ; color
  ld (set_color),a \.r
  ld a,(ix+arg1)    ; A=Y
 pop ix
setPixel_ASM:
 or a,a \ sbc hl,hl
 ld l,a			    ; Y->L
 cp a,lcdHeight
 ret nc				; return if y>lcdHeight
 or a,a \ adc hl,bc
 ret m				; return if negative
 ex de,hl
 or a,a \ adc hl,bc
 ret m				; return if negative
 ld bc,lcdWidth
 or a,a \ sbc hl,bc
 add hl,bc
 ret nc				; return if offscreen
 ex de,hl
 ld h,lcdWidth/2
 mlt hl
 add hl,hl
 add hl,de
 ld de,(currentDrawingBuffer)
 add hl,de
set_color: = $+1
 ld (hl),0
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Draw a colored filled rectangle (X,Y,W,H)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_rectangle:
 push ix
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)		; x
  ld l,(ix+arg1)		; y
  ld bc,(ix+arg2)		; width
  ld h,(ix+arg3)		; height
  ld a,(ix+arg4)		; color
  ld (FillRect_Color),a \.r
  ld a,h
  ld h,lcdWidth/2
  mlt hl
  add hl,hl
  add hl,de
  ld de,(currentDrawingBuffer)
  add hl,de
  dec bc
FillRect_Loop:
FillRect_Color = $+1
  ld (hl),0
  push hl
  pop de
  inc de
  push bc
  ldir
  pop bc
  ld de,lcdWidth
  add hl,de
  sbc hl,bc
  dec a
  jr nz,FillRect_Loop
 pop ix
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a colored rectangle outline (X,Y,W,H)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_rectangleoutline:
 push ix
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)		; x
  ld h,(ix+arg1)		; y
  ld bc,(ix+arg2)		; width
  ld l,(ix+arg3)		; height
  ld a,(ix+arg4)		; color
  push de
   push hl
    call HorizLine_ASM \.r	 	    ; top
    ld b,(ix+arg3)
    dec b
    push bc
     call RectOutlineVert_ASM \.r	; right
    pop bc
   pop hl
  pop de
  call RectOutlineVert_ASM_2 \.r	    ; left
  ld bc,(ix+arg2)
  call _memset			            ; bottom
 pop ix
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Draw a colored horizontal line (X,Y,length,color)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_horizline:
 push ix
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)		; x
  ld h,(ix+arg1)		; y
  ld bc,(ix+arg2)		; length
  ld a,(ix+arg3)
 pop ix
HorizLine_ASM:
 ld l,lcdWidth/2
 mlt hl
 add hl,hl
 add hl,de
 ld de,(currentDrawingBuffer)
 add hl,de
 jp _memset
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a colored vertical line (X,Y,length,color)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_vertline:
 push ix
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)		; x
  ld h,(ix+arg1)		; y
  ld b,(ix+arg2)		; length
  ld a,(ix+arg3)
 pop ix
RectOutlineVert_ASM_2:
 ld l,lcdWidth/2
 mlt hl
 add hl,hl
 add hl,de
 ld de,(currentDrawingBuffer)
 add hl,de
RectOutlineVert_ASM:
 ld de,lcdWidth
VLoop:
 ld (hl),a
 add hl,de
 djnz VLoop
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine to draw to back buffer if needed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_drawbuffer:
 ld hl,vram
 ld de,(mpLcdBase)
 or a,a \ sbc hl,de
 add hl,de			; cp hl,de
 jr nz,SetBackBufferLocation
 ld hl,vram+(320*240)
SetBackBufferLocation:
 ld (currentDrawingBuffer),hl
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine to draw to screen if needed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_drawscreen:
 ld hl,vram
 ld de,(mpLcdBase)
 or a,a \ sbc hl,de
 add hl,de			; cp hl,de
 jr z,SetBackBufferLocation
 ld hl,vram+(320*240)
 jr SetBackBufferLocation
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Swaps the GRAM pointers in the LCD safely
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_swapbuffer:
 ld hl,vram
 ld de,(mpLcdBase)
 or a,a \ sbc hl,de
 add hl,de
 jr nz,SetToVRAM
 ld hl,vram+(lcdWidth*lcdHeight)
SetToVRAM:
 ld (currentDrawingBuffer),de
 ld de,mpLcdIcr
 ld a,(de)
 or a,%00000100 
 ld (de),a
 ld (mpLcdBase),hl
WaitForLCDReady:
 ld a,(mpLcdRis)
 and a,%00000100
 jr z,WaitForLCDReady
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true if drawing on the buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_getbufferstatus:
 ld hl,(currentDrawingBuffer)
 ld de,(mpLcdBase)
 xor a,a \ sbc hl,de
 add hl,de
 ret z
 inc a
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the current (x,y) coordinates for text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_textx:
 ld a,(textX) \.r
 ret
_texty:
 ld hl,(textY) \.r
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets the transparent color for drawing
; Returns previous transparency color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_transparentcolor:
 push ix
  ld ix,0
  add ix,sp
  ld a,(transpcolor) \.r
  push af
   ld a,(ix+arg0)
   ld (transpcolor),a \.r
   ld (transpcolorspr),a \.r
  pop af
 pop ix
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets the text color (both foreground and background)
; high 8 is background, low 8 is foreground
; Returns previous text color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_textcolor:
 push ix
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)
 pop ix
 ld hl,(textcolor) \.r
 ld (textcolor),de \.r
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets up the (x,y) corrdinates of the cursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_settextxy:
 push ix
  ld ix,0
  add ix,sp
  ld hl,(ix+arg0)
  ld a,(ix+arg1)
 pop ix
 ld (textX),hl \.r
 ld (textY),a \.r
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a string of characters at (x,y).
; Also modifies the current text cursor posisition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_outtextxy:
 di
 push ix
  ld ix,0
  add ix,sp
  ld hl,(ix+arg0)
  ld de,(ix+arg1)
  ld a,(ix+arg2)
 pop ix
 ld (textX),de \.r
 ld (textY),a \.r
 jr textloop
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a string of characters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_outtext:
 pop de
  pop hl
  push hl
 push de
textloop:
 ld a,(hl)
 or a,a
 ret z
 push hl
  call ASM_outchar \.r
 pop hl
 inc hl
 jr textloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a single character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_outchar:
 pop hl
  pop bc
  push bc
 push hl
 ld a,c
ASM_outchar:
textX: = $+1
 ld bc,0
 push af
  push af
   push bc
    cp 128
    jr c,+_
    xor a
_:
    or a,a \ sbc hl,hl \ ld l,a
    ld de,CharSpacing \.r
    add hl,de
    ld a,(hl)			; amount to increment per character
    inc a
    ld (charwidth),a \.r
    sbc hl,hl \ ld l,a
    add hl,bc
    ld (textX),hl \.r
textY: = $+1
    ld l,0
    ld h,lcdWidth/2
    mlt hl
    add hl,hl
    ld de,(currentDrawingBuffer)
    add hl,de
   pop de			    ; de = X
   add hl,de			; Add X
  pop af
  push hl
   sbc hl,hl \ ld l,a
   add hl,hl \ add hl,hl \ add hl,hl
   ex de,hl
   ld hl,char000 \.r
   add hl,de			; hl -> Correct Character
  pop de			; de -> correct place to draw
  ld b,8
iloop:
  push bc
   ld c,(hl)
charwidth: =$+1
   ld b,0
   ex de,hl
   push de
textcolor: equ $+1
    ld de,$FF00
cloop:
    ld a,d
    rlc c
    jr nc,+_
    ld a,e
_:
transpcolor: =$+1
    cp $FF
    jr nz,+_
    ld a,(hl)
_:
    ld (hl),a
    inc hl
    djnz cloop
    ld bc,lcdWidth
    ld de,$FFFFFF               ; sign extend
    ld a,(charwidth) \.r		    ; bc+hl-charwidth
    neg
    ld e,a
    add hl,bc
    add hl,de
   pop de
   ex de,hl
   inc hl
  pop bc
  djnz iloop
 pop af
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a sprite to the screen as fast as possible
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_drawsprite:
 di
 push ix
  ld ix,0
  add ix,sp
  ld hl,(currentDrawingBuffer)
  ld de,(ix+arg1)               ; X
  ld c,(ix+arg2)                ; Y
  add hl,de
  ld b,160
  mlt bc
  add hl,bc
  add hl,bc
  ex de,hl
  ld hl,320
  ld bc,(ix+arg3)              ; width
  ld a,c
  sbc hl,bc
  ld (moveAmount),hl \.r
  ld (nextLine),a \.r
  ld b,(ix+arg4)              ; height
  ld hl,(ix+arg0)
 pop ix
InLoop: 
 push bc
nextLine: =$+1
  ld bc,0
  ldir
  ex de,hl
moveAmount: =$+1
  ld bc,0
  add hl,bc
  ex de,hl
 pop bc
 djnz InLoop
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Grabs the background really quick for transparency
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_getsprite:
 di
 push ix
  ld ix,0
  add ix,sp
  ld hl,(currentDrawingBuffer)
  ld de,(ix+arg1)               ; X
  ld c,(ix+arg2)                ; Y
  add hl,de
  ld b,lcdWidth/2
  mlt bc
  add hl,bc
  add hl,bc
  ex de,hl
  ld hl,lcdWidth
  ld bc,(ix+arg3)              ; width
  ld a,c
  sbc hl,bc
  ld (grab_moveAmount),hl \.r
  ld (grab_nextLine),a \.r
  ld b,(ix+arg4)              ; height
  ld hl,(ix+arg0)
  ex de,hl
grab_InLoop: 
  push bc
grab_nextLine: =$+1
   ld bc,0
   ldir
grab_moveAmount: =$+1
   ld bc,0
   add hl,bc
  pop bc
  djnz grab_InLoop
  ld hl,(ix+arg0)
 pop ix
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws a transparent sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_drawTransparentSprite:
 di
 push ix
  ld ix,0
  add ix,sp
  ld hl,(currentDrawingBuffer)
  ld de,(ix+arg1)               ; X
  ld c,(ix+arg2)                ; Y
  add hl,de
  ld b,lcdWidth/2
  mlt bc
  add hl,bc
  add hl,bc
  ex de,hl
  ld hl,lcdWidth
  ld bc,(ix+arg3)              ; width
  ld a,c
  sbc hl,bc
  ld (trans_moveAmount),hl \.r
  ld (trans_nextLine),a \.r
  ld b,(ix+arg4)              ; height
  ld hl,(ix+arg0)
 pop ix
trans_InLoop: 
 push bc
trans_nextLine: =$+1
  ld b,0
_:
  ld a,(hl)
transpcolorspr: =$+1
  cp a,$FF
  jr nz,+_
  ld a,(de)
_:
  ld (de),a
  inc de
  inc hl
  djnz --_
  ex de,hl
trans_moveAmount: =$+1
  ld bc,0
  add hl,bc
  ex de,hl
 pop bc
 djnz trans_InLoop
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a circle outline
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_circleoutline: 
 di
 push ix
  ld ix,0
  add ix,sp
  ld hl,(ix+arg0)
  ld de,(ix+arg1)
  ld bc,(ix+arg2)
  ld a,(ix+arg3)
  push hl
   push de 
    exx 
   pop de 
  pop hl 
  exx 
  push bc 
   push bc 
   pop de 
  pop hl 
  add hl,hl 
  push hl 
  pop bc 
  ld hl,3 
  or a,a 
  sbc hl,bc 
  push hl 
  pop ix 
  or a,a
  sbc hl,hl
drawCircle_Loop:
  or a,a
  sbc hl,de 
  add hl,de 
  jr nc,_exit_loop
  ld c,ixh 
  bit 7,c 
  jr z,_dc_else 
  push hl 
   add hl,hl 
   add hl,hl 
   ld bc,6 
   add hl,bc 
   push hl 
   pop bc 
   add ix,bc 
  pop hl 
  jr _dc_end 
_dc_else: 
  push hl
   or a,a 
   sbc hl,de 
   add hl,hl 
   add hl,hl 
   ld bc,10 
   add hl,bc 
   push hl 
   pop bc 
   add ix,bc 
  pop hl 
  dec de 
_dc_end: 
  call drawCircleSection \.r
  inc hl 
  jr drawCircle_Loop 
  
_exit_loop:
 pop ix
 ret

drawCircleSection: 
  call drawCirclePoints \.r
  ex de,hl 
  call drawCirclePoints \.r
  ex de,hl 
  ret 

drawCirclePoints: 
  push hl
   exx
  pop bc 
  push hl 
   add hl,bc
   exx 
   push de 
    exx 
   pop bc 
   ex de,hl 
   push hl 
    add hl,bc 
    ex de,hl 
    call drawPixel \.r
   pop de 
  pop hl 
  exx 
  push hl 
   exx 
  pop bc 
  push hl 
   or a,a 
   sbc hl,bc
   exx 
   push de 
    exx 
   pop bc 
   ex de,hl 
   push hl 
    add hl,bc 
    ex de,hl 
    call drawPixel \.r
   pop de 
  pop hl 
  exx 
  push hl 
   exx 
  pop bc 
  push hl 
   add hl,bc
   exx 
   push de 
    exx 
   pop bc 
   ex de,hl 
   push hl 
    or a,a 
    sbc hl,bc 
    ex de,hl 
    call drawPixel \.r
   pop de 
  pop hl 
  exx 
  push hl 
   exx 
  pop bc 
  push hl 
   or a,a 
   sbc hl,bc
   exx 
   push de 
    exx 
   pop bc 
   ex de,hl 
   push hl 
    or a,a 
    sbc hl,bc 
    ex de,hl 
    call drawPixel \.r
   pop de 
  pop hl 
  exx 
  ret 
  
drawPixel: 
 bit 7,h 
 ret nz                           ; return if negative 
 bit 7,d 
 ret nz                           ; return if negative 
 push bc 
 ld bc,320 
 or a 
 sbc hl,bc 
 add hl,bc 
 pop bc 
 ret nc                           ; return if offscreen 
 ex de,hl 
 push bc 
 ld bc,240 
 or a 
 sbc hl,bc 
 add hl,bc 
 pop bc 
 ret nc                           ; return if offscreen 
 ld h,160 
 mlt hl 
 add hl,hl 
 add hl,de 
 ld de,(currentDrawingBuffer)
 add hl,de
 ld (hl),a
 ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a filled circle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_circle:
 di
 push ix
  ld ix,0
  add ix,sp
  ld hl,(ix+arg0)
  ld de,(ix+arg1)
  ld bc,(ix+arg2)
  ld a,(ix+arg3)
  ld (color),a \.r
  ld (color2),a \.r
  push hl
   push de
    exx
   pop de
  pop hl
  exx
  ld e,c
  ld d,b
  ld l,c
  ld h,b
  add hl,hl
  ld c,l
  ld b,h
  ld hl,3
  or a,a
  sbc hl,bc
  push hl
  pop ix
  or a,a
  sbc hl,hl
drawFilledCircle_Loop:
  or a,a
  sbc hl,de
  add hl,de
  jr nc,_exit_loop_filled
  ld a,ixh
  bit 7,a
  jr z,_dfc_else
  push hl
   add hl,hl
   add hl,hl
   ld bc,6
   add hl,bc
   ld c,l
   ld b,h
   add ix,bc
  pop hl
  jr _dfc_end
_dfc_else:
  push hl
   or a,a
   sbc hl,de
   add hl,hl
   add hl,hl
   ld bc,10
   add hl,bc
   ld c,l
   ld b,h
   add ix,bc
  pop hl
  dec de
_dfc_end:
  call drawFilledCircleSection \.r
  inc hl
  jr drawFilledCircle_Loop

_exit_loop_filled:
 pop ix
 ret

drawFilledCircleSection:
  call drawFilledCirclePoints \.r
  ex de,hl
  call drawFilledCirclePoints \.r
  ex de,hl
  ret
  
drawFilledCirclePoints:
  push ix
   push hl
    push de
     push hl
      exx
     pop bc
     push hl
      or a,a
      sbc hl,bc
      push hl
       add hl,bc
       add hl,bc
       push hl
       pop ix
      pop hl
      exx
      push de
       exx
      pop bc
      push de
       ex de,hl
       add hl,bc
       ex de,hl
       push de
        push de
        pop bc
        ex de,hl
        push ix
        pop hl
       pop ix
       push bc
        ld b,ixl
        call drawLine \.r
       pop bc
      pop de
     pop hl
     exx
    pop de
   pop hl
  pop ix
  push ix
   push hl
    push de
     push hl
      exx
     pop bc
     push hl
      or a,a
      sbc hl,bc
      push hl
       add hl,bc
       add hl,bc
       push hl
       pop ix
      pop hl
      exx
      push de
       exx
      pop bc
      push de
       ex de,hl
       or a,a
       sbc hl,bc
       ex de,hl
       push de
        push de
        pop bc
        ex de,hl
        push ix
        pop hl
       pop ix
       push bc
        ld b,ixl
        call drawLine \.r
       pop bc
      pop de
     pop hl
     exx
    pop de
   pop hl
  pop ix
  ret
    
;de=x, hl=x, b=y, c=y, a=indexed color
_line:
 di                             ; Freaking TI-OS
 push ix
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)
  ld hl,(ix+arg2)
  ld b,(ix+arg1)
  ld c,(ix+arg3)
  ld a,(ix+arg4)
 pop ix
 ld (color),a \.r
 ld (color2),a \.r
drawLine:
 ld a,c
 ld (y1),a \.r
 push de
  push hl
   push bc    
    or a,a 
    sbc hl,de 
    ld a,$03 
    jr nc,+_ 
    ld a,$0B
_:  ld (xStep),a \.r
    ld (xStep2),a \.r
    ex de,hl 
    or a,a 
    sbc hl,hl 
    sbc hl,de 
    jp p,+_ \.r
    ex de,hl 
_:  ld (dx),hl \.r
    push hl 
     add hl,hl 
     ld (dx1),hl \.r
     ld (dx12),hl \.r
     or a,a
     sbc hl,hl
     ex de,hl
     sbc hl,hl
     ld e,b
     ld l,c
     or a,a 
     sbc hl,de
     ld a,$3C
     jr nc,+_
     inc a
_:   ld (yStep),a \.r
     ld (yStep2),a \.r
     ex de,hl 
     or a,a 
     sbc hl,hl 
     sbc hl,de 
     jp p,+_ \.r
     ex de,hl
_:   ld (dy),hl \.r
     add hl,hl
     ld (dy1),hl \.r
     ld (dy12),hl \.r
    pop de
   pop af
   ld hl,(dy) \.r
   or a,a 
   sbc hl,de 
  pop de
 pop bc
 ld hl,0 
 jr nc,changeYLoop 
changeXLoop:
 push hl 
  ld l,a 
  ld h,lcdWidth/2 
  mlt hl 
  add hl,hl 
  add hl,bc 
  push bc 
   ld bc,(currentDrawingBuffer)
   add hl,bc 
color: =$+1 
   ld (hl),0 
   pop bc 
   dec sp 
   dec sp 
   dec sp 
  pop hl 
  or a,a 
  sbc hl,de 
 pop hl 
 ret z 
xStep:    
 nop
 push de
dy1: =$+1 
  ld de,0 
  or a,a 
  adc hl,de
  jp m,+_ \.r
dx: =$+1
  ld de,0
  or a,a
  sbc hl,de 
  add hl,de 
  jr c,+_
yStep: 
  nop
dx1: =$+1 
  ld de,0
  sbc hl,de 
_:
 pop de
 jr changeXLoop 
changeYLoop:
 push bc 
  push hl
   ld l,a 
   ld h,lcdWidth/2 
   mlt hl 
   add hl,hl 
   add hl,bc 
   ld bc,(currentDrawingBuffer)
   add hl,bc 
color2: =$+1 
   ld (hl),0 
  pop hl
 pop bc
y1: =$+1
 cp a,0
 ret z
yStep2:
 nop
 push de
dx12: =$+1
  ld de,0
  or a,a
  adc hl,de
  jp m,+_ \.r
dy: =$+1
  ld de,0
  or a,a
  sbc hl,de
  add hl,de
  jr c,+_
xStep2:
  nop
dy12: =$+1
  ld de,0
  sbc hl,de
_:
 pop de
 jr changeYLoop
    
;#######################################################
; Inner library routines                               #
;#######################################################
 
;#######################################################
; Inner library data                                   #
;#######################################################

textBits:
 .db 0
 
CharSpacing:
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
Char128: .db $7C,$C6,$C0,$C0,$C0,$D6,$7C,$30	; .
Char129: .db $C6,$00,$C6,$C6,$C6,$C6,$7E,$00	; .
Char130: .db $0E,$00,$7C,$C6,$FE,$C0,$7C,$00	; .
Char131: .db $7E,$81,$3C,$06,$7E,$C6,$7E,$00	; .
Char132: .db $66,$00,$7C,$06,$7E,$C6,$7E,$00	; .
Char133: .db $E0,$00,$7C,$06,$7E,$C6,$7E,$00	; .
Char134: .db $18,$18,$7C,$06,$7E,$C6,$7E,$00	; .
Char135: .db $00,$00,$7C,$C6,$C0,$D6,$7C,$30	; .
Char136: .db $7E,$81,$7C,$C6,$FE,$C0,$7C,$00	; .
Char137: .db $66,$00,$7C,$C6,$FE,$C0,$7C,$00	; .
Char138: .db $E0,$00,$7C,$C6,$FE,$C0,$7C,$00	; .
Char139: .db $66,$00,$38,$18,$18,$18,$3C,$00	; .
Char140: .db $7C,$82,$38,$18,$18,$18,$3C,$00	; .
Char141: .db $70,$00,$38,$18,$18,$18,$3C,$00	; .
Char142: .db $C6,$10,$7C,$C6,$FE,$C6,$C6,$00	; .
Char143: .db $38,$38,$00,$7C,$C6,$FE,$C6,$00	; .
Char144: .db $0E,$00,$FE,$C0,$F8,$C0,$FE,$00	; .
Char145: .db $00,$00,$7F,$0C,$7F,$CC,$7F,$00	; .
Char146: .db $3F,$6C,$CC,$FF,$CC,$CC,$CF,$00	; .
Char147: .db $7C,$82,$7C,$C6,$C6,$C6,$7C,$00	; .
Char148: .db $66,$00,$7C,$C6,$C6,$C6,$7C,$00	; .
Char149: .db $E0,$00,$7C,$C6,$C6,$C6,$7C,$00	; .
Char150: .db $7C,$82,$00,$C6,$C6,$C6,$7E,$00	; .
Char151: .db $E0,$00,$C6,$C6,$C6,$C6,$7E,$00	; .
Char152: .db $66,$00,$66,$66,$66,$3E,$06,$7C	; .
Char153: .db $C6,$7C,$C6,$C6,$C6,$C6,$7C,$00	; .
Char154: .db $C6,$00,$C6,$C6,$C6,$C6,$FE,$00	; .
Char155: .db $18,$18,$7E,$D8,$D8,$D8,$7E,$18	; .
Char156: .db $38,$6C,$60,$F0,$60,$66,$FC,$00	; .
Char157: .db $66,$66,$3C,$18,$7E,$18,$7E,$18	; .
Char158: .db $F8,$CC,$CC,$FA,$C6,$CF,$C6,$C3	; .
Char159: .db $0E,$1B,$18,$3C,$18,$18,$D8,$70	; .
Char160: .db $0E,$00,$7C,$06,$7E,$C6,$7E,$00	; .
Char161: .db $1C,$00,$38,$18,$18,$18,$3C,$00	; .
Char162: .db $0E,$00,$7C,$C6,$C6,$C6,$7C,$00	; .
Char163: .db $0E,$00,$C6,$C6,$C6,$C6,$7E,$00	; .
Char164: .db $00,$FE,$00,$FC,$C6,$C6,$C6,$00	; .
Char165: .db $FE,$00,$C6,$E6,$F6,$DE,$CE,$00	; .
Char166: .db $3C,$6C,$6C,$3E,$00,$7E,$00,$00	; .
Char167: .db $3C,$66,$66,$3C,$00,$7E,$00,$00	; .
Char168: .db $18,$00,$18,$18,$30,$66,$3C,$00	; .
Char169: .db $00,$00,$00,$FC,$C0,$C0,$00,$00	; .
Char170: .db $00,$00,$00,$FC,$0C,$0C,$00,$00	; .
Char171: .db $C6,$CC,$D8,$3F,$63,$CF,$8C,$0F	; .
Char172: .db $C3,$C6,$CC,$DB,$37,$6D,$CF,$03	; .
Char173: .db $18,$00,$18,$18,$18,$18,$18,$00	; .
Char174: .db $00,$33,$66,$CC,$66,$33,$00,$00	; .
Char175: .db $00,$CC,$66,$33,$66,$CC,$00,$00	; .
Char176: .db $22,$88,$22,$88,$22,$88,$22,$88	; .
Char177: .db $55,$AA,$55,$AA,$55,$AA,$55,$AA	; .
Char178: .db $DD,$77,$DD,$77,$DD,$77,$DD,$77	; .
Char179: .db $18,$18,$18,$18,$18,$18,$18,$18	; .
Char180: .db $18,$18,$18,$18,$F8,$18,$18,$18	; .
Char181: .db $18,$18,$F8,$18,$F8,$18,$18,$18	; .
Char182: .db $36,$36,$36,$36,$F6,$36,$36,$36	; .
Char183: .db $00,$00,$00,$00,$FE,$36,$36,$36	; .
Char184: .db $00,$00,$F8,$18,$F8,$18,$18,$18	; .
Char185: .db $36,$36,$F6,$06,$F6,$36,$36,$36	; .
Char186: .db $36,$36,$36,$36,$36,$36,$36,$36	; .
Char187: .db $00,$00,$FE,$06,$F6,$36,$36,$36	; .
Char188: .db $36,$36,$F6,$06,$FE,$00,$00,$00	; .
Char189: .db $36,$36,$36,$36,$FE,$00,$00,$00	; .
Char190: .db $18,$18,$F8,$18,$F8,$00,$00,$00	; .
Char191: .db $00,$00,$00,$00,$F8,$18,$18,$18	; .
Char192: .db $18,$18,$18,$18,$1F,$00,$00,$00	; .
Char193: .db $18,$18,$18,$18,$FF,$00,$00,$00	; .
Char194: .db $00,$00,$00,$00,$FF,$18,$18,$18	; .
Char195: .db $18,$18,$18,$18,$1F,$18,$18,$18	; .
Char196: .db $00,$00,$00,$00,$FF,$00,$00,$00	; .
Char197: .db $18,$18,$18,$18,$FF,$18,$18,$18	; .
Char198: .db $18,$18,$1F,$18,$1F,$18,$18,$18	; .
Char199: .db $36,$36,$36,$36,$37,$36,$36,$36	; .
Char200: .db $36,$36,$37,$30,$3F,$00,$00,$00	; .
Char201: .db $00,$00,$3F,$30,$37,$36,$36,$36	; .
Char202: .db $36,$36,$F7,$00,$FF,$00,$00,$00	; .
Char203: .db $00,$00,$FF,$00,$F7,$36,$36,$36	; .
Char204: .db $36,$36,$37,$30,$37,$36,$36,$36	; .
Char205: .db $00,$00,$FF,$00,$FF,$00,$00,$00	; .
Char206: .db $36,$36,$F7,$00,$F7,$36,$36,$36	; .
Char207: .db $18,$18,$FF,$00,$FF,$00,$00,$00	; .
Char208: .db $36,$36,$36,$36,$FF,$00,$00,$00	; .
Char209: .db $00,$00,$FF,$00,$FF,$18,$18,$18	; .
Char210: .db $00,$00,$00,$00,$FF,$36,$36,$36	; .
Char211: .db $36,$36,$36,$36,$3F,$00,$00,$00	; .
Char212: .db $18,$18,$1F,$18,$1F,$00,$00,$00	; .
Char213: .db $00,$00,$1F,$18,$1F,$18,$18,$18	; .
Char214: .db $00,$00,$00,$00,$3F,$36,$36,$36	; .
Char215: .db $36,$36,$36,$36,$FF,$36,$36,$36	; .
Char216: .db $18,$18,$FF,$18,$FF,$18,$18,$18	; .
Char217: .db $18,$18,$18,$18,$F8,$00,$00,$00	; .
Char218: .db $00,$00,$00,$00,$1F,$18,$18,$18	; .
Char219: .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; .
Char220: .db $00,$00,$00,$00,$FF,$FF,$FF,$FF	; .
Char221: .db $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0	; .
Char222: .db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F	; .
Char223: .db $FF,$FF,$FF,$FF,$00,$00,$00,$00	; .
Char224: .db $00,$00,$76,$DC,$C8,$DC,$76,$00	; .
Char225: .db $38,$6C,$6C,$78,$6C,$66,$6C,$60	; .
Char226: .db $00,$FE,$C6,$C0,$C0,$C0,$C0,$00	; .
Char227: .db $00,$00,$FE,$6C,$6C,$6C,$6C,$00	; .
Char228: .db $FE,$60,$30,$18,$30,$60,$FE,$00	; .
Char229: .db $00,$00,$7E,$D8,$D8,$D8,$70,$00	; .
Char230: .db $00,$66,$66,$66,$66,$7C,$60,$C0	; .
Char231: .db $00,$76,$DC,$18,$18,$18,$18,$00	; .
Char232: .db $7E,$18,$3C,$66,$66,$3C,$18,$7E	; .
Char233: .db $3C,$66,$C3,$FF,$C3,$66,$3C,$00	; .
Char234: .db $3C,$66,$C3,$C3,$66,$66,$E7,$00	; .
Char235: .db $0E,$18,$0C,$7E,$C6,$C6,$7C,$00	; .
Char236: .db $00,$00,$7E,$DB,$DB,$7E,$00,$00	; .
Char237: .db $06,$0C,$7E,$DB,$DB,$7E,$60,$C0	; .
Char238: .db $38,$60,$C0,$F8,$C0,$60,$38,$00	; .
Char239: .db $78,$CC,$CC,$CC,$CC,$CC,$CC,$00	; .
Char240: .db $00,$7E,$00,$7E,$00,$7E,$00,$00	; .
Char241: .db $18,$18,$7E,$18,$18,$00,$7E,$00	; .
Char242: .db $60,$30,$18,$30,$60,$00,$FC,$00	; .
Char243: .db $18,$30,$60,$30,$18,$00,$FC,$00	; .
Char244: .db $0E,$1B,$1B,$18,$18,$18,$18,$18	; .
Char245: .db $18,$18,$18,$18,$18,$D8,$D8,$70	; .
Char246: .db $18,$18,$00,$7E,$00,$18,$18,$00	; .
Char247: .db $00,$76,$DC,$00,$76,$DC,$00,$00	; .
Char248: .db $38,$6C,$6C,$38,$00,$00,$00,$00	; .
Char249: .db $00,$00,$00,$18,$18,$00,$00,$00	; .
Char250: .db $00,$00,$00,$00,$18,$00,$00,$00	; .
Char251: .db $0F,$0C,$0C,$0C,$EC,$6C,$3C,$1C	; .
Char252: .db $78,$6C,$6C,$6C,$6C,$00,$00,$00	; .
Char253: .db $7C,$0C,$7C,$60,$7C,$00,$00,$00	; .
Char254: .db $00,$00,$3C,$3C,$3C,$3C,$00,$00	; .
Char255: .db $00,$10,$00,$00,$00,$00,$00,$00	; NULL

 .endLibrary