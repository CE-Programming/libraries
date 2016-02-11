#include "..\\..\\include\\relocation.inc"
#include "ti84pce.inc"

 .libraryName           "FILEIOC"       ; Name of library
 .libraryVersion        1               ; Version information (1-255)
 
 .function "ti_CloseAll",_CloseAll
 .function "ti_Open",_Open
 .function "ti_OpenVar",_OpenVar
 .function "ti_Close",_Close
 .function "ti_Write",_Write
 .function "ti_Read",_Read
 .function "ti_GetC",_GetChar
 .function "ti_PutC",_PutChar
 .function "ti_Delete",_Delete
 .function "ti_DeleteVar",_DeleteVar
 .function "ti_Seek",_Seek
 .function "ti_Resize",_Resize
 .function "ti_IsArchived",_IsArchived
 .function "ti_SetArchiveStatus",_SetArchiveStatus
 .function "ti_Tell",_Tell
 .function "ti_Rewind",_Rewind
 .function "ti_GetSize",_GetSize
 
 .beginDependencies
 .endDependencies
 
;-------------------------------------------------------------------------------
#define VATPtr0 $D0244E
#define VATPtr1 $D0257B
#define VATPtr2 $D0257E
#define VATPtr3 $D02581
#define VATPtr4 $D02584

#define varPtr0 $D0067E
#define varPtr1 $D00681
#define varPtr2 $D01FED
#define varPtr3 $D01FF3
#define varPtr4 $D01FF9
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
_CloseAll:
; Initializes the File IO library
; Arguments:
;  None
; Returns:
;  None
	or	a,a
	sbc	hl,hl
	ld	(VATPtr0),hl
	ld	(VATPtr1),hl
	ld	(VATPtr2),hl
	ld	(VATPtr3),hl
	ld	(VATPtr4),hl
	ld	(varPtr0),hl
	ld	(varPtr1),hl
	ld	(varPtr2),hl
	ld	(varPtr3),hl
	ld	(varPtr4),hl
	ld	hl,VarOffset0 \.r
	ld	bc,15
	jp	_memclear
 
;-------------------------------------------------------------------------------
_Resize:
; Resizes an AppVar
; Arguments:
;  __frame_arg0 : New size
;  __frame_arg1 : Slot number
; Returns:
;  Resized size if no failure
	pop	de
	pop	hl								; hl=newSize
	pop	bc							 ;	a=slot
	ld	a,c
	ld	(CurrentSlot_ASM),a \.r
	push	bc
	push	hl
	push	de
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
	push	hl
	call	_CheckInRAM_ASM \.r
	ld	a,l
	pop	hl
	jp	z,_ReturnNULL \.r
	ld	de,$FFFF-30
	or	a,a
	sbc	hl,de
	add	hl,de
	push	af
	push	hl
	ld	bc,0
	call	_SetSlotOffset_ASM \.r
	pop	hl
	pop	af
	jp	nc,_ReturnNULL \.r	; return if too big
	push	hl
	call	_GetSlotSize_ASM \.r
	pop	hl
	or	a,a
	sbc	hl,bc
	ld	(ResizeBytes),hl \.r
	jr	z,NoResize
	jr	c,DecreaseSize
IncreaseSize:
	call	_enoughmem
	jp	c,_ReturnNULL \.r
	ex	de,hl
	call	AddMemoryToVar \.r
	jr	NoResize
DecreaseSize:
	push	hl
	pop	bc
	or	a,a
	sbc	hl,hl
	sbc	hl,bc
	ld	(ResizeBytes),hl \.r
	call	DeleteMemoryFromVar \.r
NoResize:
	ld	hl,(ResizeBytes) \.r
	ret
 
;-------------------------------------------------------------------------------
_IsArchived:
; Checks if a varaible is archived
; Arguments:
;  __frame_arg0 : Slot number
; Returns:
;  0 if not archived
	pop	de
	pop	hl
	ld	a,l
	ld	(CurrentSlot_ASM),a \.r
	push	hl
	push	de
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNULL \.r
_CheckInRAM_ASM:
	call	_GetSlotVATPtr_ASM \.r
	ld	hl,(hl)
	push	bc
	ld	bc,-5
	add	hl,bc
	pop	bc
	ld	a,(hl)
	or	a,a
	sbc	hl,hl
	cp	a,$D0
	ret	nc
	inc	hl
	ret
 
;-------------------------------------------------------------------------------
_OpenVar:
; Opens a variable
; Arguments:
;  __frame_arg0 : Pointer to varaible name
;  __frame_arg1 : Opening flags
;  __frame_arg2 : Varaible Type
; Returns:
;  Slot number if no error
	push	ix
	ld	ix,0
	add	ix,sp
	ld	a,(ix+__frame_arg3)
	pop	ix
	jr	+_
;-------------------------------------------------------------------------------
_Open:
; Opens an AppVar
; Arguments:
;  __frame_arg0 : Pointer to varaible name
;  __frame_arg1 : Opening flags
; Returns:
;  Slot number if no error
	ld	a,$15
_:	ld	(varType),a \.r
	push	ix
	ld	ix,0
	add	ix,sp
	xor	a,a
	ld	hl,VATPtr0
	ld	hl,(hl)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,VATPtr1
	ld	hl,(hl)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,VATPtr2
	ld	hl,(hl)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,VATPtr3
	ld	hl,(hl)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,VATPtr4
	ld	hl,(hl)
	inc	a
	sbc	hl,de
	jr	z,+_
	jp	_returnNULL_PopIX \.r
_:	ld	(CurrentSlot_ASM),a \.r
	ld	hl,(ix+__frame_arg0)
	ld	de,op1+1
	ld	bc,9
	ldir
	xor	a,a
	ld	(de),a
	ld	hl,(ix+__frame_arg1)
	ld	a,(hl)
	cp	a,'w'
	jr	nz,nooverwite
	call	_pushop1
	call	_chkfindsym
	call	nc,_delvararc
	call	_popop1
nooverwite:
	ld	hl,(ix+__frame_arg1)
	ld	a,(hl)
	cp	a,'r'
	jr	z,+_
	cp	a,'a'
	jr	z,+_
	cp	a,'w'
	jp	nz,_returnNULL_PopIX \.r
_:	inc	hl
	ld	a,(hl)
	cp	a,'+'
	jr	nz,++_
archivevar:
	call	_pushop1
	call	_chkfindsym
	call	_chkinram
	jr	z,+_
	inc	de
	inc	de
	or	a,a
	sbc	hl,hl
	ex	de,hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	call	_enoughmem
	jp	c,_returnNULL_PopIX \.r
	call	_popop1
	call	_pushop1
	call	_arc_Unarc
	call	_popop1
	jr	archivevar
_:	call	_popop1
_:	call	_chkfindsym
	jr	c,+_
	call	_chkinram
	jr	z,_SavePtrs_ASM
	push	hl
	ld	hl,(ix+__frame_arg1)
	ld	a,(hl)
	cp	a,'r'
	pop	hl
	jp	nz,_returnNULL_PopIX \.r
	jr	_SavePtrs_ASM
	
_:	ld	hl,(ix+__frame_arg1)
	ld	a,(hl)
	cp	a,'r'
	jp	z,_returnNULL_PopIX \.r
	or	a,a
	sbc	hl,hl
varType =$+1
	ld	a,0
	call	_createvar
_SavePtrs_ASM:
	push	hl
	call	_GetSlotVATPtr_ASM \.r
	pop	bc
	ld	(hl),bc
	call	_GetSlotVarPtr_ASM \.r
	ld	(hl),de
	ld	hl,(ix+__frame_arg1)				; a=flags
	ld	a,(hl)
	ld	bc,0
	cp	a,'a'
	call	z,_GetSlotSize_ASM \.r
	call	_SetSlotOffset_ASM \.r
	pop	ix
	ld	a,(CurrentSlot_ASM) \.r
	or	a,a
	sbc	hl,hl
	ld	l,a
	ret
 
;-------------------------------------------------------------------------------
_SetArchiveStatus:
; Sets the archive status of a slot
; Arguments:
;  __frame_arg0 : Boolean value
;  __frame_arg1 : Slot number
; Returns:
;  None
	ld	a,$15
	ld	(varTypeArc),a \.r
	pop	hl
	pop	bc
	pop	de
	ld	a,e
	ld	(CurrentSlot_ASM),a \.r
	push	de
	push	bc
	push	hl
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNULL \.r
	ld	a,c
	push	af
	call	_GetSlotVATPtr_ASM \.r
	ld	hl,(hl)
	ld	bc,-6
	add	hl,bc
	ld	b,(hl)
	ld	de,op1+1
	dec	hl
_:	ld	a,(hl)
	ld	(de),a
	inc	de
	dec	hl
	djnz	-_
	xor	a,a
	ld	(de),a
varTypeArc =$+1
	ld	a,0
	ld	(op1),a
	call	_chkfindsym
	call	_chkinram
	push	af
	ld	bc,0
	call	_GetSlotVATPtr_ASM \.r
	ld	(hl),bc
	pop	bc
	pop	af
	or	a,a
	jr	z,SetNotArchived
SetArchived:
	push	bc
	pop	af
	jp	z,_arc_unarc
	ret
SetNotArchived:
	push	bc
	pop	af
	jp	nz,_arc_unarc
	ret
 
;-------------------------------------------------------------------------------
_Write:
; Performs an fwrite to an AppVar
; Arguments:
;  __frame_arg0 : Pointer to data to write
;  __frame_arg1 : Size of entries (bytes)
;  __frame_arg2 : Number of entries
;  __frame_arg3 : Slot number
; Returns:
;  Number of bytes written if success
	push	ix
	ld	ix,0
	add	ix,sp
	ld	bc,(ix+__frame_arg1)
	ld	hl,(ix+__frame_arg2)
	call	$000228			; hl*bc
	ex	de,hl
	ld	a,(ix+__frame_arg3)
	ld	(CurrentSlot_ASM),a \.r
	ld	hl,(ix+__frame_arg0)
	pop	ix
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNULL \.r
	push	hl
	call	_CheckInRAM_ASM \.r
	ld	a,l
	pop	hl
	jp	z,_ReturnNULL \.r
	ld	bc,0
_:	ld	a,(hl)
	push	hl
	push	de
	push	bc
	ld	(charIn),a \.r
	call	_PutChar_ASM \.r
	call	_SetAToHLU
	bit	7,a
	jr	nz,+_
	pop	bc
	pop	de
	pop	hl
	inc	hl
	inc	bc
	dec	de
	ld	a,e
	or	a,d
	jr	nz,-_
	ex	de,hl
	ret
_:	pop	hl
	pop	de
	pop	bc
	ret
 
;-------------------------------------------------------------------------------
_Read:
; Performs an fread to an AppVar
; Arguments:
;  __frame_arg0 : Pointer to data to read into
;  __frame_arg1 : Size of entries (bytes)
;  __frame_arg2 : Number of entries
;  __frame_arg3 : Slot number
; Returns:
;  Number of bytes read if success
	push	ix
	ld	ix,0
	add	ix,sp
	ld	bc,(ix+__frame_arg1)
	ld	hl,(ix+__frame_arg2)
	call	$000228			; hl*bc
	ex	de,hl
	ld a,(ix+__frame_arg3)
	ld (CurrentSlot_ASM),a \.r
	ld hl,(ix+__frame_arg0)
	pop ix
	call _CheckIfSlotOpen \.r
	jp z,_ReturnNULL \.r
	ld bc,0
_:	push hl
	push de
	push bc
	call _GetChar_ASM \.r
	call _SetAToHLU
	bit 7,a
	jr nz,+_
	ld a,l
	pop bc
	pop de
	pop hl
	ld (hl),a
	inc hl
	inc bc
	dec de
	ld a,e
	or a,d
	jr nz,-_
	ex de,hl
	ret
_:	pop hl
	pop de
	pop bc
	ret

;-------------------------------------------------------------------------------
_GetChar:
; Performs an fgetc to an AppVar
; Arguments:
;  __frame_arg0 : Slot number
; Returns:
;  Character read if success
	pop	de
	pop	bc
	ld	a,c
	ld	(CurrentSlot_ASM),a \.r
	push	bc
	push	de
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
_GetChar_ASM:
	call	_GetSlotSize_ASM \.r
	push	bc
	call	_GetSlotOffset_ASM \.r
	pop	hl
	or	a,a
	sbc	hl,bc	; size-offset
	jp	c,_ReturnNEG1L \.r
	jp	z,_ReturnNEG1L \.r
	push	bc
	call	_GetSlotVarPtr_ASM \.r
	ld	hl,(hl)
	add	hl,bc
	inc	hl
	inc	hl ; bypass size bytes
	pop	bc
	inc	bc
	ld	a,(hl)
	push	af
	call	_SetSlotOffset_ASM \.r
	pop	af
	or	a,a
	sbc	hl,hl
	ld	l,a
	ret
 
;-------------------------------------------------------------------------------
_Seek:
; Performs an fseek on an AppVar
; Arguments:
;  __frame_arg0 : Posistion to seek to
;  __frame_arg1 : Origin position
;  __frame_arg2 : Slot number
; Returns:
;  -1 if failure
	push ix
	ld ix,0
	add ix,sp
	ld de,(ix+__frame_arg0)
	ld l,(ix+__frame_arg1)
	ld a,(ix+__frame_arg2)
	pop ix
	ld (CurrentSlot_ASM),a \.r
	call _CheckIfSlotOpen \.r
	jp z,_ReturnNEG1L \.r
	ld a,l
	or a,a
	jr z,SeekCur
	dec a
	jr z,SeekEnd
	dec a
	jp nz,_ReturnNEG1L \.r
_SeekHandler_ASM:
	call	_GetSlotSize_ASM \.r
	push	bc
	pop	hl
	or	a,a
	sbc	hl,de 
	push	de
	pop	bc
	jp	c,_ReturnNEG1L \.r
	jp	_SetSlotOffset_ASM \.r
SeekCur:
	push	de
	call	_GetSlotOffset_ASM \.r
	pop	hl
	add	hl,bc
	ex	de,hl
	jr	_SeekHandler_ASM
SeekEnd:
	push	de
	call	_GetSlotSize_ASM \.r
	pop	hl
	add	hl,bc
	ex	de,hl
	jr	_SeekHandler_ASM

;-------------------------------------------------------------------------------
_PutChar:
; Performs an fputc on an AppVar
; Arguments:
;  __frame_arg0 : Character to place
;  __frame_arg1 : Slot number
; Returns:
;  Character written if no failure
	pop	de
	pop	hl
	ld	a,l
	ld	(charIn),a \.r
	pop	bc
	ld	a,c
	ld	(CurrentSlot_ASM),a \.r
	push	bc
	push	hl
	push	de
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
	push	hl
	call	_CheckInRAM_ASM \.r
	ld	a,l
	pop	hl
	jp	z,_ReturnNEG1L \.r
_PutChar_ASM:
	call	_GetSlotSize_ASM \.r
	push	bc
	call	_GetSlotOffset_ASM \.r
	pop	hl
	or	a,a
	sbc	hl,bc
	jp	c,_ReturnNEG1L \.r
	jr	nz,noIncrement
Increment:
	push	bc
	inc	hl
	ld	(ResizeBytes),hl \.r
	call	_enoughmem
	pop	bc
	jp	c,_ReturnNEG1L \.r
	push	bc
	ex	de,hl
	call	AddMemoryToVar \.r
	pop	bc
noIncrement:
	call	_GetSlotVarPtr_ASM \.r
	push	bc
	ld	hl,(hl)
	add	hl,bc
	inc	hl
	inc	hl
charIn	=$+1
	ld	(hl),0
	pop	bc
	inc	bc
	call	_SetSlotOffset_ASM \.r
	ld	a,(charIn) \.r
	or	a,a
	sbc	hl,hl
	ld	l,a
	ret
 
;-------------------------------------------------------------------------------
_DeleteVar:
; Deletes an arbitrary variable
; Arguments:
;  __frame_arg0 : Pointer to variable name
;  __frame_arg1 : Variable type
; Returns:
;  0 if failure
	pop	hl
	pop	de
	pop	bc
	ld	a,c
	push	bc
	push	de
	push	hl
	jr	+_

;-------------------------------------------------------------------------------
_Delete:
; Deletes an AppVar
; Arguments:
;  __frame_arg0 : Pointer to AppVar name
; Returns:
;  0 if failure
	ld	a,$15
_:	ld	(varTypeDelete),a \.r
	pop	de
	pop	hl
	push	hl
	push	de
	ld	de,op1+1
	ld	bc,9
	ldir
	xor	a,a
	ld	(de),a
varTypeDelete	=$+1
	ld	a,0
	ld	(op1),a
	call	_chkfindsym
	jp	c,_ReturnNULL \.r
	call	_delvararc
	or	a,a
	sbc	hl,hl
	inc	hl
	ret
 
;-------------------------------------------------------------------------------
_Rewind:
; Performs an frewind on a varaible
; Arguments:
;  __frame_arg0 : Slot number
; Returns:
;  -1 if failure
	pop	hl
	pop	bc
	ld	a,c
	push	bc
	push	hl
	ld	(CurrentSlot_ASM),a \.r
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
	ld	bc,0
	call	_SetSlotOffset_ASM \.r
	or	a,a
	sbc	hl,hl
	ret

;-------------------------------------------------------------------------------
_Tell:
; Performs an ftell on a varaible
; Arguments:
;  __frame_arg0 : Slot number
; Returns:
;  -1 if failure
	pop	hl
	pop	bc
	ld	a,c
	push	bc
	push	hl
	ld	(CurrentSlot_ASM),a \.r
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
	call	_GetSlotOffset_ASM \.r
	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------
_GetSize:
; Gets the size of an AppVar
; Arguments:
;  __frame_arg0 : Slot number
; Returns:
;  -1 if failure
	pop	hl
	pop	bc
	ld	a,c
	push	bc
	push	hl
	ld	(CurrentSlot_ASM),a \.r
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
	call	_GetSlotSize_ASM \.r
	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------
_Close:
; Closes an open slot varaible
; Arguments:
;  __frame_arg0 : Slot number
; Returns:
;  None
	pop	hl
	pop	bc
	ld	a,c
	push	bc
	push	hl
	ld	(CurrentSlot_ASM),a \.r
	call	_GetSlotVATPtr_ASM \.r
	ex	de,hl
	xor	a,a
	sbc	hl,hl
	ex	de,hl
	ld	(hl),de
	ret
 
;-------------------------------------------------------------------------------
; Internal library routines
;-------------------------------------------------------------------------------
 
;-------------------------------------------------------------------------------
AddMemoryToVar:
	call _GetSlotVarPtr_ASM \.r
	push hl
	ld hl,(hl)
	push hl
	 call _GetSlotOffset_ASM \.r
	pop hl
	add hl,bc
	inc hl
	inc hl
	ex de,hl
	ld hl,(ResizeBytes) \.r
	call _InsertMem
	pop hl
	ld hl,(hl)
	push hl
	ex de,hl
	or a,a
	sbc hl,hl
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	ld bc,(ResizeBytes) \.r
	add hl,bc						; increase by 5
	jr SaveSize
DeleteMemoryFromVar:
	call _GetSlotVarPtr_ASM \.r
	push hl
	ld hl,(hl)
	push hl
	 call _GetSlotOffset_ASM \.r
	pop hl
	add hl,bc
	inc hl
	inc hl
	ld de,(ResizeBytes) \.r
	call _DelMem
	pop hl
	ld hl,(hl)
	push hl
	ex de,hl
	or a,a
	sbc hl,hl
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	ld bc,(ResizeBytes) \.r
	or a,a
	sbc hl,bc								; decrease amount
SaveSize:
	ex de,hl
	pop hl										; pointer to size bytes location
	ld (hl),e
	inc hl
	ld (hl),d								; write new size.
	ret
 
_returnNULL_PopIX:
	pop	ix
_ReturnNULL:
	xor	a,a
	sbc	hl,hl
	ret
_ReturnNEG1L:
	xor	a,a
	sbc	hl,hl
	dec	hl
	ret
_CheckIfSlotOpen:
	push	hl
	push	bc
	ld	c,a
	call	_GetSlotVATPtr_ASM \.r
	ld	hl,(hl)
	add	hl,de 
	or	a,a 
	sbc	hl,de
	ld	a,c
	pop	bc
	pop	hl
	ret
_GetSlotVATPtr_ASM:
	ld	a,(CurrentSlot_ASM) \.r
	dec	a
	ld	hl,VATPtr0
	or	a,a
	ret	z
	ld	hl,VATPtr1
	dec	a
	ret	z
	ld	hl,VATPtr2
	dec	a
	ret	z
	ld	hl,VATPtr3
	dec	a
	ret	z
	ld	hl,VATPtr4
	ret
_GetSlotSizePtr_ASM:
_GetSlotVarPtr_ASM:
	ld	a,(CurrentSlot_ASM) \.r
	dec	a
	ld	hl,varPtr0
	or	a,a
	ret	z
	ld	hl,varPtr1
	dec	a
	ret	z
	ld	hl,varPtr2
	dec	a
	ret	z
	ld	hl,varPtr3
	dec	a
	ret	z
	ld	hl,varPtr4
	ret
_GetSlotOffsetPtr_ASM:
	push	bc
	ld	a,(CurrentSlot_ASM) \.r
	dec	a
	ld	l,a
	ld	h,3
	mlt	hl
	ld	bc,VarOffset0 \.r
	add	hl,bc
	pop	bc
	ret
_GetSlotSize_ASM:
	call	_GetSlotSizePtr_ASM \.r
	ld	hl,(hl)
	ld	bc,0
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ret
_GetSlotOffset_ASM:
	call	_GetSlotOffsetPtr_ASM \.r
	ld	bc,(hl)
	ret
_SetSlotOffset_ASM:
	call	_GetSlotOffsetPtr_ASM \.r
	ld	(hl),bc
	ret
 
;-------------------------------------------------------------------------------
; Internal library data
;-------------------------------------------------------------------------------

CurrentSlot_ASM:
	.db 0
ResizeBytes:
	.dl 0
VarOffset0:
	.dl 0
VarOffset1:
	.dl 0
VarOffset2:
	.dl 0
VarOffset3:
	.dl 0
VarOffset4:
	.dl 0
 
 .endLibrary