 define .libs,space=ram
 segment .libs
 .assume ADL=1
 db 192,"FILEIOC",0,1

 .def _ti_CloseAll
_ti_CloseAll:
 jp 0
 .def _ti_Open
_ti_Open:
 jp 3
 .def _ti_OpenVar
_ti_OpenVar:
 jp 6
 .def _ti_Close
_ti_Close:
 jp 9
 .def _ti_Write
_ti_Write:
 jp 12
 .def _ti_Read
_ti_Read:
 jp 15
 .def _ti_GetC
_ti_GetC:
 jp 18
 .def _ti_PutC
_ti_PutC:
 jp 21
 .def _ti_Delete
_ti_Delete:
 jp 24
 .def _ti_DeleteVar
_ti_DeleteVar:
 jp 27
 .def _ti_Seek
_ti_Seek:
 jp 30
 .def _ti_Resize
_ti_Resize:
 jp 33
 .def _ti_IsArchived
_ti_IsArchived:
 jp 36
 .def _ti_SetArchiveStatus
_ti_SetArchiveStatus:
 jp 39
 .def _ti_Tell
_ti_Tell:
 jp 42
 .def _ti_Rewind
_ti_Rewind:
 jp 45
 .def _ti_GetSize
_ti_GetSize:
 jp 48
 end
