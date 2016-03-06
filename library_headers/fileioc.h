/**
 * @file    FILEIOC CE C Library
 * @version 1.0
 *
 * @section LICENSE
 *
 * Copyright (c) 2016, Matthew Waltz
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @section DESCRIPTION
 *
 * This library implements some variable opening and editing routines
 */

#ifndef H_FILEIOC
#define H_FILEIOC

#include <stdint.h>

/**
 * Varible and flag definitions
 */
#define Real                (0)
#define RealList            (1)
#define Matrix              (2)
#define Equation            (3)
#define String              (4)
#define Program             (5)
#define ProtectedProgram    (6)
#define Picture             (7)
#define GraphDatabase       (8)
#define Unknown             (9)
#define UnknownEquation     (10)
#define NewEquation         (11)
#define Complex             (12)
#define ComplexList         (13)
#define Undefined           (14)
#define Window              (15)
#define RecallWindow        (16)
#define TableRange          (17)
#define AppVar              (21)
#define TempProgram         (22)
#define Group               (23)
#define RealFraction        (24)
#define Image               (26)
#define ComplexFraction     (27)
#define RealRadical         (28)
#define ComplexRadical      (29)
#define ComplexPi           (30)
#define ComplexPiFraction   (31)
#define RealPi              (32)
#define RealPiFraction      (33)

#ifndef EOF
#define EOF (-1)
#endif

/**
 * Closes all open slots
 * Call before you use any varaible functions
 */
void ti_CloseAll(void);

/**
 * Opens a varaible given then name and flags
 * ti_Open opens an AppVar as default file storage
 * ti_OpenVar opens a Program or Protected Program, depending on the type given
 * If there isn't enough memory to create the variable, or a slot isn't open, zero (0) is returned
 * Otherwise it returns the available slot number (1-5)
 * Available modes:
 * "r"  - Opens a file for reading. The file must exist. Keeps file in archive if in archive.                                   (Archive)
 * "w"  - Creates an empty file for writing. Overwrites file if already exists.                                                 (RAM)
 * "a"  - Appends to a file. Writing operations, append data at the end of the file. The file is created if it does not exist.  (RAM)
 * "r+" - Opens a file to update both reading and writing. The file must exist. Moves file from archive to RAM if in archive.   (RAM)
 * "w+" - Creates an empty file for both reading and writing. Overwrites file if already exists.                                (RAM)
 * "a+" - Opens a file for reading and appending. Moves file from archive to RAM if in archive. Created if it does not exist.   (RAM)
 * Unlike the standard implementation of fopen, the "b" (binary) mode is not available because characters are only 8 bits wide on this platform.
 * Type:
 *  Specifies the type of variable to open
 */
uint8_t ti_Open(const char *varname, const char *mode);
uint8_t ti_OpenVar(const char *varname, const char *mode, uint8_t type);

/**
 * Frees an open variable slot
 * Returns zero if closing failed
 */
int24_t ti_Close(const uint8_t slot);

/**
 * Writes to the current variable pointer given:
 * data:
 *  pointer to data to write
 * size:
 *  size (in bytes) of the data we are writting
 * count:
 *  number of data chunks to write to the variable slot
 * slot:
 *  varaible slot to write the data to
 * Returns the number of bytes written
 */
int24_t ti_Write(const void *data, uint24_t size, uint24_t count, uint8_t slot);

/**
 * Reads from the current variable pointer given:
 * data:
 *  pointer to data to read into
 * size:
 *  size (in bytes) of the data we are reading
 * count:
 *  number of data chunks to read from the variable slot
 * slot:
 *  varaible slot to read from
 * Returns the number of bytes read
 */
uint24_t ti_Read(const void *data, uint24_t size, uint24_t count, uint8_t slot);

/**
 * Puts a character directly into the slot data pointer, and increments the offset
 * Returns 'EOF' if current offset is larger than file size, or memory isn't large enough
 * c is internally converted to an unsigned char
 * c is returned if no error occurs
 * slot:
 *  varaible slot to put the character to
 */
uint24_t ti_PutC(uint24_t c, uint8_t slot);

/**
 * Pulls a character directly from the slot data pointer, and increments the offset
 * Reads 'EOF' if current offset is larger than file size
 * slot:
 *  varaible slot to get the character from
 */
uint24_t ti_GetC(uint8_t slot);

/**
 * Seeks to an offset from the origin:
 * SEEK_SET (2) - Seek from beginning of file
 * SEEK_END (1) - Seek from end of file
 * SEEK_CUR (0) - Seek from current offset in file
 * slot:
 *  varaible slot seeking in
 */
uint24_t ti_Seek(int24_t offset, uint24_t origin, uint8_t slot);

/**
 * Seeks to the start of the given variable
 * Basically an ti_Seek(0, SEEK_SET, slot);
 * slot:
 *  varaible slot seeking in
 */
uint24_t ti_Rewind(uint8_t slot);

/**
 * Returns the value of the current cursor offset
 */
uint16_t ti_Tell(uint8_t slot);

/**
 * Returns the size of the variable in the slot
 */
uint16_t ti_GetSize(uint8_t slot);

/**
 * Resizes the slot to the new size; note that the current file
 * offset is set to the beginning of the file
 */
int24_t ti_Resize(uint24_t new_size, uint8_t slot);

/**
 * Returns zero if the slot is not in the archive
 */
int24_t ti_IsArchived(uint8_t slot);

/**
 * Sets the varaible into either the archive or RAM
 * Returns zero if the operation fails if not enough memory or some other error
 * NOTE: This routine also closes the file handle. You must reopen the file
 */
int24_t ti_SetArchiveStatus(uint8_t archived, uint8_t slot);

/**
 * ti_Delete    - Deletes an AppVar given the name
 * ti_DeleteVar - Deletes a varaible given the name and type
 */
int24_t ti_Delete(const char *varname);
int24_t ti_DeleteVar(const char *varname, uint24_t type);

#endif
