.macro expect,msg1,val1
    POP HL
    PUSH HL
    LD DE,val1
    OR A
    SBC HL,DE
    LD A,L
    OR H
    pop hl
    JR Z,expect%%M

    CALL printStr
    .cstr "\r\n\r\n",msg1,"\r\nActual: "
    CALL printdec

    CALL printStr
    .cstr "\r\nExpected: "
    LD HL,val1
    CALL printdec

    HALT
    .cstr
expect%%M:
.endm

.macro test,code1,val1
    LD SP,DSTACK
    CALL init
    CALL enter
    .cstr code1
    expect code1,val1
.endm

.macro print,msg1
    CALL printStr
    .cstr "\r\n",msg1,"\r\n"
.endm
