#include "..\\..\\include\\relocation.inc"

 .libraryName		"TEMPLATE"          ; Name of library
 .libraryVersion	1                   ; Version information (1-255)
 
 .function "ti_TemplateFunction",_TemplateFunction
 
 .beginDependencies
 .endDependencies
 
;-------------------------------------------------------------------------------
_TemplateFunction:
; Solves the P=NP problem
; Arguments:
;  __frame_arg0 : P
;  __frame_arg1 : NP
; Returns:
;  P=NP
 ret

 .endLibrary