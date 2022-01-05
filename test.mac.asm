.macro expect,msg1,val1
    POP HL
    PUSH HL
    LD DE,val1
    OR A
    SBC HL,DE
    LD A,L
    OR H
    JR Z,expect%%M

    CALL printStr
    .cstr msg1,"\r\nActual: "
    CALL printdec

    CALL printStr
    .cstr "\r\nExpected: "
    LD HL,val1
    CALL printdec

    HALT
    .cstr
expect%%M:
    POP HL
.endm

.macro test,code1,val1
    CALL enter
    .cstr code1
    expect code1,val1
.endm
