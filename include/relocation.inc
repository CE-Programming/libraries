.nolist
;---------------------------------------------

#macro libraryName(name)
 #define numfunctions 0
 #define numrelocations 0
 
 clr()
 wr("#define asmname ",name,".asm")
 wr("#define headername ",name,".h")
 run()
 
 #define noextname eval(name)
 
 .echo > headername "/***************************************************\n"
 .echo >> headername "  ",noextname," library header file\n"
 
 .echo > relocation_table ""
 .echo > asmname " db 0C0h,\"",noextname,"\",0\n"
 .db $C0,$C0
#endmacro
#define .libraryName libraryName(

;---------------------------------------------

#macro libraryVersion(version)
 #define libversion eval(version)
 .echo >> asmname " db ",libversion,"\n"
 
 .echo >> headername "  version ",libversion,"\n"
 .echo >> headername "***************************************************/\n\n"
 .echo >> headername "#ifndef H_",noextname,"\n"
 .echo >> headername "#define H_",noextname,"\n\n"
 .echo >> headername "#pragma asm \"include \"libheader.asm\"\"\n"
 .echo >> headername "#pragma asm \"include \"",noextname,".asm\"\"\n"
 .echo >> headername "#pragma asm \"segment code\"\n\n"
 
 .db libversion
#endmacro
#define .libraryVersion libraryVersion(

;---------------------------------------------

#macro function(funcret, funcname, funcargs, funclabel)
 .echo >> asmname "_",funcname," equ $\n"
 .echo >> asmname " jp ",numfunctions*3,"\n"
 .dl funclabel
 
 .echo >> headername "/***************************************************\n"
 .echo >> headername "  function: ",funcname,"\n"
 .echo >> headername "***************************************************/\n"
 .echo >> headername funcret," ",funcname,"(",funcargs,");\n\n"
 
 #define numfunctions eval(numfunctions+1)
#endmacro
#define .function function(

;---------------------------------------------

#macro asmfunction(asmfuncname, funclabel)
 .echo >> asmname "_",funcname," equ $\n"
 .echo >> asmname " jp ",numfunctions*3,"\n"
 .dl funclabel
 #define numfunctions eval(numfunctions+1)
#endmacro
#define .asmfunc asmfunction(

;---------------------------------------------

#macro endLibrary()
 clr()
 wr("_libendaddr:")
 wr("_reloc_table:")
 run()
 #include "relocation_table"
 .dl _depend_start			; ptr
 .dl _libendaddr			; size
 
 .echo >> headername "#endif\n"

 .echo "Total library size:\t",6+numrelocations*3+numfunctions*3+_libendaddr
 .echo "Extracted library size:\t",_libendaddr
 .echo "Relocation table size:\t",numrelocations*3
 .echo "Functions vector size:\t",numfunctions*3
 .echo "Success!"
#endmacro
#define .endLibrary endLibrary()

;---------------------------------------------

#macro relocate()
 #define numrelocations eval(numrelocations+1)
 
 #define offset eval($-3)
 .echo >> relocation_table " .dl ",offset,"\n"
#endmacro
#define .r relocate()

;--------------------------------------------

#macro beginDependencies()
 clr()
 wr("_depend_start:")
 run()
 .org $000000
#endmacro
#define .beginDependencies beginDependencies()
;--------------------------------------------

#macro endDependencies()
 clr()
 wr("_depend_end:")
 run()
#endmacro
#define .endDependencies endDependencies()
;--------------------------------------------

#macro comment()
 ;
#endmacro
#define segment comment()
#define .c comment()
;--------------------------------------------

#define db .db
#define dl .dl
#define dw .dw

.list