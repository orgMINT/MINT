
strDef_:                         ;= 21
strDef:                         ;= 21
    LD DE,(vHeapPtr)        ; HL = heap ptr
    PUSH DE                 ; save start of string 
    INC BC                  ; point to next char
    JR strDef2
strDef1:
    LD (DE),A
    INC DE                  ; increase count
    INC BC                  ; point to next char
strDef2:
    LD A,(BC)
    CP "`"                  ; ` is the string terminator
    JR NZ,strDef1
    XOR A                   ; write null to terminate string
    LD (DE),A
    INC DE
    JP def3

def3:
    ld (vHeapPtr),de            ; bump heap ptr to after definiton
    jp (IY)       

prnStr_:
prnStr:
    POP HL
    CALL putStr
    JP (IY)

