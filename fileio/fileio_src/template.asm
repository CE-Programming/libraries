#include "ti84pce.inc"
#include "..\\..\\include\\relocation.inc"

 .libraryName		"FILEIOC"	                    ; Name of library
 .libraryVersion	1		                        ; Version information (1-255)
 
 .function "void","ti_CloseAll","void",_init
 .function "unsigned int","ti_Open","const char *varname, const char *mode",_openappvar
 .function "unsigned int","ti_OpenVar","const char *varname, const char *mode, unsigned int type",_openvar
 .function "unsigned int","ti_Close","unsigned int slot",_closeslot
 .function "unsigned int","ti_Write","const void *data, unsigned char size, unsigned int count, unsigned int slot",_writedata
 .function "unsigned int","ti_Read","const void *data, unsigned char size, unsigned int count, unsigned int slot",_readdata
 .function "unsigned int","ti_GetC","unsigned int slot",_getchar
 .function "unsigned int","ti_PutC","unsigned int c, unsigned int slot",_putchar
 .function "unsigned int","ti_Delete","const char *varname",_deleteslot
 .function "unsigned int","ti_DeleteVar","const char *varname, unsigned int type,",_deletevar
 .function "unsigned int","ti_Seek","unsigned short offset, unsigned short origin, unsigned int slot",_seek
 .function "unsigned int","ti_Resize","unsigned int newSize, unsigned int slot",_resize
 .function "unsigned int","ti_IsArchived","unsigned int slot",_isarchived
 .function "unsigned int","ti_SetArchiveStatus","unsigned int archived, unsigned int slot",_setarcvaraible
 .function "unsigned int","ti_Tell","unsigned int slot",_tell
 .function "unsigned int","ti_Rewind","unsigned int slot",_rewind
 .function "unsigned short","ti_GetSize","unsigned int slot",_getsize
 
 .beginDependencies
 .endDependencies
 
; stack locations
#define arg0 6
#define arg1 9
#define arg2 12
#define arg3 15
#define arg4 18
#define arg5 21
 
; slot pointer
#define VATPtr0 $D0244E
#define VATPtr1 $D0257B
#define VATPtr2 $D0257E
#define VATPtr3 $D02581
#define VATPtr4 $D02584

; slot var data pointers
#define varPtr0 $D0067E
#define varPtr1 $D00681
#define varPtr2 $D01FED
#define varPtr3 $D01FF3
#define varPtr4 $D01FF9
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set everything to 0 (NULL)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_init:
 or a,a
 sbc hl,hl
 ld (VATPtr0),hl
 ld (VATPtr1),hl
 ld (VATPtr2),hl
 ld (VATPtr3),hl
 ld (VATPtr4),hl
 ld (varPtr0),hl
 ld (varPtr1),hl
 ld (varPtr2),hl
 ld (varPtr3),hl
 ld (varPtr4),hl
 ld hl,varOffset0 \.r
 ld bc,15
 jp _memclear
 
_resize:
 pop de
  pop hl                ; hl=newSize
   pop bc               ;  a=slot
   ld a,c
   ld (currentSlot),a \.r
   push bc
  push hl
 push de
 call _checkifslotopen \.r
 jp z,_returnNEG1L \.r
 push hl
  call _checkInRAM_ASM \.r
  ld a,l
 pop hl
 jp z,_returnNULL \.r
 ld de,$FFFF-30
 or a,a
 sbc hl,de
 add hl,de
 push af
  push hl
   ld bc,0
   call _setslotoffset_ASM \.r
  pop hl
 pop af
 jp nc,_returnNULL \.r  ; return if too big
 push hl
  call _getslotsize_ASM \.r
 pop hl
 or a,a
 sbc hl,bc
 ld (ResizeBytes),hl \.r
 jr z,NoResize
 jr c,DecreaseSize
IncreaseSize:
 call _enoughmem
 jp c,_returnNULL \.r
 ex de,hl
 call AddMemoryToVar \.r
 jr NoResize
DecreaseSize:
 push hl
 pop bc
 or a,a
 sbc hl,hl
 sbc hl,bc
 ld (ResizeBytes),hl \.r
 call DeleteMemoryFromVar \.r
NoResize:
 ld hl,(ResizeBytes) \.r
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns 0 if a variable is not archived
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_isarchived:
 pop de
  pop hl
  ld a,l
  ld (currentSlot),a \.r
  push hl
 push de
 call _checkifslotopen \.r
 jp z,_returnNULL \.r
_checkInRAM_ASM:
 call _getslotVATptr_ASM \.r
 ld hl,(hl)
 push bc
  ld bc,-5
  add hl,bc
 pop bc
 ld a,(hl)
 or a,a
 sbc hl,hl
 cp a,$D0
 ret nc
 inc hl
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a variable (name, size, type, open flags)
; Returns a pointer to the start of the varaible data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_openvar:
 push ix
  ld ix,0
  add ix,sp
  ld a,(ix+arg3)
 pop ix
 jr +_
_openappvar:
 ld a,$15
_:
 ld (varType),a \.r
 push ix
  ld ix,0
  add ix,sp
  xor a,a
  ld hl,VATPtr0
  ld hl,(hl)
  add hl,de
  inc a
  sbc hl,de
  jr z,slotopen
  ld hl,VATPtr1
  ld hl,(hl)
  add hl,de
  inc a
  sbc hl,de
  jr z,slotopen
  ld hl,VATPtr2
  ld hl,(hl)
  add hl,de
  inc a
  sbc hl,de
  jr z,slotopen
  ld hl,VATPtr3
  ld hl,(hl)
  add hl,de
  inc a
  sbc hl,de
  jr z,slotopen
  ld hl,VATPtr4
  ld hl,(hl)
  inc a
  sbc hl,de
  jr z,slotopen
  jp _returnNULL_popIX \.r    ; if a slot is not open, return NULL (0)
slotopen:
  ld (currentSlot),a \.r
  ld hl,(ix+arg0)       ; hl->name
  ld de,op1+1
  ld bc,9
  ldir
  xor a,a
  ld (de),a
  ld hl,(ix+arg1)        ; a=flags
  ld a,(hl)
  cp a,'w'               ; create the file, overwrite old one
  jr nz,nooverwite
  call _pushop1
  call _chkfindsym
  call nc,_delvararc    ; delete if existing
  call _popop1
nooverwite:
  ld hl,(ix+arg1)        ; a=flags
  ld a,(hl)
  cp a,'r'
  jr z,+_
  cp a,'a'
  jr z,+_
  cp a,'w'
  jp nz,_returnNULL_popIX \.r
_:
  inc hl
  ld a,(hl)
  cp a,'+'
  jr nz,mayberead
archivevar:
  call _pushop1
  call _chkfindsym
  call _chkinram
  jr z,inram
  inc de
  inc de
  or a,a
  sbc hl,hl
  ex de,hl
  ld e,(hl)
  inc hl
  ld d,(hl)
  ex de,hl              ; hl=extracted size
  call _enoughmem
  jp c,_returnNULL_popIX \.r
  call _popop1
  call _pushop1
  call _arc_Unarc
  call _popop1
  jr archivevar
inram:
  call _popop1
mayberead:
  call _chkfindsym
  jr c,needtocreate
  call _chkinram
  jr z,_savePtrs_ASM
  push hl
   ld hl,(ix+arg1)        ; a=flags
   ld a,(hl)
   cp a,'r'               ; make sure we are reading before we send back this
  pop hl
  jp nz,_returnNULL_popIX \.r
  jr _savePtrs_ASM
needtocreate:
  ld hl,(ix+arg1)        ; a=flags
  ld a,(hl)
  cp a,'r'               ; can't create the file if we are reading
  jp z,_returnNULL_popIX \.r
  or a,a
  sbc hl,hl
varType: =$+1
  ld a,0
  call _createvar
_savePtrs_ASM:
  push hl
   call _getslotVATptr_ASM \.r
  pop bc
  ld (hl),bc
  call _getslotvarptr_ASM \.r
  ld (hl),de
  ld hl,(ix+arg1)        ; a=flags
  ld a,(hl)
  ld bc,0
  cp a,'a'
  call z,_getslotsize_ASM \.r
  call _setslotoffset_ASM \.r
 pop ix
 ld a,(currentSlot) \.r
 or a,a
 sbc hl,hl
 ld l,a
 ret
 
_setarcvaraible:
 ld a,$15
 ld (varTypeArc),a \.r
 pop hl
  pop bc
   pop de
   ld a,e
   ld (currentSlot),a \.r
   push de
  push bc
 push hl
 call _checkifslotopen \.r
 jp z,_returnNULL \.r
 ld a,c
 push af
  call _getslotVATptr_ASM \.r
  ld hl,(hl)
  ld bc,-6
  add hl,bc
  ld b,(hl)
  ld de,op1+1
  dec hl
_:
  ld a,(hl)
  ld (de),a
  inc de
  dec hl
  djnz -_
  xor a,a
  ld (de),a
varTypeArc: =$+1
  ld a,0
  ld (op1),a
  call _chkfindsym
  call _chkinram
  push af
  ld bc,0
  call _getslotVATptr_ASM \.r
  ld (hl),bc
  pop bc
 pop af
 or a,a
 jr z,SetNotArchived
SetArchived:
 push bc
 pop af
 jp z,_arc_unarc
 ret
SetNotArchived:
 push bc
 pop af
 jp nz,_arc_unarc
 ret
 
; size*count = size
_writedata:
 push ix
  ld ix,0
  add ix,sp
  ld bc,(ix+arg1)
  ld hl,(ix+arg2)
  call $000228      ; hl*bc
  ex de,hl           ; de=number of bytes to write
  ld a,(ix+arg3)     ; a=slot
  ld (currentSlot),a \.r
  ld hl,(ix+arg0)    ; ptr to data
 pop ix
 call _checkifslotopen \.r
 jp z,_returnNULL \.r
 push hl
  call _checkInRAM_ASM \.r
  ld a,l
 pop hl
 jp z,_returnNULL \.r
 ld bc,0
_:
 ld a,(hl)
 push hl
  push de
   push bc
    ld (charIn),a \.r
    call _putChar_ASM \.r
    call _SetAToHLU
    bit 7,a
    jr nz,+_
   pop bc
  pop de
 pop hl
 inc hl
 inc bc
 dec de
 ld a,e
 or a,d
 jr nz,-_
 ex de,hl
 ret
_:
 pop hl
 pop de
 pop bc
 ret
 
_readdata:
 push ix
  ld ix,0
  add ix,sp
  ld bc,(ix+arg1)
  ld hl,(ix+arg2)
  call $000228      ; hl*bc
  ex de,hl           ; de=number of bytes to read
  ld a,(ix+arg3)     ; a=slot
  ld (currentSlot),a \.r
  ld hl,(ix+arg0)    ; ptr to data
 pop ix
 call _checkifslotopen \.r
 jp z,_returnNULL \.r
 ld bc,0
_:
 push hl
  push de
   push bc
    call _getChar_ASM \.r
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
_:
 pop hl
 pop de
 pop bc
 ret
 
_getchar:
 pop de
  pop bc  ; a=slot
  ld a,c
  ld (currentSlot),a \.r
  push bc
 push de
 call _checkifslotopen \.r
 jp z,_returnNEG1L \.r
_getChar_ASM:
 call _getslotsize_ASM \.r    ; bc=size
 push bc
  call _getslotoffset_ASM \.r  ; bc=offset
 pop hl
 or a,a
 sbc hl,bc  ; size-offset
 jp c,_returnNEG1L \.r
 jp z,_returnNEG1L \.r
 push bc
  call _getslotvarptr_ASM \.r
  ld hl,(hl)
  add hl,bc
  inc hl
  inc hl ; bypass size bytes
 pop bc
 inc bc
 ld a,(hl)
 push af
  call _setslotoffset_ASM \.r
 pop af
 or a,a
 sbc hl,hl
 ld l,a
 ret
 
_seek:
 push ix
  ld ix,0
  add ix,sp
  ld de,(ix+arg0)
  ld l,(ix+arg1)
  ld a,(ix+arg2)
 pop ix
 ld (currentSlot),a \.r
 call _checkifslotopen \.r
 jp z,_returnNEG1L \.r
 ld a,l
 or a,a     ; SEEK_CUR
 jr z,seekCur
 dec a
 jr z,seekEnd
 dec a
 jp nz,_returnNEG1L \.r

_seekHandler_ASM:
 call _getslotsize_ASM \.r
 push bc
 pop hl
 or a,a
 sbc hl,de 
 push de
 pop bc
 jp c,_returnNEG1L \.r
 jp _setslotoffset_ASM \.r
 
seekCur:
 push de
  call _getslotoffset_ASM \.r
 pop hl
 add hl,bc
 ex de,hl
 jr _seekHandler_ASM
seekEnd:
 push de
  call _getslotsize_ASM \.r
 pop hl
 add hl,bc
 ex de,hl
 jr _seekHandler_ASM
 
_putchar:
 pop de
  pop hl    ; l=char
  ld a,l
  ld (charIn),a \.r
   pop bc  ; a=slot
   ld a,c
   ld (currentSlot),a \.r
   push bc
  push hl
 push de
 call _checkifslotopen \.r
 jp z,_returnNEG1L \.r
 push hl
  call _checkInRAM_ASM \.r
  ld a,l
 pop hl
 jp z,_returnNEG1L \.r
_putChar_ASM:
 call _getslotsize_ASM \.r    ; bc=size
 push bc
  call _getslotoffset_ASM \.r  ; bc=offset
 pop hl
 or a,a
 sbc hl,bc  ; size-offset
 jp c,_returnNEG1L \.r
 jr nz,noIncrement
Increment:
 push bc
  inc hl
  ld (ResizeBytes),hl \.r
  call _enoughmem
 pop bc
 jp c,_returnNEG1L \.r
 push bc
  ex de,hl
  call AddMemoryToVar \.r
 pop bc
noIncrement:
 call _getslotvarptr_ASM \.r
 push bc
  ld hl,(hl)
  add hl,bc
  inc hl
  inc hl ; bypass size bytes
charIn: =$+1
  ld (hl),0
 pop bc
 inc bc
 call _setslotoffset_ASM \.r
 ld a,(charIn) \.r
 or a,a
 sbc hl,hl
 ld l,a
 ret
 
_deletevar:
 pop hl
  pop de
   pop af
   push af
  push de
 push hl
 jr +_
_deleteslot:
 ld a,$15
_:
 ld (varTypeDelete),a \.r
 pop de
  pop hl
  push hl
 push de
 ld de,op1+1
 ld bc,9
 ldir
 xor a,a
 ld (de),a
varTypeDelete: =$+1
 ld a,0
 ld (op1),a
 call _chkfindsym
 jp c,_returnNULL \.r
 call _delvararc     ; delete if existing
 or a,a
 sbc hl,hl
 inc hl
 ret
 
_rewind:
 pop hl
  pop bc
  ld a,c
  push bc
 push hl
 ld (currentSlot),a \.r
 call _checkifslotopen \.r
 jp z,_returnNEG1L \.r
 ld bc,0
 call _setslotoffset_ASM \.r
 or a,a
 sbc hl,hl
 ret

_tell:
 pop hl
  pop bc
  ld a,c
  push bc
 push hl
 ld (currentSlot),a \.r
 call _checkifslotopen \.r
 jp z,_returnNEG1L \.r
 call _getslotoffset_ASM \.r
 push bc
 pop hl
 ret

_getsize:
 pop hl
  pop bc
  ld a,c
  push bc
 push hl
 ld (currentSlot),a \.r
 call _checkifslotopen \.r
 jp z,_returnNEG1L \.r
 call _getslotsize_ASM \.r
 push bc
 pop hl
 ret
 
_closeslot:
 pop hl
  pop af
  push af
 push hl
 ld (currentSlot),a \.r
 call _getslotVATptr_ASM \.r
 ex de,hl
 xor a,a
 sbc hl,hl
 ex de,hl
 ld (hl),de
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Internal routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
AddMemoryToVar:
 call _getslotvarptr_ASM \.r
 push hl
  ld hl,(hl)
  push hl
   call _getslotoffset_ASM \.r
  pop hl
  add hl,bc
  inc hl
  inc hl
  ex de,hl
  ld hl,(ResizeBytes) \.r		; number bytes to insert
  call _InsertMem		; insert the memory
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
  add hl,bc		        ; increase by 5
  jr SaveSize
DeleteMemoryFromVar:
 call _getslotvarptr_ASM \.r
 push hl
  ld hl,(hl)
  push hl
   call _getslotoffset_ASM \.r
  pop hl
  add hl,bc
  inc hl
  inc hl                    ; bypass size bytes
  ld de,(ResizeBytes) \.r	; number bytes to delete
  call _DelMem			    ; Delete the memory
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
  sbc hl,bc		            ; decrease amount
SaveSize:
  ex de,hl
 pop hl		                ; pointer to size bytes location
 ld (hl),e
 inc hl
 ld (hl),d		            ; write new size.
 ret
 
_returnNULL_popIX:
  pop ix
_returnNULL:
 xor a,a
 sbc hl,hl
 ret
_returnNEG1L:
 xor a,a
 sbc hl,hl
 dec hl
 ret
_checkifslotopen:
 push hl
  push bc
   ld c,a
   call _getslotVATptr_ASM \.r
   ld hl,(hl)
   add hl,de 
   or a,a 
   sbc hl,de      ; returns z if slot is not open
   ld a,c
  pop bc
 pop hl
 ret
_getslotVATptr_ASM:
 ld a,(currentSlot) \.r
 dec a
 ld hl,VATPtr0
 or a,a
 ret z
 ld hl,VATPtr1
 dec a
 ret z
 ld hl,VATPtr2
 dec a
 ret z
 ld hl,VATPtr3
 dec a
 ret z
 ld hl,VATPtr4
 ret
_getslotsizeptr_ASM:
_getslotvarptr_ASM:
 ld a,(currentSlot) \.r
 dec a
 ld hl,varPtr0
 or a,a
 ret z
 ld hl,varPtr1
 dec a
 ret z
 ld hl,varPtr2
 dec a
 ret z
 ld hl,varPtr3
 dec a
 ret z
 ld hl,varPtr4
 ret
_getslotoffsetptr_ASM:
 push bc
  ld a,(currentSlot) \.r
  dec a
  ld l,a
  ld h,3
  mlt hl
  ld bc,varOffset0 \.r
  add hl,bc
 pop bc
 ret
_getslotsize_ASM:
 call _getslotsizeptr_ASM \.r
 ld hl,(hl)
 ld bc,0
 ld c,(hl)
 inc hl
 ld b,(hl)
 ret
_getslotoffset_ASM:
 call _getslotoffsetptr_ASM \.r
 ld bc,(hl)
 ret
_setslotoffset_ASM:
 call _getslotoffsetptr_ASM \.r
 ld (hl),bc
 ret
 
currentSlot:
 .db 0
 
ResizeBytes:
 .dl 0
 
varOffset0:
 .dl 0
varOffset1:
 .dl 0
varOffset2:
 .dl 0
varOffset3:
 .dl 0
varOffset4:
 .dl 0
 
 .endLibrary