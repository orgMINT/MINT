        .ORG RAMSTART

TIB:        DS TIBSIZE

            DS RSIZE
rStack:        

            DS DSIZE
dStack:        
stack:
            .align $100
opcodes:    
            DS $80
ctrlCodes:
altCodes:
            DS $80

            .align $100
mintVars:
            DS 2                ; 
vByteMode:  DS 2                ; 
            DS $30
tbPtr:      DS 2                ; reserved for tests

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

altDefs:
            DS 26*2
altVars:

vS0:        DS 2                ; a
vBase16:    DS 2                ; b
vTIBPtr:    DS 2                ; c
vNS:        DS 2                ; d
vLastDef:   DS 2                ; e
            DS 2                ; f
vAltPage:   DS 2                ; g
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
            DS 2                ; t
            DS 2                ; u
            DS 2                ; v
            DS 2                ; w
            DS 2                ; x     
            DS 2                ; y
            DS 2                ; z

; ****************************************************************
; NS Table - Each space holds 26 user commands, 26 user vars, 12 bytes free
; ****************************************************************
            .align $40
            .org $-($80-26*2*2)
            DS ($80-26*2*2)     ; 12 bytes free vars for NS 0 
NS0:        DS NSSIZE * NSNUM
NS1         EQU NS0 + NSSIZE
HEAP:         
