#include "..\..\..\include\relocation.inc"
#include "..\..\..\include\ti84pce.inc"

 .libraryName           "FILEIOC"       ; Name of library
 .libraryVersion        2               ; Version information (1-255)
 
;-------------------------------------------------------------------------------
; v1 functions -- can no longer move/add, but can fix
;-------------------------------------------------------------------------------
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
;-------------------------------------------------------------------------------
; v2 functions
;-------------------------------------------------------------------------------
 .function "ti_GetTokenString",_GetTokenString
 .function "ti_GetDataPtr",_GetDataPtr
 .function "ti_Detect",_Detect
 .function "ti_DetectVar",_DetectVar

 .beginDependencies
 .endDependencies

;-------------------------------------------------------------------------------
; Used throughout the library
varOpenType	equ 0E30C08h
currSlot	equ 0E30C11h
resizeBytes	equ 0E30C0Eh
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
#define VATPtr0	$D0244E
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
	jp	_MemClear

;-------------------------------------------------------------------------------
_Detect:
; Finds an AppVar that starts with some data
; Arguments:
;  arg0 : address of pointer to being search
;  arg1 : pointer to null terminated string of data to search for
	pop	hl
	pop	de
	push	de
	push	hl
	ld	a,e
	jr	+_

;-------------------------------------------------------------------------------
_DetectVar:
; Finds a varaible that starts with some data
;  arg0 : address of pointer to being search
;  arg1 : pointer to null terminated string of data to search for
;  arg2 : type of varaible to search for
	ld	a,appVarObj
_:	ld	(DetectType_SMC),a
	push	ix
	ld	ix,0
	add	ix,sp
	ld	hl,(ix+9)
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	z,finish
	ld	hl,(ix+6)
	ld	hl,(hl)
	add	hl,bc
	or	a,a
	sbc	hl,bc
	jr	nz,fdetect
	ld	hl,(progPtr)
fdetect:
	ld	de,(pTemp)
	or	a
	sbc	hl,de
	jr	c,finish
	jr	z,finish
	add	hl,de
	jr	fcontinue

finish:	xor	a,a
	sbc	hl,hl
	pop	ix
	ret

fcontinue:
	push	hl
	ld	a,(hl)
DetectType_SMC =$+1
	cp	a,appVarObj
	jr	nz,fskip
fgoodtype:
	dec	hl
	dec	hl
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	a,(hl)
	call	_SetDEUToA
	ex	de,hl
	cp	a,$D0
	jr	nc,finRAM
	ld	de,9
	add	hl,de				; skip archive VAT stuff
	ld	e,(hl)
	add	hl,de
	inc	hl
finRAM:	inc	hl
	inc	hl				; hl -> data
	ld	bc,(ix+9)
_:	ld	a,(bc)
	or	a,a
	jr	z,ffound
	cp	a,(hl)
	inc	bc
	inc	de
	inc	hl
	jr	z,-_				; check the string at the memory
fskip:	pop	hl
	call	fbypassname \.r
	jr	fdetect
	
ffound:	pop	hl
	call	fbypassname \.r
	ex	de,hl
	ld	hl,(ix+6)
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	z,finish
	ld	(hl),de
	ld	hl,OP6
	pop	ix
	ret

fbypassname:					; bypass the name in the VAT (also used for setting the string name)
	ld	de,OP6
	ld	bc,-6
	add	hl,bc
	ld	b,(hl)
	dec	hl
_:	ld	a,(hl)
	ld	(de),a
	dec	hl
	inc	de
	djnz	-_
	xor	a,a
	ld	(de),a
	ret
	
;-------------------------------------------------------------------------------
_Resize:
; Resizes an AppVar
; Arguments:
;  arg0 : New size
;  arg1 : Slot number
; Returns:
;  Resized size if no failure
	pop	de
	pop	hl				; hl = newSize
	pop	bc				; a = slot
	ld	a,c
	push	bc
	push	hl
	push	de
	ld	(currSlot),a
	call	_CheckIfSlotOpen \.r
	jp	nz,_ReturnNEG1L \.r
	push	hl
	call	_CheckInRAM_ASM \.r
	pop	hl
	jp	z,_ReturnNULL \.r
	ld	de,$FFFF-30
	sbc	hl,de
	add	hl,de
	push	af
	push	hl
	ld	bc,0
	call	_SetSlotOffset_ASM \.r
	pop	hl
	pop	af
	jp	nc,_ReturnNULL \.r		; return if too big
	push	hl
	call	_GetSlotSize_ASM \.r
	pop	hl
	or	a,a
	sbc	hl,bc
	ld	(resizeBytes),hl
	jr	z,NoResize
	jr	c,DecreaseSize
IncreaseSize:
	call	_EnoughMem
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
	ld	(resizeBytes),hl
	call	DeleteMemoryFromVar \.r
NoResize:
	ld	hl,(resizeBytes)
	ret
 
;-------------------------------------------------------------------------------
_GetTokenString:
; Returns pointer to next token string
; Arguments:
;  arg0 : Slot number
; Returns:
;  Pointer to string to display
	ld	iy,0
	add	iy,sp
	ld	a,1
	ld	(TokLen_SMC),a \.r
	ld	hl,(iy+3)
	ld	hl,(hl)
	push	hl
	ld	a,(hl)
	call	_Isa2ByteTok
	ex	de,hl
	jr	nz,+_
	inc	de
	ld	hl,TokLen_SMC \.r
	inc	(hl)
_:	inc	de
	ld	hl,(iy+3)
	ld	(hl),de
	pop	hl
	push	iy
	call	_Get_Tok_Strng
	pop	iy
	ld	hl,(iy+9)
	add	hl,bc
	or	a,a
	sbc	hl,bc
	jr	z,+_
	ld	(hl),bc
_:	ld	hl,(iy+6)
	add	hl,bc
	or	a,a
	sbc	hl,bc
	jr	z,+_
TokLen_SMC =$+1
	ld	(hl),1
_:	ld	hl,OP3
	ret

;-------------------------------------------------------------------------------
_GetDataPtr:
; Returns a pointer to the current location in the given variable
; Arguments:
;  arg0 : Slot number
; Returns:
;  Pointer to current offset data
	pop	de
	pop	hl
	ld	a,l
	push	hl
	push	de
	ld	(currSlot),a
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNULL \.r
	call	_GetSlotSize_ASM \.r
	inc	hl
	push	hl
	call	_GetSlotOffset_ASM \.r
	pop	hl
	add	hl,bc
	ret

;-------------------------------------------------------------------------------
_IsArchived:
; Checks if a variable is archived
; Arguments:
;  arg0 : Slot number
; Returns:
;  0 if not archived
	pop	de
	pop	hl
	ld	a,l
	ld	(currSlot),a
	push	hl
	push	de
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNULL \.r
_CheckInRAM_ASM:
	call	_GetSlotVATPtr_ASM \.r
	ld	hl,(hl)
	dec	hl
	dec	hl
	dec	hl
	dec	hl
	dec	hl
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
;  arg0 : Pointer to variable name
;  arg1 : Opening flags
;  arg2 : Varaible Type
; Returns:
;  Slot number if no error
	ld	iy,0
	add	iy,sp
	ld	a,(iy+9)
	jr	+_
;-------------------------------------------------------------------------------
_Open:
; Opens an AppVar
; Arguments:
;  arg0 : Pointer to variable name
;  arg1 : Opening flags
; Returns:
;  Slot number if no error
	ld	iy,0
	add	iy,sp
	ld	a,appVarObj
_:	ld	(varOpenType),a
	xor	a,a
	ld	hl,(VATPtr0)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,(VATPtr1)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,(VATPtr2)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,(VATPtr3)
	add	hl,de
	inc	a
	sbc	hl,de
	jr	z,+_
	ld	hl,(VATPtr4)
	add	hl,de
	inc	a
	sbc	hl,de
	jp	nz,_ReturnNULL \.r
_:	ld	(currSlot),a			; store the current slot number
	ld	hl,(iy+3)
	dec	hl
	call	_Mov9ToOP1
	ld	a,(varOpenType)
	ld	(OP1),a
	ld	hl,(iy+6)
	ld	a,(hl)
	cp	a,'w'
	jr	nz,+_
	call	_PushOP1			; delete the file if a 'w' exists
	call	_ChkFindSym
	call	nc,_DelVarArc
	call	_PopOP1
_:	ld	hl,(iy+6)
	ld	a,(hl)
	cp	a,'r'
	jr	z,+_
	cp	a,'a'
	jr	z,+_
	cp	a,'w'
	jp	nz,_ReturnNULL \.r
_:	inc	hl
	ld	a,(hl)
	cp	a,'+'
	jr	nz,++_
_ArchiveThisVar:
	call	_PushOP1
	call	_ChkFindSym
	call	_ChkInRam
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
	call	_EnoughMem
	jp	c,_ReturnNULL \.r
	call	_PopOP1
	call	_PushOP1
	call	_Arc_Unarc
	call	_PopOP1
	jr	_ArchiveThisVar
_:	call	_PopOP1
_:	call	_ChkFindSym
	jr	c,+_
	call	_ChkInRam
	jr	z,_SavePtrs_ASM
	ld	bc,(iy+6)
	ld	a,(bc)
	cp	a,'r'
	jp	nz,_ReturnNULL \.r
        ex	de,hl				; skip vat entry in archive
	push	iy
	push	hl
	pop	iy
	ld	bc,10
	add	hl,bc
	ld 	c,(iy+9)
	add 	hl,bc
	ex	(sp),hl
	add	hl,bc
	pop	iy
	jr	_SavePtrs_ASM
_:	ld	hl,(iy+6)
	ld	a,(hl)
	cp	a,'r'
	jp	z,_ReturnNULL \.r
	or	a,a
	sbc	hl,hl
	ld	a,(varOpenType)
	call	_CreateVar
_SavePtrs_ASM:
	push	hl
	call	_GetSlotVATPtr_ASM \.r
	pop	bc
	ld	(hl),bc
	call	_GetSlotDataPtr_ASM \.r
	ld	(hl),de
	ld	hl,(iy+6)
	ld	a,(hl)
	ld	bc,0
	cp	a,'a'
	call	z,_GetSlotSize_ASM \.r
	call	_SetSlotOffset_ASM \.r
	ld	a,(currSlot)
	ret

;-------------------------------------------------------------------------------
_SetArchiveStatus:
; Sets the archive status of a slot
; Arguments:
;  arg0 : Boolean value
;  arg1 : Slot number
; Returns:
;  None
	ld	a,$15
	ld	(variableTypeArc),a \.r
	pop	hl
	pop	bc
	pop	de
	ld	a,e
	ld	(currSlot),a
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
_:	dec	hl
	ld	a,(hl)
	ld	(de),a
	inc	de
	djnz	-_
	xor	a,a
	ld	(de),a
variableTypeArc =$+1
	ld	a,0
	ld	(op1),a
	call	_ChkFindSym
	call	_ChkInRam
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
	jp	z,_Arc_Unarc
	ret
SetNotArchived:
	push	bc
	pop	af
	jp	nz,_Arc_Unarc
	ret

;-------------------------------------------------------------------------------
_Write:
; Performs an fwrite to an AppVar
; Arguments:
;  arg0 : Pointer to data to write
;  arg1 : Size of entries (bytes)
;  arg2 : Number of entries
;  arg3 : Slot number
; Returns:
;  Number of chunks written if success
	ld	iy,0
	add	iy,sp
	ld	bc,(iy+6)
	ld	hl,(iy+9)
	call	__smulu				; hl*bc
	ex	de,hl
	ld	a,(iy+12)
	ld	(currSlot),a
	ld	hl,(iy+3)
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNULL \.r
	push	hl
	call	_CheckInRAM_ASM \.r
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
	rla
	pop	bc
	pop	de
	pop	hl
	jr	c,+_
	inc	hl
	inc	bc
	dec	de
	ld	a,e
	or	a,d
	jr	nz,-_
	jr	_s

;-------------------------------------------------------------------------------
_Read:
; Performs an fread to an AppVar
; Arguments:
;  arg0 : Pointer to data to read into
;  arg1 : Size of entries (bytes)
;  arg2 : Number of entries
;  arg3 : Slot number
; Returns:
;  Number of chunks read if success
	ld	iy,0
	add	iy,sp
	ld	bc,(iy+6)
	ld	hl,(iy+9)
	call	__smulu				; hl*bc
	ex	de,hl
	ld	a,(iy+12)
	ld	(currSlot),a
	ld	hl,(iy+3)
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNULL \.r
	ld	bc,0
_:	push	hl
	push	de
	push	bc
	call	_GetChar_ASM \.r
	call	_SetAToHLU
	rla
	ld	a,l
	pop	bc
	pop	de
	pop	hl
	jr	c,_s
	ld	(hl),a
	inc	hl
	inc	bc
	dec	de
	ld	a,e
	or	a,d
	jr	nz,-_
_s:	ld	de,(iy+6)
	ex.s	de,hl
	push	hl
	ld	l,c
	ld	h,b
	pop	bc
	jp	__sdivu

;-------------------------------------------------------------------------------
_GetChar:
; Performs an fgetc to an AppVar
; Arguments:
;  arg0 : Slot number
; Returns:
;  Character read if success
	pop	de
	pop	bc
	ld	a,c
	ld	(currSlot),a
	push	bc
	push	de
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
_GetChar_ASM:
	call	_GetSlotSize_ASM \.r
	push	bc
	call	_GetSlotOffset_ASM \.r
	pop	hl
	dec	hl
	or	a,a
	sbc	hl,bc				; size-offset
	jp	c,_ReturnNEG1L \.r
	push	bc
	call	_GetSlotDataPtr_ASM \.r
	ld	hl,(hl)
	add	hl,bc
	inc	hl
	inc	hl ; bypass size bytes
	pop	bc
	inc	bc
	ld	a,(hl)
	call	_SetSlotOffset_ASM \.r
	or	a,a
	sbc	hl,hl
	ld	l,a
	ret

;-------------------------------------------------------------------------------
_Seek:
; Performs an fseek on an AppVar
; Arguments:
;  arg0 : Posistion to seek to
;  arg1 : Origin position
;  arg2 : Slot number
; Returns:
;  -1 if failure
	ld	iy,0
	add	iy,sp
	ld	de,(iy+3)
	ld	l,(iy+6)
	ld	a,(iy+9)
	ld	(currSlot),a
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
	ld	a,l
	or	a,a
	jr	z,SeekCur
	dec	a
	jr	z,SeekEnd
	dec	a
	jp	nz,_ReturnNEG1L \.r
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
	call	_GetSlotOffset_ASM \.r
	ex	de,hl
	add	hl,bc
	ex	de,hl
	jr	_SeekHandler_ASM
SeekEnd:
	call	_GetSlotSize_ASM \.r
	ex	de,hl
	add	hl,bc
	ex	de,hl
	jr	_SeekHandler_ASM

;-------------------------------------------------------------------------------
_PutChar:
; Performs an fputc on an AppVar
; Arguments:
;  arg0 : Character to place
;  arg1 : Slot number
; Returns:
;  Character written if no failure
	pop	de
	pop	hl
	ld	a,l
	ld	(charIn),a \.r
	pop	bc
	ld	a,c
	ld	(currSlot),a
	push	bc
	push	hl
	push	de
	call	_CheckIfSlotOpen \.r
	jp	z,_ReturnNEG1L \.r
	push	hl
	call	_CheckInRAM_ASM \.r
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
	ld	(resizeBytes),hl
	call	_EnoughMem
	pop	bc
	jp	c,_ReturnNEG1L \.r
	push	bc
	ex	de,hl
	call	AddMemoryToVar \.r
	pop	bc
noIncrement:
	call	_GetSlotDataPtr_ASM \.r
	ld	hl,(hl)
	add	hl,bc
	inc	hl
	inc	hl
charIn	=$+1
	ld	(hl),0
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
;  arg0 : Pointer to variable name
;  arg1 : Variable type
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
;  arg0 : Pointer to AppVar name
; Returns:
;  0 if failure
	ld	a,$15
_:	pop	de
	pop	hl
	push	hl
	push	de
	dec	hl
	push	af
	call	_Mov9ToOP1
	pop	af
	ld	(OP1),a
	call	_ChkFindSym
	jp	c,_ReturnNULL \.r
	call	_DelVarArc
	or	a,a
	sbc	hl,hl
	inc	hl
	ret

;-------------------------------------------------------------------------------
_Rewind:
; Performs an frewind on a varaible
; Arguments:
;  arg0 : Slot number
; Returns:
;  -1 if failure
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a,c
	ld	(currSlot),a
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
;  arg0 : Slot number
; Returns:
;  -1 if failure
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a,c
	ld	(currSlot),a
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
;  arg0 : Slot number
; Returns:
;  -1 if failure
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a,c
	ld	(currSlot),a
	call	_CheckIfSlotOpen \.r
	jr	z,_ReturnNEG1L
	call	_GetSlotSize_ASM \.r
	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------
_Close:
; Closes an open slot varaible
; Arguments:
;  arg0 : Slot number
; Returns:
;  None
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a,c
	ld	(currSlot),a
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
 
_ReturnNULL:
	xor	a,a
	sbc	hl,hl
	ret
_ReturnNEG1L:
	scf
	sbc	hl,hl
	ret

;-------------------------------------------------------------------------------
AddMemoryToVar:
	call	_GetSlotDataPtr_ASM	\.r
	push	hl
	ld	hl,(hl)
	push	hl
	call	_GetSlotOffset_ASM	\.r
	pop	hl
	add	hl,bc
	inc	hl
	inc	hl
	ex	de,hl
	ld	hl,(resizeBytes)
	call	_InsertMem
	pop	hl
	ld	hl,(hl)
	push	hl
	ex	de,hl
	or	a,a
	sbc	hl,hl
	ex	de,hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,(resizeBytes)
	add	hl,bc
	jr	SaveSize

DeleteMemoryFromVar:
	call	_GetSlotDataPtr_ASM \.r
	push	hl
	ld	hl,(hl)
	push	hl
	call	_GetSlotOffset_ASM \.r
	pop	hl
	add	hl,bc
	inc	hl
	inc	hl
	ld	de,(resizeBytes)
	call	_DelMem
	pop	hl
	ld	hl,(hl)
	push	hl
	ex	de,hl
	or	a,a
	sbc	hl,hl
	ex	de,hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,(resizeBytes)
	or	a,a
	sbc	hl,bc					; decrease amount
SaveSize:
	ex	de,hl
	pop	hl					; pointer to size bytes location
	ld	(hl),e
	inc	hl
	ld	(hl),d					; write new size
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
	ld	a,(currSlot)
	ld	hl,VATPtr0 	; =$D0244E
	dec	a
	ret	z
	inc	h
	ld	l,$7b		; VATPtr1=$D0257B
	dec	a
	ret	z
	ld	l,$7e		; VATPtr2= $D0257E
	dec	a
	ret	z
	ld	l,$81		; VATPtr3=$D02581
	dec	a
	ret	z
	ld	l,$84		; VATPtr4=$D02584
	ret
_GetSlotDataPtr_ASM:
	ld	a,(currSlot)
	ld	hl,varPtr0	; varPtr0 = $D0067E
	dec	a
	ret	z
	ld	l,$81		; varPtr1 = $D00681
	dec	a
	ret	z
	ld	hl,varPtr2	; varPtr2 = $D01FED
	dec	a
	ret	z
	ld	l,$f3		; varPtr3 = $D01FF3
	dec	a
	ret	z
	ld	l,$f9		; varPtr4 = $D01FF9
	ret
_GetSlotOffsetPtr_ASM:
	push	bc
	ld	hl,(currSlot)
	dec	l
	ld	h,3
	mlt	hl
	ld	bc,VarOffset0 \.r
	add	hl,bc
	pop	bc
	ret
_GetSlotSize_ASM:
	call	_GetSlotDataPtr_ASM \.r
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

; Stores the loctaion of the offsets for the working variables
VarOffset0:
	.dl 0,0,0,0,0
 
 .endLibrary
