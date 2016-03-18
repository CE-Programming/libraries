;-------------------------------------------------------------------------------
; Eventually I would like to transform this routine to support arbitary degrees:
; This would be rather slow though.
; int xt,yt;
; int xs,ys;
; float sinma = sin(-angle);
; float cosma = cos(-angle);
; int hwidth = width / 2;
; int hheight = height / 2;
;
; for(int x = 0; x < width; x++) {
;	for(int y = 0; y < height; y++) {
;		xt = x - hwidth;
;		yt = y - hheight;
;		
;		xs = (int)round((cosma * xt - sinma * yt) + hwidth);
;		ys = (int)round((sinma * xt + cosma * yt) + hheight);
;
;		if(xs >= 0 && xs < width && ys >= 0 && ys < height) {
;			/* set target pixel (x,y) to color at (xs,ys) */
;		} else {
;			/* set target pixel (x,y) to sprite transparent color */
;		}
;	}
;}
;-------------------------------------------------------------------------------
_RotateSprite:
; Draws a scaled sprite to the screen
; Arguments:
;  __frame_arg0 : Pointer to sprite source
;  __frame_arg1 : Pointer to sprite copy destination
;  __frame_arg2 : Width
;  __frame_arg3 : Height
;  __frame_arg4 : Rotation amount (90,-90,180) for now
; Returns:
;  Pointer to sprite copy destination
	ret

;-------------------------------------------------------------------------------
_FlipSpriteHoriz:
; Draws a scaled sprite to the screen
; Arguments:
;  __frame_arg0 : Pointer to sprite source
;  __frame_arg1 : Pointer to sprite copy destination
;  __frame_arg2 : Width
;  __frame_arg3 : Height
; Returns:
;  Pointer to sprite copy destination
	ret
	
;-------------------------------------------------------------------------------
_FlipSpriteVert:
; Draws a scaled sprite to the screen
; Arguments:
;  __frame_arg0 : Pointer to sprite source
;  __frame_arg1 : Pointer to sprite copy destination
;  __frame_arg2 : Width
;  __frame_arg3 : Height
; Returns:
;  Pointer to sprite copy destination
	push	ix
	ld	ix,0
	add	ix,sp
	ld	a,(ix+__frame_arg2)
	ld	(flipSpriteWidth_ASM),a \.r
	ld	h,a
	ld	l,(ix+__frame_arg3)
	mlt	hl
	push	hl
	
	ld	de,(ix+__frame_arg0)
	ld	hl,(ix+__frame_arg1)
	ld	b,(ix+__frame_arg3)
_:	push	bc
flipSpriteWidth_ASM =$+1
	ld	bc,0
	
	pop	bc
	djnz	-_
	pop	ix
	ret
	
;-------------------------------------------------------------------------------
_NoClipDrawScaledSprite:
; Draws a scaled sprite to the screen
; Arguments:
;  __frame_arg0 : Pointer to sprite
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width -- 8bits
;  __frame_arg4 : Height -- 8bits
;  __frame_arg5 : Width Scale (integer)
;  __frame_arg6 : Height Scale (integer)
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
	ld	c,(ix+__frame_arg3)
	ld	b,(ix+__frame_arg5)
	ld	a,b
	ld	(NoClipSprScaledWidth),a \.r
	ld	a,c
	mlt	bc
	ld	(NoClipSprScaledCopyAmt),bc \.r
	or	a,a
	sbc	hl,bc
	ld	(NoClipSprScaledMoveAmt),hl \.r
	ld	(NoClipSprScaledLineNext),a \.r
	ld	a,(ix+__frame_arg6)
	ld	(NoClipHeightScale),a \.r
	ld	b,(ix+__frame_arg4)
	ld	hl,(ix+__frame_arg0)
_:	push	bc
NoClipSprScaledLineNext =$+1
	ld	c,0
	push	de
NoClipSprScaledWidth =$+1
_:	ld	b,0
	ld	a,(hl)
_:	ld	(de),a
	inc	de
	djnz	-_
	inc	hl
	dec	c
	jr	nz,--_
	ex	de,hl
NoClipSprScaledMoveAmt =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
NoClipHeightScale =$+1
	ld	a,0
	push	hl
	pop	ix
	pop	hl
_:	dec	a
	jr	z,+_
	push	bc
NoClipSprScaledCopyAmt = $+1
	ld	bc,0
	ldir
	pop	bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	add	hl,bc
	jr	-_
_:	lea	hl,ix
	pop	bc
	djnz	-----_
	pop	ix
	ret

;-------------------------------------------------------------------------------
_NoClipDrawScaledTransparentSprite:
; Draws a scaled sprite to the screen with transparency
; Arguments:
;  __frame_arg0 : Pointer to sprite
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width -- 8bits
;  __frame_arg4 : Height -- 8bits
;  __frame_arg5 : Width Scale (integer)
;  __frame_arg6 : Height Scale (integer)
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
	ld	c,(ix+__frame_arg3)
	ld	b,(ix+__frame_arg5)
	ld	a,b
	ld	(ClipSprScaledWidth),a \.r
	ld	a,c
	mlt	bc
	or	a,a
	sbc	hl,bc
	ld	(ClipSprScaledMoveAmt),hl \.r
	ld	(ClipSprScaledLineNext),a \.r
	ld	b,(ix+__frame_arg4)
	ld	hl,(ix+__frame_arg0)
	ld	a,(ix+__frame_arg6)
	ld	(ClipHeightScale),a \.r
_:	push	bc
ClipHeightScale =$+1
	ld	a,0
_:	dec	a
	jr	z,++++_
	push	af
	push	hl
ClipSprScaledLineNext =$+1
	ld	c,0
ClipSprScaledWidth =$+1
_:	ld	b,0
	ld	a,(hl)
ClipSprScaledTransColor =$+1
	cp	a,0
	jr	z,+++_
_:	ld	(de),a
	inc	de
	djnz	-_
_:	inc	hl
	dec	c
	jr	nz,---_
	ex	de,hl
ClipSprScaledMoveAmt =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
	push	hl
	pop	ix
	pop	hl
	pop	af
	jr	----_
_:	lea	hl,ix
	pop	bc
	djnz	------_
	pop	ix
	ret
_:	inc	de
	djnz	-_
	jr	--_
	
	
;-------------------------------------------------------------------------------
_ClipDrawTransparentSprite:
; Draws a transparent sprite with clipping
; Arguments:
;  __frame_arg0 : Pointer to sprite
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width -- 8bits
;  __frame_arg4 : Height -- 8bits
; Returns:
;  None
	push	ix
	call	_ClipDraw_ASM \.r
	sub	a,(ix+__frame_arg3)	; how much to add to the sprite per iterations
	ld	(ClipSprTransNextAmt),a \.r
	or	a,a
	sbc	hl,hl
	ex	de,hl
	ld	hl,lcdWidth
	ld	e,(ix+__frame_arg3)
	ld	a,e
	sbc	hl,de
	ld	(ClipSprTransMoveAmt),hl \.r
	ld	(ClipSprTransNextLine),a \.r
	ld	de,(ix+__frame_arg1)
	ld	l,(ix+__frame_arg2)
	ld	h,160
	mlt	hl
	add	hl,hl
	add	hl,de
	ld	de,(currentDrawingBuffer)
	add	hl,de
	ex	de,hl
	ld	b,(ix+__frame_arg4)
	ld	hl,(ix+__frame_arg0)
ClipSprTransColor =$+1
	ld	c,0
_:	push	bc
ClipSprTransNextLine =$+1
	ld	b,0
_:	ld	a,(hl)
	cp	a,c
	jr	z,+_
	ld	(de),a
_:	inc	de
	inc	hl
	djnz	--_
	ex	de,hl
ClipSprTransMoveAmt =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
ClipSprTransNextAmt =$+1
	ld	bc,0
	add	hl,bc
	pop	bc
	djnz	---_
	pop	ix
	ret
	
;-------------------------------------------------------------------------------
_ClipDrawSprite:
; Places an sprite on the screen as fast as possible with clipping
; Arguments:
;  __frame_arg0 : Pointer to sprite
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width -- 8bits
;  __frame_arg4 : Height -- 8bits
; Returns:
;  None
	push	ix
	call	_ClipDraw_ASM \.r
	sub	a,(ix+__frame_arg3)	; how much to add to the sprite per iterations
	ld	(ClipSprNextAmt),a \.r
	or	a,a
	sbc	hl,hl
	ex	de,hl
	ld	hl,lcdWidth
	ld	e,(ix+__frame_arg3)
	ld	a,e
	sbc	hl,de
	ld	(ClipSprMoveAmt),hl \.r
	ld	(ClipSprLineNext),a \.r
	ld	de,(ix+__frame_arg1)
	ld	l,(ix+__frame_arg2)
	ld	h,160
	mlt	hl
	add	hl,hl
	add	hl,de
	ld	de,(currentDrawingBuffer)
	add	hl,de
	ex	de,hl
	ld	b,(ix+__frame_arg4)
	ld	hl,(ix+__frame_arg0)
_:	push	bc
ClipSprLineNext =$+1
	ld	bc,0
	ldir
	ex	de,hl
ClipSprMoveAmt =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
ClipSprNextAmt =$+1
	ld	bc,0
	add	hl,bc
	pop	bc
	djnz	-_
	pop	ix
	ret
	
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
NoClipSprTransColor =$+1
	ld	c,0
_:	push	bc
NoClipSprTransNextLine =$+1
	ld	b,0
_:	ld	a,(hl)
	cp	a,c
	jr	z,+_
	ld	(de),a
_:	inc	de
	inc	hl
	djnz	--_
	ex	de,hl
NoClipSprTransMoveAmt =$+1
	ld	bc,0
	add	hl,bc
	ex	de,hl
	pop	bc
	djnz	---_
	ret
	
;-------------------------------------------------------------------------------
_ClipDraw_ASM:
; Clipping stuff
; Arguments:
;  __frame_arg0 : Pointer to sprite
;  __frame_arg1 : X Coord
;  __frame_arg2 : Y Coord
;  __frame_arg3 : Width -- 8bits
;  __frame_arg4 : Height -- 8bits
; Returns:
;  None
	ld	ix,3
	add	ix,sp
	ld	a,(ix+__frame_arg3)
	sbc	hl,hl
	ld	l,a
	ld	(ix+__frame_arg3),hl
	ld	l,(ix+__frame_arg4)
	ld	(ix+__frame_arg4),hl
	ld	(tmpSpriteWidth_ASM),a \.r
	ld	de,(ix+__frame_arg2)
	ld	hl,(_ymin) \.r
	sbc	hl,de
	jp	m,NoTopClipNeeded_ASM \.r
	jp	z,NoTopClipNeeded_ASM \.r
	ld	a,l
	ld	de,(ix+__frame_arg2)
	ld	hl,(ix+__frame_arg4)
	add	hl,de
	bit	7,h
	jp	nz,_ReturnRestoreIX_ASM \.r
	ld	hl,(ix+__frame_arg4)
	add	hl,de
	ld	(ix+__frame_arg4),hl
	ld	l,a
	ld	h,(ix+__frame_arg3)
	mlt	hl
	ld	de,(ix+__frame_arg0)
	add	hl,de
	ld	(ix+__frame_arg0),hl
	ld	hl,(_ymin) \.r
	ld	(ix+__frame_arg2),hl
NoTopClipNeeded_ASM:
	ld	hl,(ix+__frame_arg2)
	ld	de,(_ymax) \.r
	call	_SignedCompare_ASM \.r
	jp	nc,_ReturnRestoreIX_ASM \.r
	ld	de,(ix+__frame_arg2)
	ld	hl,(ix+__frame_arg4)
	add	hl,de
	ld	de,(_ymax) \.r
	call	_SignedCompare_ASM \.r
	jp	c,NoBottomClipNeeded_ASM \.r
	ld	hl,(_ymax) \.r
	ld	de,(ix+__frame_arg2)
	or	a,a
	sbc	hl,de
	ld	(ix+__frame_arg4),hl
NoBottomClipNeeded_ASM:
	ld	hl,(ix+__frame_arg1)
	ld	de,(_xmin) \.r
	call	_SignedCompare_ASM \.r
	jp	nc,NoLeftClip_ASM \.r
	ld	hl,(ix+__frame_arg1)
	ld	de,(ix+__frame_arg3)
	add	hl,de
	ld	de,(_xmin) \.r
	ex	de,hl
	call	_SignedCompare_ASM \.r
	jp	nc,_ReturnRestoreIX_ASM \.r
	ld	de,(ix+__frame_arg1)
	ld	hl,(ix+__frame_arg0)
	or	a,a
	sbc	hl,de
	ld	(ix+__frame_arg0),hl
	ld	hl,(ix+__frame_arg3)
	add	hl,de
	jp	p,_ReturnRestoreIX_ASM \.r
	ld	(ix+__frame_arg3),hl
	ld	de,(_xmin) \.r
	ld	(ix+__frame_arg1),de
NoLeftClip_ASM:
	ld	hl,(ix+__frame_arg1)
	ld	de,(_xmax) \.r
	call	_SignedCompare_ASM \.r
	jp	nc,_ReturnRestoreIX_ASM \.r
	ld	hl,(ix+__frame_arg1)
	ld	de,(ix+__frame_arg3)
	add	hl,de
	ld	de,(_xmax) \.r
	ex	de,hl
	call	_SignedCompare_ASM \.r
	jp	nc,NoRightClip_ASM \.r
	ld	hl,(_xmax) \.r
	ld	de,(ix+__frame_arg1)
	or	a,a
	sbc	hl,de
	ld	(ix+__frame_arg3),hl
NoRightClip_ASM:
tmpSpriteWidth_ASM =$+1
	ld	a,0
	ret