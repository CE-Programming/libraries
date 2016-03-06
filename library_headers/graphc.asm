 define .libs,space=ram
 segment .libs
 .assume ADL=1
 db 192,"GRAPHC",0,2

 .def _gc_InitGraph
_gc_InitGraph:
 jp 0
 .def _gc_CloseGraph
_gc_CloseGraph:
 jp 3
 .def _gc_SetColorIndex
_gc_SetColorIndex:
 jp 6
 .def _gc_SetDefaultPalette
_gc_SetDefaultPalette:
 jp 9
 .def _gc_SetPalette
_gc_SetPalette:
 jp 12
 .def _gc_FillScrn
_gc_FillScrn:
 jp 15
 .def _gc_ClipSetPixel
_gc_ClipSetPixel:
 jp 18
 .def _gc_ClipGetPixel
_gc_ClipGetPixel:
 jp 21
 .def _gc_GetColor
_gc_GetColor:
 jp 24
 .def _gc_SetColor
_gc_SetColor:
 jp 27
 .def _gc_NoClipLine
_gc_NoClipLine:
 jp 30
 .def _gc_NoClipRectangle
_gc_NoClipRectangle:
 jp 33
 .def _gc_NoClipRectangleOutline
_gc_NoClipRectangleOutline:
 jp 36
 .def _gc_NoClipHorizLine
_gc_NoClipHorizLine:
 jp 39
 .def _gc_NoClipVertLine
_gc_NoClipVertLine:
 jp 42
 .def _gc_NoClipCircle
_gc_NoClipCircle:
 jp 45
 .def _gc_ClipCircleOutline
_gc_ClipCircleOutline:
 jp 48
 .def _gc_DrawBuffer
_gc_DrawBuffer:
 jp 51
 .def _gc_DrawScreen
_gc_DrawScreen:
 jp 54
 .def _gc_SwapDraw
_gc_SwapDraw:
 jp 57
 .def _gc_DrawState
_gc_DrawState:
 jp 60
 .def _gc_PrintChar
_gc_PrintChar:
 jp 63
 .def _gc_PrintInt
_gc_PrintInt:
 jp 66
 .def _gc_PrintUnsignedInt
_gc_PrintUnsignedInt:
 jp 69
 .def _gc_PrintString
_gc_PrintString:
 jp 72
 .def _gc_PrintStringXY
_gc_PrintStringXY:
 jp 75
 .def _gc_StringWidth
_gc_StringWidth:
 jp 78
 .def _gc_CharWidth
_gc_CharWidth:
 jp 81
 .def _gc_TextX
_gc_TextX:
 jp 84
 .def _gc_TextY
_gc_TextY:
 jp 87
 .def _gc_SetTextXY
_gc_SetTextXY:
 jp 90
 .def _gc_SetTextColor
_gc_SetTextColor:
 jp 93
 .def _gc_SetTransparentColor
_gc_SetTransparentColor:
 jp 96
 .def _gc_NoClipDrawSprite
_gc_NoClipDrawSprite:
 jp 99
 .def _gc_NoClipDrawTransparentSprite
_gc_NoClipDrawTransparentSprite:
 jp 102
 .def _gc_NoClipGetSprite
_gc_NoClipGetSprite:
 jp 105
 .def _gc_SetCustomFontData
_gc_SetCustomFontData:
 jp 108
 .def _gc_SetCustomFontSpacing
_gc_SetCustomFontSpacing:
 jp 111
 .def _gc_SetFontMonospace
_gc_SetFontMonospace:
 jp 114
 .def _gc_SetClipWindow
_gc_SetClipWindow:
 jp 117
 .def _gc_ClipRegion
_gc_ClipRegion:
 jp 120
 .def _gc_ShiftWindowDown
_gc_ShiftWindowDown:
 jp 123
 .def _gc_ShiftWindowUp
_gc_ShiftWindowUp:
 jp 126
 .def _gc_ShiftWindowLeft
_gc_ShiftWindowLeft:
 jp 129
 .def _gc_ShiftWindowRight
_gc_ShiftWindowRight:
 jp 132
 .def _gc_ClipRectangle
_gc_ClipRectangle:
 jp 135
 .def _gc_ClipRectangleOutline
_gc_ClipRectangleOutline:
 jp 138
 .def _gc_ClipHorizLine
_gc_ClipHorizLine:
 jp 141
 .def _gc_ClipVertLine
_gc_ClipVertLine:
 jp 144
 .def _gc_ClipDrawSprite
_gc_ClipDrawSprite:
 jp 147
 .def _gc_ClipDrawTransparentSprite
_gc_ClipDrawTransparentSprite:
 jp 150
 .def _gc_NoClipDrawScaledSprite
_gc_NoClipDrawScaledSprite:
 jp 153
 .def _gc_NoClipDrawScaledTransparentSprite
_gc_NoClipDrawScaledTransparentSprite:
 jp 156
 end
