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
    DB len
.endm

.macro REPDAT,len,data			; compress the command tables
    
    DB (len | $80)
    DB data
.endm

.macro ENDDAT
    DB 0
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
    DB "\\e\\@\\L;"			; remembers last line edited

edit_:
    .cstr "`?`?\\P\\L;"

list_:
    .cstr "\\N26(\\i@65+\\L\\t@0>(\\N))\\P;"

printStack_:
    .cstr "\\T\\P;"        

iOpcodes:
    LITDAT 15
    DB    lsb(store_)   ;   !            
    DB    lsb(dup_)     ;   "
    DB    lsb(hex_)     ;    #
    DB    lsb(swap_)    ;    $            
    DB    lsb(over_)    ;    %            
    DB    lsb(and_)     ;    &
    DB    lsb(drop_)    ;    '
    DB    lsb(begin_)   ;    (        
    DB    lsb(again_)   ;    )
    DB    lsb(mul_)     ;    *            
    DB    lsb(add_)     ;    +
    DB    lsb(hdot_)    ;    ,            
    DB    lsb(sub_)     ;    -
    DB    lsb(dot_)     ;    .
    DB    lsb(div_)     ;    /	;/MOD

    REPDAT 10, lsb(num_)		; 10 x repeat lsb of add to the num routine 

    LITDAT 7
    DB    lsb(def_)    ;    :        
    DB    lsb(ret_)    ;    ;
    DB    lsb(lt_)     ;    <
    DB    lsb(eq_)     ;    =            
    DB    lsb(gt_)     ;    >            
    DB    lsb(key_)    ;    ?   ( -- val )  read a char from input
    DB    lsb(fetch_)  ;    @    

    REPDAT 26, lsb(call_)		; call a command A, B ....Z

    LITDAT 6
    DB    lsb(arrDef_) ;    [
    DB    lsb(alt_)    ;    \
    DB    lsb(arrEnd_) ;    ]
    DB    lsb(xor_)    ;    ^
    DB    lsb(arrIndex_)    ;    _   
    DB    lsb(str_)    ;    `   ; for printing `hello`        

    REPDAT 26, lsb(var_)		; a b c .....z

    LITDAT 5
    DB    lsb(shl_)    ;    {
    DB    lsb(or_)     ;    |            
    DB    lsb(shr_)    ;    }            
    DB    lsb(rot_)    ;    ~ ( a b c -- b c a ) rotate            

iAltCodes:

    LITDAT 4
    DB     lsb(cstore_)     ;!  byte store     
    DB     lsb(aNop_)       ;"  				
    DB     lsb(aNop_)       ;#  edit definition 				
    DB     lsb(newln_)      ;$  prints a newline to output	

    REPDAT 7, lsb(aNop_)
                            ; %
                            ; &
                            ; '
                            ; (
                            ; )
                            ; *
                            ; +

    LITDAT 2
    DB     lsb(emit_)       ;,  ( b -- ) prints a char              
    DB     lsb(depth_)      ;-  num items on stack

    REPDAT 2, lsb(aNop_)
                            ;.              
                            ;/                

    REPDAT 10, lsb(aNop_)
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
    DB     lsb(anonDef_)    ;:  return add of a anon def, \: 1 2 3;    \\ ret add of this                

    REPDAT 5, lsb(aNop_)
                            ;;                
                            ;<  
                            ;=    
                            ;>  
                            ;?  

    LITDAT 21
    DB     lsb(cFetch_)     ;@      byte fetch
    DB     lsb(aNop_)       ;A
    DB     lsb(break_)      ;B      conditional break from loop
    DB     lsb(aNop_)       ;C
    DB     lsb(depth_)      ;D      num items on stack
    DB     lsb(emit_)       ;E      emit a char
    DB     lsb(aNop_)       ;F
    DB     lsb(go_)         ;G      execute mint code
    DB     lsb(aNop_)       ;H
    DB     lsb(inPort_)     ;I      input from port
    DB     lsb(aNop_)       ;J
    DB     lsb(aNop_)       ;K
    DB     lsb(editDef_)    ;L      edit line
    DB     lsb(aNop_)       ;M
    DB     lsb(newln_)      ;N      prints a newline to output
    DB     lsb(outPort_)    ;O      output to port
    DB     lsb(prompt_)     ;P      print MINT prompt
    DB     lsb(aNop_)       ;Q
    DB     lsb(aNop_)       ;R
    DB     lsb(arrSize_)    ;S      array size
    DB     lsb(printStk_)   ;T      non-destructively prints stack
    
    REPDAT 3, lsb(aNop_)
                            ;U
                            ;V
                            ;W      
    
    LITDAT 1
    DB     lsb(exec_)       ;X      execute machine code 
    
    REPDAT 2, lsb(aNop_)
                            ;Y
                            ;Z

    LITDAT 2
    DB     lsb(cArrDef_)    ;[      byte array
    DB     lsb(comment_)    ;\      comment text, skips reading until end of line

    REPDAT 4, lsb(aNop_)
                            ; ]
                            ; ^
                            ; _
                            ; `

    REPDAT 8, lsb(altVar_)  ;a...h

    LITDAT 2
    DB     lsb(i_)          ;i  returns index variable of current loop          
    DB     lsb(j_)          ;j  returns index variable of outer loop     \i+6     

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
    LD SP,DSTACK		; start of MINT
    CALL init		    ; setups
    CALL printStr		; prog count to stack, put code line 235 on stack then call print
    .cstr "MINT1.3\r\n"

interpret:
    call prompt

    LD BC,0                 ; load BC with offset into TIB, decide char into tib or execute or control         
    LD (vTIBPtr),BC

interpret2:                     ; calc nesting (a macro might have changed it)
    LD E,0                  ; initilize nesting value
    PUSH BC                 ; save offset into TIB, 
                            ; BC is also the count of chars in TIB
    LD HL,TIB               ; HL is start of TIB
    JR interpret4

interpret3:
    LD A,(HL)               ; A = char in TIB
    INC HL                  ; inc pointer into TIB
    DEC BC                  ; dec count of chars in TIB
    call nesting            ; update nesting value

interpret4:
    LD A,C                  ; is count zero?
    OR B
    JR NZ, interpret3       ; if not loop
    POP BC                  ; restore offset into TIB
; *******************************************************************         
; Wait for a character from the serial input (keyboard) 
; and store it in the text buffer. Keep accepting characters,
; increasing the instruction pointer BC - until a newline received.
; *******************************************************************

waitchar:   
    CALL getchar            ; loop around waiting for character from serial port
    CP $20			; compare to space
    JR NC,waitchar1		; if >= space, if below 20 set cary flag
    CP $0                   ; is it end of string? null end of string
    JR Z,waitchar4
    CP '\r'                 ; carriage return? ascii 13
    JR Z,waitchar3		; if anything else its macro/control 
    cp CTRL_H
    jr z,backSpace
    LD d,msb(macros)
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
    LD (vTIBPtr),BC
    PUSH DE
    call ENTER		;mint go operation and jump to it
    .cstr "\\G"
    LD BC,(vTIBPtr)
    JR interpret2

waitchar1:
    LD HL,TIB
    ADD HL,BC
    LD (HL),A               ; store the character in textbuf
    INC BC
    CALL putchar            ; echo character to screen
    CALL nesting
    JR  waitchar            ; wait for next character

waitchar3:
    LD HL,TIB
    ADD HL,BC
    LD (HL),"\r"            ; store the crlf in textbuf
    INC HL
    LD (HL),"\n"            
    INC HL                  ; ????
    INC BC
    INC BC
    CALL crlf               ; echo character to screen
    LD A,E                  ; if zero nesting append and ETX after \r
    OR A
    JR NZ,waitchar
    LD (HL),$03             ; store end of text ETX in text buffer 
    INC BC

waitchar4:    
    LD (vTIBPtr),BC
    LD BC,TIB               ; Instructions stored on heap at address HERE, we pressed enter
    DEC BC

; ********************************************************************************
;
; Dispatch Routine.
;
; Get the next character and form a 1 byte jump address
;
; This target jump address is loaded into HL, and using JP (HL) to quickly 
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
    INC BC                      ;       Increment the IP
    LD A, (BC)                  ;       Get the next character and dispatch
    or a                        ; is it NUL?       
    jr z,exit
    cp CTRL_C
    jr z,etx
    sub "!"
    LD L,A                      ;       Index into table
    LD H,msb(opcodes)           ;       Start address of jump table         
    LD L,(HL)                   ;       get low jump address
    LD H,msb(page4)             ;       Load H with the 1st page address
    JP (HL)                     ;       Jump to routine

exit:
    INC BC			; store offests into a table of bytes, smaller
    LD DE,BC                
    CALL rpop               ; Restore Instruction pointer
    LD BC,HL
    EX DE,HL
    JP (HL)

etx:                                ;=12
    LD HL,-DSTACK               ; check if stack pointer is underwater
    ADD HL,SP
    JR NC,etx1
    LD SP,DSTACK
etx1:
    JP interpret

init:                           ;=68
    LD HL,LSTACK
    LD (vLoopSP),HL         ; Loop stack pointer stored in memory
    LD IX,RSTACK
    LD IY,NEXT		; IY provides a faster jump to NEXT

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

    LD HL,VARS              ; init namespaces to 0 using LDIR
    LD DE,HL
    INC DE
    LD (HL),0
    LD BC,VARS_SIZE
    LDIR

initOps:
    LD HL, iOpcodes
    LD DE, opcodes
    LD BC, 256

initOps1:
    LD A,(HL)
    INC HL
    SLA A                     
    RET Z
    JR C, initOps2
    SRL A
    LD C,A
    LD B,0
    LDIR
    JR initOps1
    
initOps2:        
    SRL A
    LD B,A
    LD A,(HL)
    INC HL
initOps2a:
    LD (DE),A
    INC DE
    DJNZ initOps2a
    JR initOps1

lookupRef:
    LD D,0
lookupRef0:
    CP "a"
    JR NC,lookupRef2
lookupRef1:
    SUB "A"
    LD E,0
    JR lookupRef3        
lookupRef2:
    SUB "a"
    LD E,26*2
lookupRef3:
    ADD A,A
    ADD A,E
    LD HL,VARS
    ADD A,L
    LD L,A
    LD A,0
    ADC A,H
    LD H,A
    XOR A
    OR E                        ; sets Z flag if A-Z
    RET

printhex:                           ;=31  
                                ; Display HL as a 16-bit number in hex.
    PUSH BC                     ; preserve the IP
    LD A,H
    CALL printhex2
    LD A,L
    CALL printhex2
    POP BC
    RET
printhex2:		                    
    LD	C,A
	RRA 
	RRA 
	RRA 
	RRA 
    CALL printhex3
    LD A,C
printhex3:		
    AND	0x0F
	ADD	A,0x90
	DAA
	ADC	A,0x40
	DAA
	JP putchar

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
    JR NZ,nesting1
    BIT 7,E
    JR Z,nesting1a
    RES 7,E
    RET
nesting1a: 
    SET 7,E
    RET
nesting1:
    BIT 7,E             
    RET NZ             
    CP ':'
    JR Z,nesting2
    CP '['
    JR Z,nesting2
    CP '('
    JR NZ,nesting3
nesting2:
    INC E
    RET
nesting3:
    CP ';'
    JR Z,nesting4
    CP ']'
    JR Z,nesting4
    CP ')'
    RET NZ
nesting4:
    DEC E
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
    EX (SP),HL		                ; swap			
    CALL putStr		
    INC HL			                ; inc past null
    EX (SP),HL		                ; put it back	
    RET

putStr0:                            ;=9
    CALL putchar
    INC HL
putStr:
    LD A,(HL)
    OR A
    JR NZ,putStr0
    RET

rpush:                              ;=11
    DEC IX                  
    LD (IX+0),H
    DEC IX
    LD (IX+0),L
    RET

rpop:                               ;=11
    LD L,(IX+0)         
    INC IX              
    LD H,(IX+0)
    INC IX                  
rpop2:
    RET

; **********************************************************************			 
; Page 4 primitive routines 
; **********************************************************************
    .align $100
page4:

and_:        
    POP     DE          ;     Bitwise AND the top 2 elements of the stack
    POP     HL          ;    
    LD      A,E         ;   
    AND     L           ;   
    LD      L,A         ;   
    LD      A,D         ;   
    AND     H           ;   
and1:
    LD      H,A         ;   
    PUSH    HL          ;    
    JP (IY)        ;   
    
                        ; 
or_: 		 
    POP     DE             ; Bitwise OR the top 2 elements of the stack
    POP     HL
    LD      A,E
    OR      L
    LD      L,A
    LD      A,D
    OR      H
    JR and1

xor_:		 
    POP     DE              ; Bitwise XOR the top 2 elements of the stack
xor1:
    POP     HL
    LD      A,E
    XOR     L
    LD      L,A
    LD      A,D
    XOR     H
    JR and1

inv_:				; Bitwise INVert the top member of the stack
    LD DE, $FFFF            ; by xoring with $FFFF
    JR xor1        

add_:                           ; Add the top 2 members of the stack
    POP     DE                 
    POP     HL                 
    ADD     HL,DE              
    PUSH    HL                 
    JP carry              
                             
again_: JP again		; close loop

call_:
    LD A,(BC)
    CALL lookupRef1
    LD E,(HL)
    INC HL
    LD D,(HL)
    JP go1

dot_:       
    POP HL
    CALL printDec
dot2:
    LD A,' '           
    CALL putChar
    JP (IY)

hdot_:                          ; print hexadecimal
    POP     HL
    CALL printhex
    JR   dot2

drop_:                          ; Discard the top member of the stack
    POP     HL
    JP (IY)

dup_:        
    POP     HL              ; Duplicate the top member of the stack
    PUSH    HL
    PUSH    HL
    JP (IY)
fetch_:                         ; Fetch the value from the address placed on the top of the stack      
    POP HL              
fetch1:
    LD E,(HL)         
    INC HL             
    LD D,(HL)         
    PUSH DE              
    JP (IY)           

hex_:   JP hex

key_:
    CALL getchar
    LD H,0
    LD L,A
    PUSH HL
    JP (IY)

nop_:       
    JP NEXT             ; hardwire white space to always go to NEXT (important for arrays)


over_:  
    POP HL              ; Duplicate 2nd element of the stack
    POP DE
    PUSH DE
    PUSH HL
    PUSH DE              ; And push it to top of stack
    JP (IY)        

ret_:
    CALL rpop               ; Restore Instruction pointer
    LD BC,HL                
    JP (IY)             

rot_:                               ; a b c -- b c a
    POP DE                      ; a b                   de = c
    POP HL                      ; a                     hl = b
    EX (SP),HL                  ; b                     hl = a
    PUSH DE                     ; b c             
    PUSH HL                     ; b c a                         
    JP (IY)

;  Left shift { is multiply by 2		
shl_:   
    POP HL                  ; Duplicate the top member of the stack
    ADD HL,HL
    PUSH HL                 ; shift left fallthrough into add_     
    JP (IY)                 ;   

			;  Right shift } is a divide by 2		
shr_:    
    POP HL                  ; Get the top member of the stack
shr1:
    SRL H
    RR L
    PUSH HL
    JP (IY)                 ;   

store_:                         ; Store the value at the address placed on the top of the stack
    POP HL               
    POP DE               
    LD (HL),E          
    INC HL              
    LD (HL),D          
    JP (IY)            
                              
; $ swap                        ; a b -- b a Swap the top 2 elements of the stack
swap_:        
    POP HL
    EX (SP),HL
    PUSH HL
    JP (IY)
    
sub_:       		    ; Subtract the value 2nd on stack from top of stack 
    inc bc              ; check if sign of a number
    ld a,(bc)
    dec bc
    cp "0"
    jr c,sub1
    cp "9"+1
    jp c,num    
sub1:
    POP DE              ;    
    POP HL              ;      Entry point for INVert
sub2:   
    AND A               ;      Entry point for NEGate
    SBC HL,DE           ; 
    PUSH HL             ;    
    JP carry               
                            ; 5  
eq_:    
    POP HL
    POP DE
    AND A              ; reset the carry flag
    SBC HL,DE          ; only equality sets HL=0 here
    JR Z, equal
    LD HL, 0
    JR less           ; HL = 1    

gt_:    
    POP DE
    POP HL
    JR cmp_
    
lt_:    
    POP HL
    POP DE
    
cmp_:   
    AND A              ; reset the carry flag
    SBC HL,DE          ; only equality sets HL=0 here
JR Z,less          ; equality returns 0  KB 25/11/21
    LD HL, 0
    JP M,less
equal:  
    INC L              ; HL = 1    
less:     
    PUSH HL
    JP (IY) 
    
var_:
    LD A,(BC)
    CALL lookupRef2
    PUSH HL
    JP (IY)

str_:                         
str:                                                      
    INC BC
    
str1:            
    LD A, (BC)
    INC BC
    CP "`"                      ; ` is the string terminator
    JR Z,str2
    CALL putchar
    JR str1
str2:  
    DEC BC
    JP   (IY) 

num_:   JP num
begin_: JP begin
arrDef_:JP arrDef    
arrEnd_:JP arrEnd
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
    INC BC
    LD A,(BC)
    LD HL,altCodes
    sub "!"
    ADD A,L
    LD L,A
alt2:
    LD A,(HL)                   ;       get low jump address
    LD HL,page6
    LD L,A                      
    JP (HL)                     ;       Jump to routine

arrIndex:
    pop hl                              ; hl = index  
    pop de                              ; de = array
    add hl,hl                           ; if data width = 2 then double 
    add hl,de                           ; add addr
    push hl
    jp (iy)

mul:                                ;=19
    POP  DE                     ; get first value
    POP  HL
    PUSH BC                     ; Preserve the IP
    LD B,H                      ; BC = 2nd value
    LD C,L
    
    LD HL,0
    LD A,16
mul2:
    ADD HL,HL
    RL E
    RL D
    JR NC,$+6
    ADD HL,BC
    JR NC,$+3
    INC DE
    DEC A
    JR NZ,mul2
	POP BC			    ; Restore the IP
	PUSH HL                     ; Put the product on the stack - stack bug fixed 2/12/21
	JP (IY)

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
    POP HL
    LD A,L                      ; zero?
    OR H
    JR Z,begin1
    PUSH IX
    LD IX,(vLoopSP)
    LD DE,-6
    ADD IX,DE
    LD (IX+0),0                 ; loop var
    LD (IX+1),0                 
    LD (IX+2),L                 ; loop limit
    LD (IX+3),H                 
    LD (IX+4),C                 ; loop address
    LD (IX+5),B                 
    LD (vLoopSP),IX
    POP IX
    JP (IY)
begin1:
    LD E,1
begin2:
    INC BC
    LD A,(BC)
    CALL nesting
    XOR A
    OR E
    JR NZ,begin2
    LD HL,1
begin3:
    INC BC
    LD A,(BC)
    DEC BC
    CP "("
    JR NZ,begin4
    PUSH HL
begin4:        
    JP (IY)

again:                              ;=72
    PUSH IX
    LD IX,(vLoopSP)
    LD E,(IX+0)                 ; peek loop var
    LD D,(IX+1)                 
    LD L,(IX+2)                 ; peek loop limit
    LD H,(IX+3)                 
    DEC HL
    OR A
    SBC HL,DE
    JR Z,again2
    INC DE
    LD (IX+0),E                 ; poke loop var
    LD (IX+1),D                 
again1:
    LD C,(IX+4)                 ; peek loop address
    LD B,(IX+5)                 
    JR again4
again2:   
    LD DE,6                     ; drop loop frame
again3:
    ADD IX,DE
again4:
    LD (vLoopSP),IX
    POP IX
    LD HL,0                     ; skip ELSE clause
    JR begin3               

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
    LD A,(BC)
    SUB "a" - ((altVars - mintVars)/2) 
    ADD A,A
    LD H,msb(mintVars)
    LD L,A
    PUSH HL
anop_:
    JP (IY)                    

anonDef_:                           ;= 7        
    INC BC
    LD DE,(vHeapPtr)            ; start of defintion
    PUSH DE
    JP def1

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
    POP HL
    LD A,L                      ; zero?
    OR H
    JR NZ,break1
    JP (IY)
break1:
    LD DE,6                     ; drop loop frame
    ADD IX,DE
    JP begin1                   ; skip to end of loop        

cArrDef_:                           ; define a byte array
    LD A,TRUE
    JP arrDef1

cFetch_:
    POP     HL          
    LD      D,0            
    LD      E,(HL)         
    PUSH    DE              
    JP (IY)           

comment_:
    INC BC                      ; point to next char
    LD A,(BC)
    CP "\r"                     ; terminate at cr 
    JR NZ,comment_
    DEC BC
    JP   (IY) 

cStore_:	  
    POP    HL               
    POP    DE               
    LD     (HL),E          
    JP     (IY)            
                         
depth_:
depth:
    LD HL,0
    ADD HL,SP
    EX DE,HL
    LD HL,DSTACK
    OR A
    SBC HL,DE
    JP shr1

emit_:
    POP HL
    LD A,L
    CALL putchar
    JP (IY)

exec_:
    CALL exec1
    JP (IY)
exec1:
    POP HL
    EX (SP),HL
    JP (HL)

editDef_:
    call editDef
    JP (IY)

prompt_:
    CALL prompt
    JP (IY)


go_:				    ;\^
    POP DE
go1:
    LD A,D                      ; skip if destination address is null
    OR E
    JR Z,go3
    LD HL,BC
    INC BC                      ; read next char from source
    LD A,(BC)                   ; if ; to tail call optimise
    CP ";"                      ; by jumping to rather than calling destination
    JR Z,go2
    CALL rpush                  ; save Instruction Pointer
go2:
    LD BC,DE
    DEC BC
go3:
    JP (IY)                     

inPort_:			    ; \<
    POP HL
    LD A,C
    LD C,L
    IN L,(C)
    LD H,0
    LD C,A
    PUSH HL
    JP (IY)        

i_:
    LD HL,(vLoopSP)
    PUSH HL
    JP (IY)

j_:                                 ;=9  
    LD HL,(vLoopSP)             ;the address of j is 6 bytes more than i
    LD DE,6
    ADD HL,DE
    PUSH HL
    JP (IY)
    
newln_:
    call crlf
    JP (IY)        

outPort_:
    POP HL
    LD E,C
    LD C,L
    POP HL
    OUT (C),L
    LD C,E
    JP (IY)        

printStk_:
printStk:                           ;=40
    ; MINT: \a@2- \- 1- ("@ \b@ \(,)(.) 2-) '             
    call ENTER
    .cstr "`=> `\\a@2- \\- 1-(",$22,"@.2-)'\\N"             
    JP (IY)

;*******************************************************************
; Page 5 primitive routines continued
;*******************************************************************

; ********************************************************************************
; Number Handling Routine - converts numeric ascii string to a 16-bit number in HL
; Read the first character. 
;			
; Number characters ($30 to $39) are converted to digits by subtracting $30
; and then added into the L register. (HL forms a 16-bit accumulator)
; Fetch the next character, if it is a number, multiply contents of HL by 10
; and then add in the next digit. Repeat this until a non-number character is 
; detected. Add in the final digit so that HL contains the converted number.
; Push HL onto the stack and proceed to the dispatch routine.
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

hex:                                ;=26
    LD HL,0	    		    ; Clear HL to accept the number
hex1:
    INC BC
    LD A,(BC)		    ; Get the character which is a numeral
    BIT 6,A                     ; is it uppercase alpha?
    JR Z, hex2                  ; no a decimal
    SUB 7                       ; sub 7  to make $A - $F
hex2:
    SUB $30                     ; Form decimal digit
    JP C,num2
    CP $0F+1
    JP NC,num2
    ADD HL,HL                   ; 2X ; Multiply digit(s) in HL by 16
    ADD HL,HL                   ; 4X
    ADD HL,HL                   ; 8X
    ADD HL,HL                   ; 16X     
    ADD A,L                     ; Add into bottom of HL
    LD  L,A                     ;   
    JR  hex1

;*******************************************************************
; Subroutines
;*******************************************************************

editDef:                            ;=50 lookup up def based on number
    POP HL                      ; pop ret address
    EX (SP),HL                  ; swap with TOS                  
    LD A,L
    EX AF,AF'
    LD A,L
    CALL lookupRef
    LD E,(HL)
    INC HL
    LD D,(HL)
    LD A,D
    OR E
    LD HL,TIB
    JR Z,editDef3
    LD A,":"
    CALL writeChar
    EX AF,AF'
    CALL writeChar
    JR editDef2
editDef1:
    INC DE
editDef2:        
    LD A,(DE)
    CALL writeChar
    CP ";"
    JR NZ,editDef1
editDef3:        
    LD DE,TIB
    OR A
    SBC HL,DE
    LD (vTIBPtr),HL
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
    INC BC
    LD  A,(BC)                  ; Get the next character
    LD (vLastDef),A
    CALL lookupRef
    LD DE,(vHeapPtr)            ; start of defintion
    LD (HL),E                   ; Save low byte of address in CFA
    INC HL              
    LD (HL),D                   ; Save high byte of address in CFA+1
    INC BC
def1:                               ; Skip to end of definition   
    LD A,(BC)                   ; Get the next character
    INC BC                      ; Point to next character
    LD (DE),A
    INC DE
    CP ";"                      ; Is it a semicolon 
    JR Z, def2                  ; end the definition
    JR  def1                    ; get the next element
def2:    
    DEC BC
def3:
    LD (vHeapPtr),DE            ; bump heap ptr to after definiton
    JP (IY)       

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

; ARRAY compilation routine
; compNEXT:                           ;=26
;     POP DE          	        ; DE = return address
;     LD HL,(vHeapPtr)  	        ; load heap ptr
;     LD (HL),E       	        ; store lsb
;     LD A,(vByteMode)
;     INC HL          
;     OR A
;     JR NZ,compNext1
;     LD (HL),D
;     INC HL
; compNEXT1:
;     LD (vHeapPtr),HL            ; save heap ptr
;     jp NEXT

; arrDef:                         ;=18
;     LD A,FALSE
; arrDef1:      
;     LD IY,compNEXT
;     LD (vByteMode),A
;     LD HL,(vHeapPtr)        ; HL = heap ptr
;     CALL rpush              ; save start of array \[  \]
;     JP NEXT                 ; hardwired to NEXT

; arrEnd:                             ;=27
;     CALL rpop                   ; DE = start of array
;     PUSH HL
;     EX DE,HL
;     LD HL,(vHeapPtr)            ; HL = heap ptr
;     OR A
;     SBC HL,DE                   ; bytes on heap 
;     LD A,(vByteMode)
;     OR A
;     JR NZ,arrEnd2
;     SRL H                       ; BC = m words
;     RR L
; arrEnd2:
;     PUSH HL 
;     LD IY,NEXT
;     JP (IY)                     ; hardwired to NEXT


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
    ld a,(de)                   ; a = lsb of stack item
    dec de
    ld (hl),a                   ; write lsb of array item
    inc hl                      ; move to msb of array item
    ld a,(vByteMode)            ; vByteMode=1? 
    dec a
    jr z,arrayEnd2
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

writeChar:                          ;=5
    LD (HL),A
    INC HL
    JP putchar

enter:                              ;=9
    LD HL,BC
    CALL rpush                      ; save Instruction Pointer
    POP BC
    DEC BC
    JP (IY)                    



