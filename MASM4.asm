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
    memoryConsumption DWORD 0

    ;menu prompt
    strHeader0 BYTE "MASM4 TEXT EDITOR",10,"Data Structure Memory Consumption: ",0
    strHeader1 BYTE " bytes",10,"<1> View all strings",10,10,0
    strHeader2 BYTE "<2> Add string",10,"    <a> from Keyboard",10,"    <b> from File. Static file named input.txt",10,10,0
    strHeader3 BYTE "<3> Delete string. Given an index #, delete the string and de-allocate memory.",10,10,0
    strHeader4 BYTE "<4> Edit string. Given an index #, replace old string w/ new string. Allocate/De-allocate as needed.",10,10,0
    strHeader5 BYTE "<5> String search. Regardless of case, return all strings that match the substring given.",10,10,0
    strHeader6 BYTE "<6> Save File",10,10,"<7> Quit",10,10,0

    .code                       ; begin code

;###################################################
; main PROC
;   The main driver of the program. Display menu
;   and get user's choice
;###################################################
main PROC                                               ;
    call Clrscr
    INVOKE putstring, ADDR strHeader0
    INVOKE putstring, ADDR strHeader1
    INVOKE putstring, ADDR strHeader2
    INVOKE putstring, ADDR strHeader3
    INVOKE putstring, ADDR strHeader4
    INVOKE putstring, ADDR strHeader5
    INVOKE putstring, ADDR strHeader6

    INVOKE ExitProcess,0


main ENDP                                               ;

END main               	        ; end program

