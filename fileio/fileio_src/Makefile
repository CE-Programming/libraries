LIB = FILEIOC
SOURCES = template.asm

AS = @"..\..\include\spasm"

ASMFLAGS =  -E
 
$(LIB) :
	$(AS) $(ASMFLAGS) $(SOURCES) $(LIB).8xv
	
all : $(LIB)