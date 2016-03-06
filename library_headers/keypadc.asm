 define .libs,space=ram
 segment .libs
 .assume ADL=1
 db 192,"KEYPADC",0,1

 .def _kb_Scan
_kb_Scan:
 jp 0
 .def _kb_ScanGroup
_kb_ScanGroup:
 jp 3
 .def _kb_AnyKey
_kb_AnyKey:
 jp 6
 .def _kb_Reset
_kb_Reset:
 jp 9
 end
