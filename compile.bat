@echo off
@rem ########################################################################
@rem Credit to Robert Baker for providing this batch script.
@rem
@rem This is a build script for assembling .asm files and then linking them.
@rem The ml and link commands are included in the system path.
@rem ########################################################################

@rem ########################################################################
@rem  The projectName variable should contain the filename of the assembly
@rem  file without the file extension.
@rem  This should be the only change made to the file inbetween runs.
@rem
set projectName=MASM4
@rem
@rem set scriptPath to path to location of the script
set scriptPath=%~dp0
@rem ########################################################################

@rem ########################################################################
@rem  Do clean up of binaries from last run
echo. && echo delete %scriptPath%*.obj
del %scriptPath%*.obj
echo delete %scriptPath%*.exe && echo.
del %scriptPath%*.exe
@rem ########################################################################

@rem ########################################################################
@rem  ml    Microsoft (R) Macro Assembler Version 6.14.8444
@rem  /c        Assemble without linking
@rem  /Zd       Add number line debug info
@rem  /coff     Generate COFF format object file
@rem  /Fl       [file] Generate listing
@rem
@rem  This will output an unlinked %projectName%.obj file
\masm32\bin\ml /c /Zd /coff /Fl %projectName%.asm


if exist %projectName%.obj (
    echo. && echo Assembly Complete && echo.
) else (
    echo. && echo Assembly FAILED && echo.
    goto endScript
)
@rem ########################################################################

@rem ########################################################################
@rem  link  Microsoft (R) Incremental Linker Version 5.12.8078
@rem
@rem  /SUBSYSTEM:CONSOLE    Contains the macros for the console
@rem  /out:                 Specifies the output file
@rem
@rem  Object Files & Libs with corresponding MACROS
@rem  -------------------------------------------------------------------
@rem  | library & Object File           | Macros                        |
@rem  -------------------------------------------------------------------
@rem  | ..\macros\kernel32.lib          | * ExitProcess                 |
@rem  -------------------------------------------------------------------
@rem  | ..\macros\convutil201604.obj    | * ascint32                    |
@rem  |                                 | * intasc32                    |
@rem  |                                 | * intasc32Comma               |
@rem  |                                 | * hexToChar                   |
@rem  |                                 | * memoryallocBailey           |
@rem  -------------------------------------------------------------------
@rem  | ..\macros\utility201609.obj     | * getch                       |
@rem  |                                 | * getche                      |
@rem  |                                 | * putch                       |
@rem  |                                 | * putstring                   |
@rem  |                                 | * getstring                   |
@rem  -------------------------------------------------------------------
@rem No white space allowed after the ^.
@rem Link.exe will fail if there is any space after the ^ operator
link /SUBSYSTEM:CONSOLE /out:%projectName%.exe %projectName%.obj ^
..\macros\kernel32.lib ^
..\macros\convutil201604.obj ^
..\macros\utility201609.obj ^
..\irvine\kernel32.lib ^
..\irvine\Irvine32.lib ^
..\irvine\User32.lib

if exist %projectName%.exe (
    echo. && echo Link Complete && echo.
) else (
    echo. && echo Link FAILED && echo.
    goto endScript
)
@rem ########################################################################


@rem ########################################################################
@rem    Run the project from the command line.
@rem    Wait for a key press from the user before closing cmd window.
%projectName%.exe
:endScript
    pause
@rem ########################################################################
