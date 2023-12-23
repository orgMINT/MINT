        DSIZE       EQU $80
        RSIZE       EQU $80
        LSIZE       EQU $80
        TIBSIZE     EQU $100		; 256 bytes , along line!

        VARS_SIZE      EQU 26*2*2	; A..Z, a..z words

        .ORG RAMSTART

TIB:        DS TIBSIZE

            DS RSIZE
rStack:        

            DS DSIZE
dStack:        
stack:
            DS LSIZE
lStack:
            .align $100
opcodes:    
            DS $80-32-1-1
altCodes:
            DS $80-32-1-5

            .align $100
mintVars:
            DS $30
vLoopSP:    DS 2                ; 

vByteMode:  DS 2                ; 
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

            DS 26*2
altVars:

vS0:        DS 2                ; a
vBase16:    DS 2                ; b
vCarry:     DS 2                ; c
vNS:        DS 2                ; d
vLastDef:   DS 2                ; e
            DS 2                ; f
            DS 2                ; g
vHeapPtr:   DS 2                ; h
            DS 2                ; i
            DS 2                ; j
            DS 2                ; k
            DS 2                ; l  
            DS 2                ; m  
            DS 2                ; n
            DS 2                ; o
            DS 2                ; p
            DS 2                ; q
            DS 2                ; r     
            DS 2                ; s
vTIBPtr:    DS 2                ; t
            DS 2                ; u
            DS 2                ; v
            DS 2                ; w
            DS 2                ; x     
            DS 2                ; y
            DS 2                ; z

            ; .align $40
VARS:   DS VARS_SIZE

HEAP:         
