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
    HEAP_MAX   = 400000000
    STRING_MAX = 512

    .data
    totalMem    DWORD 0
    strTotalMem  BYTE "00000000",0
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
    dLength     DWORD ?

;***********************
;    MACRO PrintMenu   *
; Prints the main menu *
;***********************
PrintMenu MACRO
    call Clrscr                         ; Clear the screen
    mWriteString strHeader0             ; Print menu
    mWriteString strTotalMem            ; Print total bytes
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
    INVOKE HeapCreate, 
        HEAP_ZERO_MEMORY, 
        HEAP_START, 
        HEAP_MAX  ; Create heap
    mov hHeap, eax                              ; Retrieve handle
    pop eax                                     ; Restore eax
endm

;**************************************
;         MACRO AllocMem              *
; Allocate memory and store in pArray *
;**************************************
AllocMem MACRO bytes:REQ
    push eax                                    ; Preserve eax
    INVOKE HeapAlloc,                           ; Allocate memory on the heap
            hHeap, 
            HEAP_ZERO_MEMORY, dLength
    .IF eax == NULL
        mWrite "HeapAlloc failed"               ; Print error
        jmp _end                                ; Terminate. (TODO: Grow heap?)
    .ELSE
        mov pArray, eax                         ; Store base address in pArray
    .ENDIF
    pop eax                                     ; Restore eax
endm

    .code                               ; begin code

;**************************************************
; main PROC                                       *
;   The main driver of the program. Display menu  *
;   and get user's choice.                        *
;**************************************************
main PROC
_setup:
    CreateHeap                          ; Create heap and store handle in hHeap
_mainmenu:
    PrintMenu                           ; Print the menu
    
    mWriteString strPrompt1             ; Prompt for a menu choice
    INVOKE getstring, ADDR strInput,1   ; Get a menu choice from user
    INVOKE ascint32, ADDR strInput      ; Convert to int for comparison
    MOV numInput, eax                   ; Store in eax

    cmp numInput, 1                     ; View all strings
    je _mainmenu

    cmp numInput, 2                     ; Add a string
    je _addString

    cmp numInput, 3                     ; Delete a string
    je _mainmenu

    cmp numInput, 4                     ; Edit a string
    je _mainmenu

    cmp numInput, 5                     ; String search
    je _mainmenu

    cmp numInput, 6                     ; Save file
    je _mainmenu

    jmp _end


_addString:
    call Crlf                                    ; Print newline
    mWrite "Enter a selection (a - b): "         ; Prompt user
    INVOKE getstring, ADDR strInput,1            ; Get user choice
    cmp strInput, "a"                            ; If a
    je _fromKeyboard                             ; Get user input from keyboard
    cmp strInput, "b"                            ; If b
    je _fromFile                                 ; Read from file
    jmp _mainmenu                                ; Anything else, go back to main menu

_fromKeyboard:
    call Crlf                                    ; Print newline
    mWrite "Enter a string: "                    ; Prompt user
    INVOKE getstring, ADDR strInput, STRING_MAX  ; Get string in strInput, MAX = 512 BYTES
    mov ebx, OFFSET strInput                     ; Store string in eax
    push ebx                                     ; Pass string to String_length
    call String_length                           ; Get length of string in eax
    add esp, 4                                   ; Clean up stack
    mov dLength, eax                             ; Store length in dLength
    cmp dLength, 0                               ; Is it an empty string?
    je _mainmenu                                 ; If so, jump back to menu
    AllocMem dLength                             ; Otherwise, allocate memory
    jmp _mainmenu                                ; Go to main menu
_fromFile:
    jmp _mainmenu

_end:
    INVOKE HeapDestroy, hHeap           ; Destroy the heap!!
    INVOKE ExitProcess,0                ; Exit gracefully

main ENDP

;###################################################
; String_length PROC
;   Calculate length of string
; Receives: A string
; Returns: The length of the string in eax
;###################################################
String_length PROC
x_param EQU [ebp + 8]           ; set macro for x
        push ebp                ; save base pointer
        mov ebp, esp            ; set ebp equal to esp

        push esi                ; save stack index pointer
        push ebx                ; save ebx

        mov eax, 0              ; initialize eax to 0
        mov ebx, x_param        ; pass our parameter
        mov esi, 0              ; set stack index pointer to 0
    startloop:
        cmp BYTE ptr[ebx+esi],0 ; check if we are at the end of the string
        je endloop              ; if so, jump to endloop
        inc eax                 ; else, increment count
        inc esi                 ; point to next letter
        jmp startloop           ; loop
    endloop:
        pop ebx                 ; restore ebx
        pop esi                 ; restore esi

        pop ebp                 ; restore base pointer value
        ret                     ; return -- caller must clean up the stack
String_length ENDP

END main               	        ; end program
