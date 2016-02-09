LIB = FILEIOC
SOURCES = fileio_lib.asm

AS = @"..\..\include\spasm"

ASMFLAGS =  -E
 
$(LIB) :
	$(AS) $(ASMFLAGS) $(SOURCES) $(LIB).8xv
	
all : $(LIB)