;*************************************************************************
; Program Name : MASM 4
; Programmer(s): Jason Inciong & Jesse Mazzella
; Class        : CS3B T/Th 3:30p
; Date         : May 3, 2018
; Purpose      : 
;*************************************************************************

    .486
    .model flat, stdcall
    option casemap :none
    .stack 100h

    INCLUDE ..\Irvine\Irvine32.inc  ; Holds Irvine Prototypes
    INCLUDE ..\Irvine\Macros.inc    ; Holds Irvine Macros (because why not)

    ;**************
    ;* PROTOTYPES *
    ;**************
    ExitProcess   PROTO Near32 stdcall, dwExitCode:dword
    ascint32      PROTO Near32 stdcall, lpStringOfNumericChars:dword
    intasc32      PROTO Near32 stdcall, lpStringToHold:dword, dVal:dword
    getstring     PROTO Near32 stdcall, lpStringToGet:dword, dlength:dword
    putstring     PROTO Near32 stdcall, lpStringToPrint:dword
    getche        PROTO Near32 stdcall  ;returns character in the AL register *
    getch         PROTO Near32 stdcall  ;returns character in the AL register *
    putch         PROTO Near32 stdcall, bChar:byte

    HEAP_START = 0
    HEAP_MAX = 4000000000

    .data
    totalMem DWORD 0

    ;menu prompt
    strHeader0   BYTE "MASM4 TEXT EDITOR",10,"Data Structure Memory Consumption: ",0
    strHeader1   BYTE " bytes",10,"<1> View all strings",10,10,0
    strHeader2   BYTE "<2> Add string",10,"    <a> from Keyboard",10,"    <b> from File (Static file named input.txt)",10,10,0
    strHeader3   BYTE "<3> Delete string. Given an index #, delete the string and de-allocate memory.",10,10,0
    strHeader4   BYTE "<4> Edit string. Given an index #, replace old string w/ new string. Allocate/De-allocate as needed.",10,10,0
    strHeader5   BYTE "<5> String search. Regardless of case, return all strings that match the substring given.",10,10,0
    strHeader6   BYTE "<6> Save File",10,10,"<7> Quit",10,10,0
    strPrompt1   BYTE "Enter a selection (1 - 7): ",0

    strInput     BYTE ?
    numInput    DWORD ?
    hHeap      HANDLE ?
    pArray      DWORD ?

;***********************
;    MACRO PrintMenu   *
; Prints the main menu *
;***********************
PrintMenu MACRO
    call Clrscr                         ; Clear the screen
    mWriteString strHeader0             ; Print menu
    mWriteString strHeader1             ;
    mWriteString strHeader2             ;
    mWriteString strHeader3             ;
    mWriteString strHeader4             ;
    mWriteString strHeader5             ;
    mWriteString strHeader6             ;
endm

;**********************************
;         MACRO CreateHeap        *
; Create heap and retrieve handle *
;**********************************
CreateHeap MACRO
    push eax                                    ; Preserve eax
    INVOKE HeapCreate, 0, HEAP_START, HEAP_MAX  ; Create heap
    mov hHeap, eax                            ; Retrieve handle
    pop eax                                     ; Restore eax
endm

AllocMem MACRO handle:REQ, bytes:REQ
    push eax
    INVOKE HeapAlloc, handle, HEAP_ZERO_MEMORY, bytes
    .IF eax == NULL
        mWrite "HeapAlloc failed"
        jmp _end
    .ELSE
        mov pArray, eax
    .ENDIF
    pop eax
endm

    .code                               ; begin code

;**************************************************
; main PROC                                       *
;   The main driver of the program. Display menu  *
;   and get user's choice.                        *
;**************************************************
main PROC
    CreateHeap                          ; Create heap and store handle in hHeap
_start:
    PrintMenu                           ; Print the menu
    
    mWriteString strPrompt1             ; Prompt for a menu choice
    INVOKE getstring, ADDR strInput,1   ; Get a menu choice from user
    INVOKE ascint32, ADDR strInput      ; Convert to int for comparison
    MOV numInput, eax                   ; Store in eax

    cmp numInput, 1                          ; View all strings
    je _start

    cmp numInput, 2                          ; Add a string
    je _addString

    cmp numInput, 3                          ; Delete a string
    je _start

    cmp numInput, 4                          ; Edit a string
    je _start

    cmp numInput, 5                          ; String search
    je _start

    cmp numInput, 6                          ; Save file
    je _start

    jmp _end


_addString:
    call Crlf
 
    mWrite "Enter a selection (a - b): ",0
    INVOKE getstring, ADDR strInput,1
    cmp strInput, "a"
    je _fromKeyboard
    cmp strInput, "b"
    je _fromFile
    jmp _start

_fromKeyboard:
    jmp _start
_fromFile:
    jmp _start

_end:
    INVOKE ExitProcess,0                ; Exit gracefully

main ENDP
END main               	                ; End program
