DSIZE       EQU $80
RSIZE       EQU $80
TIBSIZE     EQU $100		; 256 bytes , along line!
VARS_SIZE   equ 26*2

.ORG RAMSTART

TIB:        DS TIBSIZE

            DS RSIZE
rStack:        

            DS DSIZE
dStack:        
stack:
tbPtr:      DS 2                ; reserved for tests
vTemp1:     ds 2                ; 
vTemp2:     ds 2                ; 

RST08:      DS 2                 
RST10:      DS 2                 
RST18:      DS 2                 
RST20:      DS 2                 
RST28:      DS 2                 
RST30:      DS 2                ; 
BAUD        DS 2                ; 
INTVEC:     DS 2                ; 
NMIVEC:     DS 2                ; 
GETCVEC:    DS 2                ;   
PUTCVEC:    DS 2                ;   

            .align $100
opcodes:    
            DS $80-32-1-1
altCodes:
            DS 26

            .align $100

vars:       DS VARS_SIZE
defs:       DS VARS_SIZE

altVars:
            DS 2                ; a
vByteMode:  DS 2                ; b
vCarry:     DS 2                ; c carry variable
            DS 2                ; d
            DS 2                ; e
vIntFunc:   DS 2                ; f interrupt func
            DS 2                ; g
vHeapPtr:   DS 2                ; h heap pointer variable
            DS 2                ; i loop variable
            DS 2                ; j outer loop variable
vTIBPtr:    DS 2                ; k address of text input buffer
            DS 2                ; l  
            DS 2                ; m  
            DS 2                ; n 
            DS 2                ; o
            DS 2                ; p
            DS 2                ; q
vRemain:    DS 2                ; r remainder of last division     
vStkStart:  DS 2                ; s address of start of stack
            DS 2                ; t
            DS 2                ; u
vIntID:     DS 2                ; v interrupt id
            DS 2                ; w
            DS 2                ; x     
            DS 2                ; y
vLastDef:   DS 2                ; z name of last defined function

vPointer:   DS 2                ; 
vElse:      DS 2                ; 

HEAP:         
