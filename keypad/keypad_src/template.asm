#include "..\\..\\include\\relocation.inc"
 
; stack locations
#define arg0 6
#define arg1 9
#define arg2 12
#define arg3 15
#define arg4 18
#define arg5 21

 .libraryName		"KEYPADC"	                    ; Name of library
 .libraryVersion	1		                        ; Version information (1-255)
 
 .function "void","kb_Scan","void",_keyboardscan
 .function "unsigned char","kb_ScanGroup","unsigned char row",_keyboardscangroup
 .function "unsigned char","kb_AnyKey","void",_keyboardanykey
 .function "void","kb_Reset","void",_keyboardclear
 
 .beginDependencies
 .endDependencies
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Quickly scans the keyboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_keyboardscan:
 di
 ld hl,DI_Mode
 ld (hl),2
 xor a,a
scan_wait_scan:
 cp a,(hl)
 jr nz,scan_wait_scan
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets the controller to mode 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_keyboardclear:
 ld hl,DI_Mode
 xor a		; Mode 0
 ld (hl),a
 inc l		; 0F50001h
 ld (hl),15	; Wait 15*256 APB cycles before scanning each row
 inc l		; 0F50002h
 xor a
 ld (hl),a
 inc l		; 0F50003h
 ld (hl),15	; Wait 15 APB cycles before each scan
 inc l		; 0F50004h
 ld a,8		; Number of rows to scan
 ld (hl),a
 inc l		; 0F50005h
 ld (hl),a	; Number of columns to scan
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Scans a keyboard group
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_keyboardscangroup:
 di
 pop hl
  pop bc
  push bc
 push hl
 ld hl,DI_Mode
 ld (hl),2
 xor a,a
scan_wait:
 cp a,(hl)
 jr nz,scan_wait
 ld a,c
 cp a,8
 jr nc,return0
 ld l,a
 ld h,2
 mlt hl
 ld de,kbdG1-2
 add hl,de
 ld a,(hl)
 ret
return0:
 xor a,a
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks if any key is pressed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_keyboardanykey:
 di
 ld hl,DI_Mode
 ld (hl),2
 xor a,a
scan_wait_any:
 cp a,(hl)
 jr nz,scan_wait_any
 ld hl,kbdG1
 or a,(hl)
 inc hl \ inc hl
 or a,(hl)
 inc hl \ inc hl
 or a,(hl)
 inc hl \ inc hl
 or a,(hl)
 inc hl \ inc hl
 or a,(hl)
 inc hl \ inc hl
 or a,(hl)
 inc hl \ inc hl
 or a,(hl)
 ret
 
 .endLibrary