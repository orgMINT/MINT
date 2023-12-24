; *************************************************************************
;
;       MINT Minimal Interpreter for the Z80 
;
;       Ken Boak, John Hardy and Craig Jones. 
;
;       GNU GENERAL PUBLIC LICENSE                   Version 3, 29 June 2007
;
;       see the LICENSE file in this repo for more information 
;
; *****************************************************************************
    TRUE        EQU 1		; not FF, for MINT
    FALSE       EQU 0
    EMPTY       EQU 0		; for an empty macro, ctrl-<something>=macro, ie ctrl-h = backspace macros (in MINT)

    CTRL_C      equ 3
    CTRL_E      equ 5
    CTRL_H      equ 8
    CTRL_J      equ 10
    CTRL_L      equ 12
    CTRL_P      equ 16

.macro LITDAT,len
    db len
.endm

.macro REPDAT,len,data			; compress the command tables
    
    db (len | $80)
    db data
.endm

.macro ENDDAT
    db 0
.endm

; **************************************************************************
; Page 0  Initialisation
; **************************************************************************		

	.ORG ROMSTART + $180		; 0+180 put mint code from here	

; **************************************************************************
; Macros must be written in Mint and end with ; 
; this code must not span pages
; **************************************************************************
macros:

reedit_:
    db "\\e\\@\\L;"			; remembers last line edited

edit_:
    .cstr "`?`?\\P\\L;"

list_:
    .cstr "\\N26(\\i@65+\\L\\t@0>(\\N))\\P;"

printStack_:
    .cstr "\\T\\P;"        

iOpcodes:
    LITDAT 15
    db    lsb(store_)   ;   !            
    db    lsb(dup_)     ;   "
    db    lsb(hex_)     ;    #
    db    lsb(swap_)    ;    $            
    db    lsb(over_)    ;    %            
    db    lsb(and_)     ;    &
    db    lsb(drop_)    ;    '
    db    lsb(begin_)   ;    (        
    db    lsb(again_)   ;    )
    db    lsb(mul_)     ;    *            
    db    lsb(add_)     ;    +
    db    lsb(hdot_)    ;    ,            
    db    lsb(sub_)     ;    -
    db    lsb(dot_)     ;    .
    db    lsb(div_)     ;    /	;/MOD

    REPDAT 10, lsb(num_)		; 10 x repeat lsb of add to the num routine 

    LITDAT 7
    db    lsb(def_)    ;    :        
    db    lsb(ret_)    ;    ;
    db    lsb(lt_)     ;    <
    db    lsb(eq_)     ;    =            
    db    lsb(gt_)     ;    >            
    db    lsb(key_)    ;    ?   ( -- val )  read a char from input
    db    lsb(fetch_)  ;    @    

    REPDAT 26, lsb(call_)		; call a command A, B ....Z

    LITDAT 6
    db    lsb(arrDef_) ;    [
    db    lsb(alt_)    ;    \
    db    lsb(arrEnd_) ;    ]
    db    lsb(xor_)    ;    ^
    db    lsb(arrIndex_)    ;    _   
    db    lsb(str_)    ;    `   ; for printing `hello`        

    REPDAT 26, lsb(var_)		; a b c .....z

    LITDAT 4
    db    lsb(shl_)    ;    {
    db    lsb(or_)     ;    |            
    db    lsb(shr_)    ;    }            
    db    lsb(rot_)    ;    ~ ( a b c -- b c a ) rotate            

iAltCodes:

    LITDAT 4
    db     lsb(cstore_)     ;!  byte store     
    db     lsb(aNop_)       ;"  				
    db     lsb(aNop_)       ;#  edit definition 				
    db     lsb(newln_)      ;$  prints a newline to output	

    REPDAT 7, lsb(aNop_)
                            ; %
                            ; &
                            ; '
                            ; (
                            ; )
                            ; *
                            ; +

    LITDAT 2
    db     lsb(emit_)       ;,  ( b -- ) prints a char              
    db     lsb(depth_)      ;-  num items on stack

    REPDAT 12, lsb(aNop_)
                            ;.              
                            ;/                
                            ;0
                            ;1
                            ;2
                            ;3
                            ;4
                            ;5
                            ;6
                            ;7
                            ;8
                            ;9
                            
    LITDAT 1
    db     lsb(anonDef_)    ;:  return add of a anon def, \: 1 2 3;    \\ ret add of this                

    REPDAT 5, lsb(aNop_)
                            ;;                
                            ;<  
                            ;=    
                            ;>  
                            ;?  

    LITDAT 21
    db     lsb(cFetch_)     ;@      byte fetch
    db     lsb(aNop_)       ;A
    db     lsb(break_)      ;B      conditional break from loop
    db     lsb(aNop_)       ;C
    db     lsb(depth_)      ;D      num items on stack
    db     lsb(emit_)       ;E      emit a char
    db     lsb(aNop_)       ;F
    db     lsb(go_)         ;G      execute mint code
    db     lsb(aNop_)       ;H
    db     lsb(inPort_)     ;I      input from port
    db     lsb(aNop_)       ;J
    db     lsb(aNop_)       ;K
    db     lsb(editDef_)    ;L      edit line
    db     lsb(aNop_)       ;M
    db     lsb(newln_)      ;N      prints a newline to output
    db     lsb(outPort_)    ;O      output to port
    db     lsb(prompt_)     ;P      print MINT prompt
    db     lsb(aNop_)       ;Q
    db     lsb(aNop_)       ;R
    db     lsb(arrSize_)    ;S      array size
    db     lsb(printStk_)   ;T      non-destructively prints stack
    
    REPDAT 3, lsb(aNop_)
                            ;U
                            ;V
                            ;W      
    
    LITDAT 1
    db     lsb(exec_)       ;X      execute machine code 
    
    REPDAT 2, lsb(aNop_)
                            ;Y
                            ;Z

    LITDAT 2
    db     lsb(cArrDef_)    ;[      byte array
    db     lsb(comment_)    ;\      comment text, skips reading until end of line

    REPDAT 4, lsb(aNop_)
                            ; ]
                            ; ^
                            ; _
                            ; `

    REPDAT 8, lsb(altVar_)  ;a...h

    LITDAT 2
    db     lsb(i_)          ;i  returns index variable of current loop          
    db     lsb(j_)          ;j  returns index variable of outer loop     \i+6     

    REPDAT 16, lsb(altVar_) ;k...z

    ENDDAT 

backSpace:
    ld a,c
    or b
    jp z, interpret2
    dec bc
    call printStr
    .cstr "\b \b"
    jp interpret2
    
start:
    ld SP,DSTACK		; start of MINT
    call init		    ; setups
    call printStr		; prog count to stack, put code line 235 on stack then call print
    .cstr "MINT1.3\r\n"

interpret:
    call prompt

    ld BC,0                 ; load BC with offset into TIB, decide char into tib or execute or control         
    ld (vTIBPtr),BC

interpret2:                     ; calc nesting (a macro might have changed it)
    ld E,0                  ; initilize nesting value
    push BC                 ; save offset into TIB, 
                            ; BC is also the count of chars in TIB
    ld hl,TIB               ; hl is start of TIB
    jr interpret4

interpret3:
    ld A,(hl)               ; A = char in TIB
    inc hl                  ; inc pointer into TIB
    dec BC                  ; dec count of chars in TIB
    call nesting            ; update nesting value

interpret4:
    ld A,C                  ; is count zero?
    or B
    jr NZ, interpret3       ; if not loop
    pop BC                  ; restore offset into TIB
; *******************************************************************         
; Wait for a character from the serial input (keyboard) 
; and store it in the text buffer. Keep accepting characters,
; increasing the instruction pointer BC - until a newline received.
; *******************************************************************

waitchar:   
    call getchar            ; loop around waiting for character from serial port
    CP $20			; compare to space
    jr NC,waitchar1		; if >= space, if below 20 set cary flag
    CP $0                   ; is it end of string? null end of string
    jr Z,waitchar4
    CP '\r'                 ; carriage return? ascii 13
    jr Z,waitchar3		; if anything else its macro/control 
    cp CTRL_H
    jr z,backSpace
    ld d,msb(macros)
    cp CTRL_E
    ld e,lsb(edit_)
    jr z,macro
    cp CTRL_J
    ld e,lsb(reedit_)
    jr z,macro
    cp CTRL_L
    ld e,lsb(list_)
    jr z,macro
    cp CTRL_P
    ld e,lsb(printStack_)
    jr z,macro
    jr interpret2

macro:                          ;=25
    ld (vTIBPtr),BC
    push de
    call ENTER		;mint go operation and jump to it
    .cstr "\\G"
    ld BC,(vTIBPtr)
    jr interpret2

waitchar1:
    ld hl,TIB
    add hl,BC
    ld (hl),A               ; store the character in textbuf
    inc BC
    call putchar            ; echo character to screen
    call nesting
    jr  waitchar            ; wait for next character

waitchar3:
    ld hl,TIB
    add hl,BC
    ld (hl),"\r"            ; store the crlf in textbuf
    inc hl
    ld (hl),"\n"            
    inc hl                  ; ????
    inc BC
    inc BC
    call crlf               ; echo character to screen
    ld A,E                  ; if zero nesting append and ETX after \r
    or A
    jr NZ,waitchar
    ld (hl),$03             ; store end of text ETX in text buffer 
    inc BC

waitchar4:    
    ld (vTIBPtr),BC
    ld BC,TIB               ; Instructions stored on heap at address HERE, we pressed enter
    dec BC

; ********************************************************************************
;
; Dispatch Routine.
;
; Get the next character and form a 1 byte jump address
;
; This target jump address is loaded into hl, and using jp (hl) to quickly 
; jump to the selected function.
;
; Individual handler routines will deal with each category:
;
; 1. Detect characters A-Z and jump to the User Command handler routine
;
; 2. Detect characters a-z and jump to the variable handler routine
;
; 3. All other characters are punctuation and cause a jump to the associated
; primitive code.
;
; Instruction Pointer IP BC is incremented
;
; *********************************************************************************
NEXT:                           ;      
    inc BC                      ;       Increment the IP
    ld A, (BC)                  ;       Get the next character and dispatch
    or a                        ; is it NUL?       
    jr z,exit
    cp CTRL_C
    jr z,etx
    sub "!"
    jr c,NEXT
    ld L,A                      ;       Index into table
    ld H,msb(opcodes)           ;       Start address of jump table         
    ld L,(hl)                   ;       get low jump address
    ld H,msb(page4)             ;       Load H with the 1st page address
    jp (hl)                     ;       Jump to routine

exit:
    inc BC			; store offests into a table of bytes, smaller
    ld de,BC                
    call rpop               ; Restore Instruction pointer
    ld BC,hl
    EX de,hl
    jp (hl)

etx:                                ;=12
    ld hl,-DSTACK               ; check if stack pointer is underwater
    add hl,SP
    jr NC,etx1
    ld SP,DSTACK
etx1:
    jp interpret

init:                           ;=68
    ld hl,LSTACK
    ld (vLoopSP),hl         ; Loop stack pointer stored in memory
    ld IX,RSTACK
    ld IY,NEXT		; IY provides a faster jump to NEXT

    ld hl,altVars               ; init altVars to 0 
    ld b,26 * 2
init1:
    ld (hl),0
    inc hl
    djnz init1
    ld hl,dStack
    ld (vS0),hl
    ld hl,65
    ld (vLastDef),hl
    ld hl,HEAP
    ld (vHeapPtr),hl

    ld hl,VARS              ; init namespaces to 0 using LDIR
    ld de,hl
    inc de
    ld (hl),0
    ld BC,VARS_SIZE
    LDIR

initOps:
    ld hl, iOpcodes
    ld de, opcodes
    ld BC, 256

initOps1:
    ld A,(hl)
    inc hl
    SLA A                     
    RET Z
    jr C, initOps2
    SRL A
    ld C,A
    ld B,0
    LDIR
    jr initOps1
    
initOps2:        
    SRL A
    ld B,A
    ld A,(hl)
    inc hl
initOps2a:
    ld (de),A
    inc de
    DJNZ initOps2a
    jr initOps1

lookupRef:
    ld D,0
lookupRef0:
    CP "a"
    jr NC,lookupRef2
lookupRef1:
    SUB "A"
    ld E,0
    jr lookupRef3        
lookupRef2:
    SUB "a"
    ld E,26*2
lookupRef3:
    add A,A
    add A,E
    ld hl,VARS
    add A,L
    ld L,A
    ld A,0
    ADC A,H
    ld H,A
    XOR A
    or E                        ; sets Z flag if A-Z
    RET

printhex:                           ;=31  
                                ; Display hl as a 16-bit number in hex.
    push BC                     ; preserve the IP
    ld A,H
    call printhex2
    ld A,L
    call printhex2
    pop BC
    RET
printhex2:		                    
    ld	C,A
	RRA 
	RRA 
	RRA 
	RRA 
    call printhex3
    ld A,C
printhex3:		
    and	0x0F
	add	A,0x90
	DAA
	ADC	A,0x40
	DAA
	jp putchar

; **************************************************************************             
; calculate nesting value
; A is char to be tested, 
; E is the nesting value (initially 0)
; E is increased by ( and [ 
; E is decreased by ) and ]
; E has its bit 7 toggled by `
; limited to 127 levels
; **************************************************************************             

nesting:                        ;=44
    CP '`'
    jr NZ,nesting1
    BIT 7,E
    jr Z,nesting1a
    RES 7,E
    RET
nesting1a: 
    SET 7,E
    RET
nesting1:
    BIT 7,E             
    RET NZ             
    CP ':'
    jr Z,nesting2
    CP '['
    jr Z,nesting2
    CP '('
    jr NZ,nesting3
nesting2:
    inc E
    RET
nesting3:
    CP ';'
    jr Z,nesting4
    CP ']'
    jr Z,nesting4
    CP ')'
    RET NZ
nesting4:
    dec E
    RET 

prompt:                             ;=9
    call printStr
    .cstr "\r\n> "
    RET

crlf:                               ;=7
    call printStr
    .cstr "\r\n"
    RET

printStr:                           ;=7
    EX (SP),hl		                ; swap			
    call putStr		
    inc hl			                ; inc past null
    EX (SP),hl		                ; put it back	
    RET

putStr0:                            ;=9
    call putchar
    inc hl
putStr:
    ld A,(hl)
    or A
    jr NZ,putStr0
    RET

rpush:                              ;=11
    dec IX                  
    ld (IX+0),H
    dec IX
    ld (IX+0),L
    RET

rpop:                               ;=11
    ld L,(IX+0)         
    inc IX              
    ld H,(IX+0)
    inc IX                  
rpop2:
    RET

writeChar:                          ;=5
    ld (hl),A
    inc hl
    jp putchar

enter:                              ;=9
    ld hl,BC
    call rpush                      ; save Instruction Pointer
    pop BC
    dec BC
    jp (IY)                    


; **********************************************************************			 
; Page 4 primitive routines 
; **********************************************************************
    .align $100
page4:

and_:        
    pop     de          ;     Bitwise and the top 2 elements of the stack
    pop     hl          ;    
    ld      A,E         ;   
    and     L           ;   
    ld      L,A         ;   
    ld      A,D         ;   
    and     H           ;   
and1:
    ld      H,A         ;   
    push    hl          ;    
    jp (IY)        ;   
    
                        ; 
or_: 		 
    pop     de             ; Bitwise or the top 2 elements of the stack
    pop     hl
    ld      A,E
    or      L
    ld      L,A
    ld      A,D
    or      H
    jr and1

xor_:		 
    pop     de              ; Bitwise XOR the top 2 elements of the stack
xor1:
    pop     hl
    ld      A,E
    XOR     L
    ld      L,A
    ld      A,D
    XOR     H
    jr and1

inv_:				; Bitwise INVert the top member of the stack
    ld de, $FFFF            ; by xoring with $FFFF
    jr xor1        

add_:                           ; add the top 2 members of the stack
    pop     de                 
    pop     hl                 
    add     hl,de              
    push    hl                 
    jp carry              
                             
again_: jp again		; close loop

call_:
    ld A,(BC)
    call lookupRef1
    ld E,(hl)
    inc hl
    ld D,(hl)
    jp go1

dot_:       
    pop hl
    call printDec
dot2:
    ld A,' '           
    call putChar
    jp (IY)

hdot_:                          ; print hexadecimal
    pop     hl
    call printhex
    jr   dot2

drop_:                          ; Discard the top member of the stack
    pop     hl
    jp (IY)

dup_:        
    pop     hl              ; Duplicate the top member of the stack
    push    hl
    push    hl
    jp (IY)
fetch_:                         ; Fetch the value from the address placed on the top of the stack      
    pop hl              
fetch1:
    ld E,(hl)         
    inc hl             
    ld D,(hl)         
    push de              
    jp (IY)           

nop_:       
    jp NEXT             ; hardwire white space to always go to NEXT (important for arrays)


over_:  
    pop hl              ; Duplicate 2nd element of the stack
    pop de
    push de
    push hl
    push de              ; and push it to top of stack
    jp (IY)        

ret_:
    call rpop               ; Restore Instruction pointer
    ld BC,hl                
    jp (IY)             

rot_:                               ; a b c -- b c a
    pop de                      ; a b                   de = c
    pop hl                      ; a                     hl = b
    EX (SP),hl                  ; b                     hl = a
    push de                     ; b c             
    push hl                     ; b c a                         
    jp (IY)

;  Left shift { is multiply by 2		
shl_:   
    pop hl                  ; Duplicate the top member of the stack
    add hl,hl
    push hl                 ; shift left fallthrough into add_     
    jp (IY)                 ;   

			;  Right shift } is a divide by 2		
shr_:    
    pop hl                  ; Get the top member of the stack
shr1:
    SRL H
    RR L
    push hl
    jp (IY)                 ;   

store_:                         ; Store the value at the address placed on the top of the stack
    pop hl               
    pop de               
    ld (hl),E          
    inc hl              
    ld (hl),D          
    jp (IY)            
                              
; $ swap                        ; a b -- b a Swap the top 2 elements of the stack
swap_:        
    pop hl
    EX (SP),hl
    push hl
    jp (IY)
    
sub_:       		    ; Subtract the value 2nd on stack from top of stack 
    inc bc              ; check if sign of a number
    ld a,(bc)
    dec bc
    cp "0"
    jr c,sub1
    cp "9"+1
    jp c,num    
sub1:
    pop de              ;    
    pop hl              ;      Entry point for INVert
sub2:   
    and A               ;      Entry point for NEGate
    SBC hl,de           ; 
    push hl             ;    
    jp carry               
                            ; 5  
eq_:    
    pop hl
    pop de
    and A              ; reset the carry flag
    SBC hl,de          ; only equality sets hl=0 here
    jr Z, equal
    ld hl, 0
    jr less           ; hl = 1    

gt_:    
    pop de
    pop hl
    jr cmp_
    
lt_:    
    pop hl
    pop de
    
cmp_:   
    and A              ; reset the carry flag
    SBC hl,de          ; only equality sets hl=0 here
jr Z,less          ; equality returns 0  KB 25/11/21
    ld hl, 0
    jp M,less
equal:  
    inc L              ; hl = 1    
less:     
    push hl
    jp (IY) 
    
var_:
    ld A,(BC)
    call lookupRef2
    push hl
    jp (IY)

str_:                         
str:                                                      
    inc BC
    
str1:            
    ld A, (BC)
    inc BC
    CP "`"                      ; ` is the string terminator
    jr Z,str2
    call putchar
    jr str1
str2:  
    dec BC
    jp   (IY) 

hex_:
    ld hl,0	    		    ; Clear hl to accept the number
hex1:
    inc BC
    ld A,(BC)		    ; Get the character which is a numeral
    BIT 6,A                     ; is it uppercase alpha?
    jp Z, hex2                  ; no a decimal
    SUB 7                       ; sub 7  to make $A - $F
    jp hex2

num_:   jp num
begin_: jp begin
arrDef_:jp arrDef    
arrEnd_:jp arrEnd
def_:   jp def

arrIndex_: jr arrIndex
mul_:   jr mul      
div_:   jr div
alt_:   

;*******************************************************************
; Page 5 primitive routines 
;*******************************************************************
    ;falls through 
alt:                                ;=11
    inc BC
    ld A,(BC)
    ld hl,altCodes
    sub "!"
    add A,L
    ld L,A
alt2:
    ld A,(hl)                   ;       get low jump address
    ld hl,page6
    ld L,A                      
    jp (hl)                     ;       Jump to routine

key_:
    call getchar
    ld H,0
    ld L,A
    push hl
    jp (IY)

arrIndex:
    pop hl                              ; hl = index  
    pop de                              ; de = array
    add hl,hl                           ; if data width = 2 then double 
    add hl,de                           ; add addr
    push hl
    jp (iy)

mul:                                ;=19
    pop  de                     ; get first value
    pop  hl
    push BC                     ; Preserve the IP
    ld B,H                      ; BC = 2nd value
    ld C,L
    
    ld hl,0
    ld A,16
mul2:
    add hl,hl
    RL E
    RL D
    jr NC,$+6
    add hl,BC
    jr NC,$+3
    inc de
    dec A
    jr NZ,mul2
	pop BC			    ; Restore the IP
	push hl                     ; Put the product on the stack - stack bug fixed 2/12/21
	jp (IY)

div:
    ld hl,bc                    ; hl = IP
    pop bc                      ; bc = denominator
    ex (sp),hl                  ; save IP, hl = numerator  
    ld a,h
    xor b
    push af
    xor b
    jp p,absBC
;absHL
    xor a  
    sub l  
    ld l,a
    sbc a,a  
    sub h  
    ld h,a
absBC:
    xor b
    jp p,$+9
    xor a  
    sub c  
    ld c,a
    sbc a,a  
    sub b  
    ld b,a
    add hl,hl
    ld a,15
    ld de,0
    ex de,hl
    jr jumpin
Loop1:
    add hl,bc   ;--
Loop2:
    dec a       ;4
    jr z,EndSDiv ;12|7
jumpin:
    sla e       ;8
    rl d        ;8
    adc hl,hl   ;15
    sbc hl,bc   ;15
    jr c,Loop1  ;23-2b
    inc e       ;--
    jp Loop2    ;--
EndSDiv:
    pop af  
    jp p,div10
    xor a  
    sub e  
    ld e,a
    sbc a,a  
    sub d  
    ld d,a
div10:
    pop bc
    push de                     ; quotient
    push hl                     ; remainder
    jp (iy)

    	                    ;=57                     
begin:                              ; Left parentheses begins a loop
    pop hl
    ld A,L                      ; zero?
    or H
    jr Z,begin1
    push IX
    ld IX,(vLoopSP)
    ld de,-6
    add IX,de
    ld (IX+0),0                 ; loop var
    ld (IX+1),0                 
    ld (IX+2),L                 ; loop limit
    ld (IX+3),H                 
    ld (IX+4),C                 ; loop address
    ld (IX+5),B                 
    ld (vLoopSP),IX
    pop IX
    jp (IY)
begin1:
    ld E,1
begin2:
    inc BC
    ld A,(BC)
    call nesting
    XOR A
    or E
    jr NZ,begin2
    ld hl,1
begin3:
    inc BC
    ld A,(BC)
    dec BC
    CP "("
    jr NZ,begin4
    push hl
begin4:        
    jp (IY)

again:                              ;=72
    push IX
    ld IX,(vLoopSP)
    ld E,(IX+0)                 ; peek loop var
    ld D,(IX+1)                 
    ld L,(IX+2)                 ; peek loop limit
    ld H,(IX+3)                 
    dec hl
    or A
    SBC hl,de
    jr Z,again2
    inc de
    ld (IX+0),E                 ; poke loop var
    ld (IX+1),D                 
again1:
    ld C,(IX+4)                 ; peek loop address
    ld B,(IX+5)                 
    jr again4
again2:   
    ld de,6                     ; drop loop frame
again3:
    add IX,de
again4:
    ld (vLoopSP),IX
    pop IX
    ld hl,0                     ; skip ELSE clause
    jr begin3               

carry:                              ;=10
    ld hl,0
    rl l
    ld (vCarry),hl
    jp (iy)              

; **************************************************************************
; Page 6 Alt primitives
; **************************************************************************
    .align $100
page6:


altVar_:
    ld A,(BC)
    SUB "a" - ((altVars - mintVars)/2) 
    add A,A
    ld H,msb(mintVars)
    ld L,A
    push hl
anop_:
    jp (IY)                    

anonDef_:                           ;= 7        
    inc BC
    ld de,(vHeapPtr)            ; start of defintion
    push de
    jp def1

arrSize_:
arrSize:
    pop hl
    dec hl                      ; msb size 
    ld d,(hl)
    dec hl                      ; lsb size 
    ld e,(hl)
    push de
    jp (iy)

break_:
    pop hl
    ld A,L                      ; zero?
    or H
    jr NZ,break1
    jp (IY)
break1:
    ld de,6                     ; drop loop frame
    add IX,de
    jp begin1                   ; skip to end of loop        

cArrDef_:                           ; define a byte array
    ld A,TRUE
    jp arrDef1

cFetch_:
    pop     hl          
    ld      D,0            
    ld      E,(hl)         
    push    de              
    jp (IY)           

comment_:
    inc BC                      ; point to next char
    ld A,(BC)
    CP "\r"                     ; terminate at cr 
    jr NZ,comment_
    dec BC
    jp   (IY) 

cStore_:	  
    pop    hl               
    pop    de               
    ld     (hl),E          
    jp     (IY)            
                         
depth_:
depth:
    ld hl,0
    add hl,SP
    EX de,hl
    ld hl,DSTACK
    or A
    SBC hl,de
    jp shr1

emit_:
    pop hl
    ld A,L
    call putchar
    jp (IY)

exec_:
    call exec1
    jp (IY)
exec1:
    pop hl
    EX (SP),hl
    jp (hl)

editDef_:
    call editDef
    jp (IY)

prompt_:
    call prompt
    jp (IY)


go_:				    ;\^
    pop de
go1:
    ld A,D                      ; skip if destination address is null
    or E
    jr Z,go3
    ld hl,BC
    inc BC                      ; read next char from source
    ld A,(BC)                   ; if ; to tail call optimise
    CP ";"                      ; by jumping to rather than calling destination
    jr Z,go2
    call rpush                  ; save Instruction Pointer
go2:
    ld BC,de
    dec BC
go3:
    jp (IY)                     

inPort_:			    ; \<
    pop hl
    ld A,C
    ld C,L
    IN L,(C)
    ld H,0
    ld C,A
    push hl
    jp (IY)        

i_:
    ld hl,(vLoopSP)
    push hl
    jp (IY)

j_:                                 ;=9  
    ld hl,(vLoopSP)             ;the address of j is 6 bytes more than i
    ld de,6
    add hl,de
    push hl
    jp (IY)
    
newln_:
    call crlf
    jp (IY)        

outPort_:
    pop hl
    ld E,C
    ld C,L
    pop hl
    OUT (C),L
    ld C,E
    jp (IY)        

printStk_:
printStk:                           ;=40
    ; MINT: \a@2- \- 1- ("@ \b@ \(,)(.) 2-) '             
    call ENTER
    .cstr "`=> `\\a@2- \\- 1-(",$22,"@.2-)'\\N"             
    jp (IY)

;*******************************************************************
; Page 5 primitive routines continued
;*******************************************************************

; ********************************************************************************
; Number Handling Routine - converts numeric ascii string to a 16-bit number in hl
; Read the first character. 
;			
; Number characters ($30 to $39) are converted to digits by subtracting $30
; and then added into the L register. (hl forms a 16-bit accumulator)
; Fetch the next character, if it is a number, multiply contents of hl by 10
; and then add in the next digit. Repeat this until a non-number character is 
; detected. add in the final digit so that hl contains the converted number.
; push hl onto the stack and proceed to the dispatch routine.
; ********************************************************************************
     
num:
	ld hl,$0000				    ; Clear hl to accept the number
	ld a,(bc)				    ; Get numeral or -
    cp '-'
    jr nz,num0
    inc bc                      ; move to next char, no flags affected
num0:
    ex af,af'                   ; save zero flag = 0 for later
num1:
    ld a,(bc)                   ; read digit    
    sub "0"                     ; less than 0?
    jr c, num2                  ; not a digit, exit loop 
    cp 10                       ; greater that 9?
    jr nc, num2                 ; not a digit, exit loop
    inc bc                      ; inc IP
    ld de,hl                    ; multiply hl * 10
    add hl,hl    
    add hl,hl    
    add hl,de    
    add hl,hl    
    add a,l                     ; add digit in a to hl
    ld l,a
    ld a,0
    adc a,h
    ld h,a
    jr num1 
num2:
    dec bc
    ex af,af'                   ; restore zero flag
    jr nz, num3
    ex de,hl                    ; negate the value of hl
    ld hl,0
    or a                        ; jump to sub2
    sbc hl,de    
num3:
    push hl                     ; Put the number on the stack
    jp (iy)                     ; and process the next character

;*******************************************************************
; Subroutines
;*******************************************************************

editDef:                            ;=50 lookup up def based on number
    pop hl                      ; pop ret address
    EX (SP),hl                  ; swap with TOS                  
    ld A,L
    EX AF,AF'
    ld A,L
    call lookupRef
    ld E,(hl)
    inc hl
    ld D,(hl)
    ld A,D
    or E
    ld hl,TIB
    jr Z,editDef3
    ld A,":"
    call writeChar
    EX AF,AF'
    call writeChar
    jr editDef2
editDef1:
    inc de
editDef2:        
    ld A,(de)
    call writeChar
    CP ";"
    jr NZ,editDef1
editDef3:        
    ld de,TIB
    or A
    SBC hl,de
    ld (vTIBPtr),hl
    RET

; **************************************************************************             
; def is used to create a colon definition
; When a colon is detected, the next character (usually uppercase alpha)
; is looked up in the vector table to get its associated code field address
; This CFA is updated to point to the character after uppercase alpha
; The remainder of the characters are then skipped until after a semicolon  
; is found.
; ***************************************************************************

def:                                ; Create a colon definition
    inc BC
    ld  A,(BC)                  ; Get the next character
    ld (vLastDef),A
    call lookupRef
    ld de,(vHeapPtr)            ; start of defintion
    ld (hl),E                   ; Save low byte of address in CFA
    inc hl              
    ld (hl),D                   ; Save high byte of address in CFA+1
    inc BC
def1:                               ; Skip to end of definition   
    ld A,(BC)                   ; Get the next character
    inc BC                      ; Point to next character
    ld (de),A
    inc de
    CP ";"                      ; Is it a semicolon 
    jr Z, def2                  ; end the definition
    jr  def1                    ; get the next element
def2:    
    dec BC
def3:
    ld (vHeapPtr),de            ; bump heap ptr to after definiton
    jp (IY)       

; hl = value
printDec:    
    bit 7,h
    jr z,printDec2
    ld a,'-'
    call putchar
    xor a  
    sub l  
    ld l,a
    sbc a,a  
    sub h  
    ld h,a
printDec2:        
    push bc
    ld c,0                      ; leading zeros flag = false
    ld de,-10000
    call printDec4
    ld de,-1000
    call printDec4
    ld de,-100
    call printDec4
    ld e,-10
    call printDec4
    inc c                       ; flag = true for at least digit
    ld e,-1
    call printDec4
    pop bc
    ret
printDec4:
    ld b,'0'-1
printDec5:	    
    inc b
    add hl,de
    jr c,printDec5
    sbc hl,de
    ld a,'0'
    cp b
    jr nz,printDec6
    xor a
    or c
    ret z
    jr printDec7
printDec6:	    
    inc c
printDec7:	    
    ld a,b
    jp putchar

arrDef:                         
    ld A,FALSE
arrDef1:      
    ld (vByteMode),A
    ld hl,0
    add hl,sp                   ; save 
    call rpush
    jp (iy)

arrEnd:                       
    ld (vTemp1),bc              ; save IP
    call rpop
    ld (vTemp2),hl              ; save old SP
    ld de,hl                    ; de = hl = old SP
    or a 
    sbc hl,sp                   ; hl = array count (items on stack)
    srl h                       ; num items = num bytes / 2
    rr l                        
    ld bc,hl                    ; bc = count
    ld hl,(vHeapPtr)            ; hl = array[-4]
    ld (hl),c                   ; write num items in length word
    inc hl
    ld (hl),b
    inc hl                      ; hl = array[0], bc = count
                                ; de = old SP, hl = array[0], bc = count
    jr arrayEnd2
arrayEnd1:                        
    dec bc                      ; dec items count
    dec de
    dec de
    ld a,(de)                   ; a = lsb of stack item
    ld (hl),a                   ; write lsb of array item
    inc hl                      ; move to msb of array item
    ld a,(vByteMode)            ; vByteMode=1? 
    dec a
    jr z,arrayEnd2
    inc de
    ld a,(de)                   ; a = msb of stack item
    dec de
    ld (hl),a                   ; write msb of array item
    inc hl                      ; move to next word in array
arrayEnd2:
    ld a,c                      ; if not zero loop
    or b
    jr nz,arrayEnd1
    ex de,hl                    ; de = end of array 
    ld hl,(vTemp2)
    ld sp,hl                    ; SP = old SP
    ld hl,(vHeapPtr)            ; de = array[-2]
    inc hl
    inc hl
    push hl                     ; return array[0]
    ld (vHeapPtr),de            ; move heap* to end of array
    ld bc,(vTemp1)              ; restore IP
    jp (iy)

; hex continued
hex2:
    SUB $30                     ; Form decimal digit
    jp C,num2
    CP $0F+1
    jp NC,num2
    add hl,hl                   ; 2X ; Multiply digit(s) in hl by 16
    add hl,hl                   ; 4X
    add hl,hl                   ; 8X
    add hl,hl                   ; 16X     
    add A,L                     ; add into bottom of hl
    ld  L,A                     ;   
    jp  hex1



