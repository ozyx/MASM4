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
    ExitProcess       PROTO Near32 stdcall, dwExitCode:dword

    HEAP_START = 0
    HEAP_MAX   = 400000000
    STRING_MAX = 512

    ListNode STRUCT
        ALIGN    BYTE
        strLine  BYTE STRING_MAX DUP(0)      ; Address to line
        ALIGN   DWORD
        dwNext  DWORD 0                     ; Address to next node
    ListNode ENDS

    sumOfEntryFields = SIZEOF ListNode.strLine

    .data

    
    totalMem    DWORD 0                     ; Total memory allocated on the heap
    strTotalMem  BYTE "00000000",0          ; Total memory converted to a string for display in menu
    ;menu prompt
    strHeader0   BYTE "MASM4 TEXT EDITOR",10,"Data Structure Memory Consumption: ",0
    strHeader1   BYTE " bytes",10,"<1> View all strings",10,10,0
    strHeader2   BYTE "<2> Add string",10,"    <a> from Keyboard",10,"    <b> from File (Static file named input.txt)",10,10,0
    strHeader3   BYTE "<3> Delete string. Given an index #, delete the string and de-allocate memory.",10,10,0
    strHeader4   BYTE "<4> Edit string. Given an index #, replace old string w/ new string. Allocate/De-allocate as needed.",10,10,0
    strHeader5   BYTE "<5> String search. Regardless of case, return all strings that match the substring given.",10,10,0
    strHeader6   BYTE "<6> Save File",10,10,"<7> Quit",10,10,0
    strPrompt1   BYTE "Enter a selection (1 - 7): ",0

    charIn       BYTE ?
    hHeap      HANDLE ?
    pArray      DWORD ?
    dwLength    DWORD ?
    dwFlags     DWORD HEAP_ZERO_MEMORY      ; Flags to use for HeapCreate, HeapAlloc, etc
    dwBytes     DWORD 0                     ; Bytes to allocate memory

    head        DWORD ?                     ; Pointer to first node in list
    tail        DWORD ?                     ; Pointer to last node in list
    currNod     DWORD ?                     ; Pointer to the current node
    prevNod     DWORD 0                     ; Pointer to the previous node
    nextNod     DWORD 0                     ; Pointer to the next node

    thisNode ListNode{}                     ; ListNode object

;*****************************
;       MACRO InitList       *
; Initialize the linked list *
;*****************************
InitList MACRO
    mov dwBytes, SIZEOF ListNode            ; Allocate memory for a ListNode
    AddNode dwBytes                         ; Call AddNode
    mov eax, pArray                         ; Store initial address in eax
    mov head, eax                           ; Store address of first node in head
endm

;***********************
;    MACRO AddNode     *
; Add a new node to    *
; the list             *
;***********************
AddNode MACRO bytes:REQ
    push ebx                                ; Preserve ebx
    AllocMem bytes                          ; Allocate a certain number of bytes
    mov ebx,  pArray                        ; Move memory address to ebx
    mov tail, ebx                           ; Store the new address for tail
    pop ebx                                 ; Restore ebx
endm

PrintNode MACRO
    mov edi, head
    mov ebx, 00h

_displaystart:
    cmp [edi+sumOfEntryFields],ebx
    je _mainmenu

    mWrite "DISPLAYING NODE: "
    mov eax, [edi]
    mov prevNod, eax
    mov edx, edi
    call WriteString
    call Crlf

    add edi, SIZEOF thisNode.strLine
    mov edi, [edi]
    mov currNod, edi
    jmp _displaystart
endm

;***********************
;    MACRO PrintMenu   *
; Prints the main menu *
;***********************
PrintMenu MACRO
    ; call Clrscr                       ; Clear the screen
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
        dwFlags, 
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
            dwFlags, bytes
    .IF eax == NULL
        mWrite "HeapAlloc failed"               ; Print error
    .ELSE
        mov pArray, eax                         ; Store base address in pArray
    .ENDIF
    pop eax                                     ; Restore eax
endm

    .code                                       ; begin code

;**************************************************
; main PROC                                       *
;   The main driver of the program. Display menu  *
;   and get user's choice.                        *
;**************************************************
main PROC
_setup:
    CreateHeap                        ; Create heap and store handle in hHeap
    InitList                          ; Initialize the linked list

_mainmenu:

    mov eax, tail                     ; Move tail to eax
    mov currNod, eax                  ; Update current node

    PrintMenu                         ; Print the menu
    
    mWriteString strPrompt1           ; Prompt for a menu choice
    call ReadChar                     ; Get choice from user in al
    MOV charIn, al                    ; Store user choice in charIn

    cmp charIn, "1"                   ; View all strings
    je _print

    cmp charIn, "2"                   ; Add a string
    je _addString

    cmp charIn, "3"                   ; Delete a string
    je _mainmenu

    cmp charIn, "4"                   ; Edit a string
    je _mainmenu

    cmp charIn, "5"                   ; String search
    je _mainmenu

    cmp charIn, "6"                   ; Save file
    je _mainmenu

    jmp _end

_print:
    ; call Clrscr
    ; call Crlf
    PrintNode
    jmp _mainmenu

_addString:
    call Crlf                                    ; Print newline
    mWrite "Enter a selection (a - b): "         ; Prompt user
    call ReadChar                                ; Get user choice in al
    cmp al, "a"                                  ; If a
    je _fromKeyboard                             ; Get user input from keyboard
    cmp al, "b"                                  ; If b
    je _fromFile                                 ; Read from file
    jmp _mainmenu                                ; Anything else, go back to main menu

_fromKeyboard:
    call Crlf                                    ; Print newline
    mWrite "Enter a string: "                    ; Prompt user
    mReadString thisNode.strLine                 ; Read string from user into strBuffer
    mov dwLength, eax                            ; Store length in dwLength
    cmp dwLength, 0                              ; Is it an empty string?
    je _mainmenu                                 ; If so, jump back to menu

    AddNode dwBytes                              ; Otherwise, add a new node
    mov eax, tail                                ; Move tail to eax
    mov thisNode.dwNext, eax                     ; The current node's next-ptr will point to tail

    mov esi, OFFSET thisNode                     ; Move address of this node to esi
    mov edi, currNod                             ; Move currNod to edi
    
    INVOKE Str_copy, ADDR thisNode.strLine, edi  ; Copy the line into the new node object
    add edi, SIZEOF thisNode.strLine             ; Add size of strLine to edi
    mov eax, (ListNode PTR [esi]).dwNext         ; Move next node address into eax

    mov [edi], eax                               ; Next node address into edi
    jmp _mainmenu                                ; Go to main menu

_fromFile:
    jmp _mainmenu

_end:
    INVOKE HeapDestroy, hHeap           ; Destroy the heap!!
    INVOKE ExitProcess,0                ; Exit gracefully

main ENDP
END main               	        ; end program
