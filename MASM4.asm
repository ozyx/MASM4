;*************************************************************************
; Program Name : MASM 4
; Programmer(s): Jason Inciong & Jesse Mazzella
; Class        : CS3B T/Th 3:30p
; Date         : 
; Purpose      : 
;*************************************************************************

    .486
    .model flat, stdcall
    option casemap :none
    .stack 100h

    INCLUDE ..\Irvine\Irvine32.inc  ; Holds Irvine Prototypes

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

.data
.code

main PROC                           ;
    INVOKE ExitProcess, 0           ; Exit gracefully
main ENDP                           ;
END main               	            ; end program
