#include "..\\include\\relocation.inc"

 .libraryName		"TEMPLATE"	                    ; Name of library
 .libraryVersion	1		                        ; Version information (1-255)
 
 .function "void","tp_Nop","void",_ret
 
 .beginDependencies
 .endDependencies
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sample funciton
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_ret:
 nop
 ret

 .endLibrary