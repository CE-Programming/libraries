LIB = KEYPADC
SOURCES = keypad_lib_old.asm

AS = "..\..\..\include\spasm"

ASMFLAGS =  -E
 
$(LIB) :
	@$(AS) $(ASMFLAGS) $(SOURCES) $(LIB).8xv
	
all : $(LIB)