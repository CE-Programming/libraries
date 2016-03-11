/**
 * @file    KEYPADC CE C Library
 * @version 2.0
 *
 * @section LICENSE
 *
 * Copyright (c) 2016
 * Matthew Waltz
 * Shaun "Methsoft" McFall
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
 * This library implements some simple keyboard reading routines
 */

#ifndef H_KEYPADC
#define H_KEYPADC

#include <stdint.h>
#include <stdbool.h>

typedef uint16_t key_t;

/**
 * Scans the given keyboard row and returns the row value
 * Note: Diasbles interrupts
 */
uint8_t kb_ScanGroup(uint8_t row);

/**
 * Scans the keyboard quickly to tell if any key was pressed
 * Note: Diasbles interrupts
 */
uint8_t kb_AnyKey(void);

/**
 * Scans the keyboard to update data values
 * Note: Diasbles interrupts
 */
void kb_Scan(void);

/**
 * Resets the keyboard
 * Only use if you modify keyboard timmings or numer of rows
 */
void kb_Reset(void);

/**
 * Keyboard group 0 (Unused)
 */
#define kb_group_0      0

/**
 * Keyboard group 1
 */
#define kb_group_1    1
#define kb_Graph      1<<0
#define kb_Trace      1<<1
#define kb_Zoom       1<<2
#define kb_Window     1<<3
#define kb_Yequ       1<<4
#define kb_2nd        1<<5
#define kb_Mode       1<<6
#define kb_Del        1<<7

/**
 * Keyboard group 2
 */
#define kb_group_2    2
#define kb_Store      1<<1
#define kb_Ln         1<<2
#define kb_Log        1<<3
#define kb_Square     1<<4
#define kb_Recip      1<<5
#define kb_Math       1<<6
#define kb_Alpha      1<<7

/**
 * Keyboard group 3
 */
#define kb_group_3    3
#define kb_0          1<<0
#define kb_1          1<<1
#define kb_4          1<<2
#define kb_7          1<<3
#define kb_Comma      1<<4
#define kb_Sin        1<<5
#define kb_Apps       1<<6
#define kb_GraphVar   1<<7

/**
 * Keyboard group 4
 */
#define kb_group_4    4
#define kb_DecPnt     1<<0
#define kb_2          1<<1
#define kb_5          1<<2
#define kb_8          1<<3
#define kb_LParen     1<<4
#define kb_Cos        1<<5
#define kb_Pgrm       1<<6
#define kb_Stat       1<<7

/**
 * Keyboard group 5
 */
#define kb_group_5    5
#define kb_Chs        1<<0
#define kb_3          1<<1
#define kb_6          1<<2
#define kb_9          1<<3
#define kb_RParen     1<<4
#define kb_Tan        1<<5
#define kb_Vars       1<<6

/**
 * Keyboard group 6
 */
#define kb_group_6    6
#define kb_Enter      1<<0
#define kb_Add        1<<1
#define kb_Sub        1<<2
#define kb_Mul        1<<3
#define kb_Div        1<<4
#define kb_Power      1<<5
#define kb_Clear      1<<6

/**
 * Keyboard group 7
 */
#define kb_group_7    7
#define kb_Down       1<<0
#define kb_Left       1<<1
#define kb_Right      1<<2
#define kb_Up         1<<3

#define kb_dataArray ((uint16_t*)0xF50010)

/**
* Keyboard group 1
*/
#define kb_KeyGraph           (key_t)(1 << 8 | 1<<0)
#define key_trace           (key_t)(1 << 8 | 1<<1)
#define kb_KeyZoom            (key_t)(1 << 8 | 1<<2)
#define kb_KeyWindow          (key_t)(1 << 8 | 1<<3)
#define kb_KeyYequ            (key_t)(1 << 8 | 1<<4)
#define kb_Key2nd             (key_t)(1 << 8 | 1<<5)
#define kb_KeyMode            (key_t)(1 << 8 | 1<<6)
#define kb_KeyDel             (key_t)(1 << 8 | 1<<7)

/**
* Keyboard group 2
*/
#define kb_KeyStore           (key_t)(2 << 8 | 1<<1)
#define kb_KeyLn              (key_t)(2 << 8 | 1<<2)
#define kb_KeyLog             (key_t)(2 << 8 | 1<<3)
#define kb_KeySquare          (key_t)(2 << 8 | 1<<4)
#define kb_KeyRecip           (key_t)(2 << 8 | 1<<5)
#define kb_KeyMath            (key_t)(2 << 8 | 1<<6)
#define kb_KeyAlpha           (key_t)(2 << 8 | 1<<7)

/**
* Keyboard group 3
*/
#define kb_Key0               (key_t)(3 << 8 | 1<<0)
#define kb_Key1               (key_t)(3 << 8 | 1<<1)
#define kb_Key4               (key_t)(3 << 8 | 1<<2)
#define kb_Key7               (key_t)(3 << 8 | 1<<3)
#define kb_KeyComma           (key_t)(3 << 8 | 1<<4)
#define kb_KeySin             (key_t)(3 << 8 | 1<<5)
#define kb_KeyApps            (key_t)(3 << 8 | 1<<6)
#define kb_KeyGraphVar        (key_t)(3 << 8 | 1<<7)

/**
* Keyboard group 4
*/
#define kb_KeyDecPnt          (key_t)(4 << 8 | 1<<0)
#define kb_Key2               (key_t)(4 << 8 | 1<<1)
#define kb_Key5               (key_t)(4 << 8 | 1<<2)
#define kb_Key8               (key_t)(4 << 8 | 1<<3)
#define kb_KeyLParen          (key_t)(4 << 8 | 1<<4)
#define kb_KeyCos             (key_t)(4 << 8 | 1<<5)
#define kb_KeyPgrm            (key_t)(4 << 8 | 1<<6)
#define kb_KeyStat            (key_t)(4 << 8 | 1<<7)

/**
* Keyboard group 5
*/
#define kb_KeyChs            (key_t)(5 << 8 | 1<<0)
#define kb_Key3              (key_t)(5 << 8 | 1<<1)
#define kb_Key6              (key_t)(5 << 8 | 1<<2)
#define kb_Key9              (key_t)(5 << 8 | 1<<3)
#define kb_KeyRParen         (key_t)(5 << 8 | 1<<4)
#define key_tan            (key_t)(5 << 8 | 1<<5)
#define kb_KeyVars           (key_t)(5 << 8 | 1<<6)

/**
* Keyboard group 6
*/
#define kb_KeyEnter          (key_t)(6 << 8 | 1<<0)
#define kb_KeyAdd            (key_t)(6 << 8 | 1<<1)
#define kb_KeySub            (key_t)(6 << 8 | 1<<2)
#define kb_KeyMul            (key_t)(6 << 8 | 1<<3)
#define kb_KeyDiv            (key_t)(6 << 8 | 1<<4)
#define kb_KeyPower          (key_t)(6 << 8 | 1<<5)
#define kb_KeyClear          (key_t)(6 << 8 | 1<<6)

/**
* Keyboard group 7
*/
#define kb_KeyDown           (key_t)(7 << 8 | 1<<0)
#define kb_KeyLeft           (key_t)(7 << 8 | 1<<1)
#define kb_KeyRight          (key_t)(7 << 8 | 1<<2)
#define kb_KeyUp             (key_t)(7 << 8 | 1<<3)

#endif
