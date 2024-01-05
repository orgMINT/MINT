; *************************************************************************
;
;       MINT 2.0 Minimal Interpreter for the Z80 
;
;       John Hardy and Ken Boak
;       incorporates bit-bang serial routines by Craig Jones 
;
;       GNU GENERAL PUBLIC LICENSE                   Version 3, 29 June 2007
;
;       see the LICENSE file in this repo for more information 
;
; *****************************************************************************
    TRUE        EQU -1		
    FALSE       EQU 0
    UNLIMITED   EQU -1		

    CTRL_C      equ 3
    CTRL_E      equ 5
    CTRL_H      equ 8
    CTRL_L      equ 12
    CTRL_R      equ 18
    CTRL_S      equ 19

    BSLASH      equ $5c

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
    db "/z/L;"			; remembers last line edited

edit_:
    .cstr "`?`/K/P/L;"

list_:
    .cstr "/N26(/i65+/L/k0>(/N))/P;"

printStack_:
    .cstr "`=> `/s2- /D1-(",$22,",2-)'/N/P;"        

iOpcodes:
    LITDAT 15
    db    lsb(bang_)        ;   !            
    db    lsb(dquote_)      ;   "
    db    lsb(hash_)        ;   #
    db    lsb(dollar_)      ;   $            
    db    lsb(percent_)     ;   %            
    db    lsb(amper_)       ;   &
    db    lsb(quote_)       ;   '
    db    lsb(lparen_)      ;   (        
    db    lsb(rparen_)      ;   )
    db    lsb(star_)        ;   *            
    db    lsb(plus_)        ;   +
    db    lsb(comma_)       ;   ,            
    db    lsb(minus_)       ;   -
    db    lsb(dot_)         ;   .
    db    lsb(slash_)       ;   /	

    REPDAT 10, lsb(num_)	; 10 x repeat lsb of add to the num routine 

    LITDAT 7
    db    lsb(colon_)       ;    :        
    db    lsb(semi_)        ;    ;
    db    lsb(lt_)          ;    <
    db    lsb(eq_)          ;    =            
    db    lsb(gt_)          ;    >            
    db    lsb(question_)    ;    ?   
    db    lsb(at_)          ;    @    

    REPDAT 26, lsb(call_)	; call a command a, B ....Z

    LITDAT 6
    db    lsb(lbrack_)      ;    [
    db    lsb(bslash_)      ;    \
    db    lsb(rbrack_)      ;    ]
    db    lsb(caret_)       ;    ^
    db    lsb(underscore_)  ;    _   
    db    lsb(grave_)       ;    `   ; for printing `hello`        

    REPDAT 26, lsb(var_)	; a b c .....z

    LITDAT 4
    db    lsb(lbrace_)      ;    {
    db    lsb(pipe_)        ;    |            
    db    lsb(rbrace_)      ;    }            
    db    lsb(tilde_)       ;    ~ ( a b c -- b c a ) rotate            

iAltCodes:

    LITDAT 26
    db     lsb(alloc_)      ;A      allocate some heap memory
    db     lsb(bmode_)      ;B      toggle byte mode  
    db     lsb(printChar_)  ;C      print a char
    db     lsb(depth_)      ;D      depth of stack
    db     lsb(aNop_)       ;E      else condition
    db     lsb(false_)      ;F      false condition
    db     lsb(go_)         ;G      go execute mint code
    db     lsb(aNop_)       ;H
    db     lsb(inPort_)     ;I      input from port
    db     lsb(aNop_)       ;J
    db     lsb(key_)        ;K      read a char from input
    db     lsb(editDef_)    ;L      edit line
    db     lsb(aNop_)       ;M
    db     lsb(newln_)      ;N      prints a newline to output
    db     lsb(outPort_)    ;O      output to port
    db     lsb(prompt_)     ;P      print MINT prompt
    db     lsb(aNop_)       ;Q
    db     lsb(aNop_)       ;R
    db     lsb(arrSize_)    ;S      array size
    db     lsb(aNop_)       ;T      true condition
    db     lsb(aNop_)       ;U      unlimited endless loops
    db     lsb(aNop_)       ;V
    db     lsb(while_)      ;W      conditional break from loop
    db     lsb(exec_)       ;X      execute machine code 
    db     lsb(aNop_)       ;Y
    db     lsb(aNop_)       ;Z

    ENDDAT 

backSpace:
    ld a,c
    or b
    jr z, interpret2
    dec bc
    call printStr
    .cstr "\b \b"
    jr interpret2
    
start:
    ld SP,DSTACK		; start of MINT
    call init		    ; setups
    call printStr		; prog count to stack, put code line 235 on stack then call print
    .cstr "MINT2.0\r\n"

interpret:
    call prompt

    ld bc,0                 ; load bc with offset into TIB, decide char into tib or execute or control         
    ld (vTIBPtr),bc

interpret2:                     ; calc nesting (a macro might have changed it)
    ld E,0                  ; initilize nesting value
    push bc                 ; save offset into TIB, 
                            ; bc is also the count of chars in TIB
    ld hl,TIB               ; hl is start of TIB
    jr interpret4

interpret3:
    ld a,(hl)               ; A = char in TIB
    inc hl                  ; inc pointer into TIB
    dec bc                  ; dec count of chars in TIB
    call nesting            ; update nesting value

interpret4:
    ld a,C                  ; is count zero?
    or B
    jr NZ, interpret3       ; if not loop
    pop bc                  ; restore offset into TIB

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
    cp CTRL_R
    ld e,lsb(reedit_)
    jr z,macro
    cp CTRL_L
    ld e,lsb(list_)
    jr z,macro
    cp CTRL_S
    ld e,lsb(printStack_)
    jr z,macro
    jr interpret2

macro:                          
    ld (vTIBPtr),bc
    push de
    call ENTER		;mint go operation and jump to it
    .cstr "/G"
    ld bc,(vTIBPtr)
    jr interpret2

waitchar1:
    ld hl,TIB
    add hl,bc
    ld (hl),A               ; store the character in textbuf
    inc bc
    call putchar            ; echo character to screen
    call nesting
    jr  waitchar            ; wait for next character

waitchar3:
    ld hl,TIB
    add hl,bc
    ld (hl),"\r"            ; store the crlf in textbuf
    inc hl
    ld (hl),"\n"            
    inc hl                  ; ????
    inc bc
    inc bc
    call crlf               ; echo character to screen
    ld a,E                  ; if zero nesting append and ETX after \r
    or A
    jr NZ,waitchar
    ld (hl),$03             ; store end of text ETX in text buffer 
    inc bc

waitchar4:    
    ld (vTIBPtr),bc
    ld bc,TIB               ; Instructions stored on heap at address HERE, we pressed enter
    dec bc

NEXT:                           
    inc bc                      ; Increment the IP
    ld a,(bc)                   ; Get the next character and dispatch
    or a                        ; is it NUL?       
    jr z,exit
    cp CTRL_C
    jr z,etx
    sub "!"
    jr c,NEXT
    ld L,A                      ; Index into table
    ld H,msb(opcodes)           ; Start address of jump table         
    ld L,(hl)                   ; get low jump address
    ld H,msb(page4)             ; Load H with the 1st page address
    jp (hl)                     ; Jump to routine

exit:
    inc bc			; store offests into a table of bytes, smaller
    ld de,bc                
    call rpop               ; Restore Instruction pointer
    ld bc,hl
    EX de,hl
    jp (hl)

etx:                                
    ld hl,-DSTACK               ; check if stack pointer is underwater
    add hl,SP
    jr NC,etx1
    ld SP,DSTACK
etx1:
    jp interpret

init:                           
    ld IX,RSTACK
    ld IY,NEXT		; IY provides a faster jump to NEXT

    ld hl,altVars               ; init altVars to 0 
    ld b,26 * 2
init1:
    ld (hl),0
    inc hl
    djnz init1
    ld hl,TRUE                  ; hl = TRUE
    ld (vTrue),hl
    dec hl                      ; hl = Unlimited
    ld (vUnlimited),hl
    ld hl,dStack
    ld (vStkStart),hl
    ld hl,65
    ld (vLastDef),hl
    ld hl,HEAP
    ld (vHeapPtr),hl

    ld hl,VARS              ; init namespaces to 0 using LDIR
    ld de,hl
    inc de
    ld (hl),0
    ld bc,VARS_SIZE
    LDIR

initOps:
    ld hl, iOpcodes
    ld de, opcodes
    ld bc, $80-32-1-1+26

initOps1:
    ld a,(hl)
    inc hl
    SLA A                     
    ret Z
    jr C, initOps2
    SRL A
    ld C,A
    ld B,0
    LDIR
    jr initOps1
    
initOps2:        
    SRL A
    ld B,A
    ld a,(hl)
    inc hl
initOps2a:
    ld (de),A
    inc de
    DJNZ initOps2a
    jr initOps1

lookupRef1:
    sub "A"
    ld e,0
    jr lookupRef3        
lookupRef2:
    sub "a"
    ld e,26*2
lookupRef3:
    add a,a
    add a,e
    ld hl,VARS
    add a,l
    ld l,a
    ld a,0
    ADC a,h
    ld h,a
    XOR a
    or e                        ; sets Z flag if A-Z
    ret

printhex:                           
                                ; Display hl as a 16-bit number in hex.
    push bc                     ; preserve the IP
    ld a,H
    call printhex2
    ld a,L
    call printhex2
    pop bc
    ret
printhex2:		                    
    ld	C,A
	RRA 
	RRA 
	RRA 
	RRA 
    call printhex3
    ld a,C
printhex3:		
    and	0x0F
	add	a,0x90
	DAA
	ADC	a,0x40
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

nesting:                        
    CP '`'
    jr NZ,nesting1
    BIT 7,E
    jr Z,nesting1a
    RES 7,E
    ret
nesting1a: 
    SET 7,E
    ret
nesting1:
    BIT 7,E             
    ret NZ             
    CP ':'
    jr Z,nesting2
    CP '['
    jr Z,nesting2
    CP '('
    jr NZ,nesting3
nesting2:
    inc E
    ret
nesting3:
    CP ';'
    jr Z,nesting4
    CP ']'
    jr Z,nesting4
    CP ')'
    ret NZ
nesting4:
    dec E
    ret 

prompt:                            
    call printStr
    .cstr "\r\n> "
    ret

crlf:                               
    call printStr
    .cstr "\r\n"
    ret

printStr:                           
    EX (SP),hl		                ; swap			
    call putStr		
    inc hl			                ; inc past null
    EX (SP),hl		                ; put it back	
    ret

putStr0:                            
    call putchar
    inc hl
putStr:
    ld a,(hl)
    or A
    jr NZ,putStr0
    ret

rpush:                              
    dec IX                  
    ld (IX+0),H
    dec IX
    ld (IX+0),L
    ret

rpop:                               
    ld L,(IX+0)         
    inc IX              
    ld H,(IX+0)
    inc IX                  
rpop2:
    ret

writeChar:                          
    ld (hl),A
    inc hl
    jp putchar

toggle:
    ld a,(hl)
    cpl
    ld (hl),a
    inc hl
    ld a,(hl)
    cpl
    ld (hl),a
    jp (iy)

enter:                              
    ld hl,bc
    call rpush                      ; save Instruction Pointer
    pop bc
    dec bc
    jp (iy)                    

carry:                              
    ld hl,0
    rl l
    ld (vCarry),hl
    jp (iy)              

; **********************************************************************			 
; Page 4 primitive routines 
; **********************************************************************
    .align $100
page4:

quote_:                          ; Discard the top member of the stack
    pop     hl
at_:
bslash_:   
underscore_: 
    jp (IY)

amper_:        
    pop de                  ;     Bitwise and the top 2 elements of the stack
    pop hl          
    ld a,E         
    and L           
    ld L,A         
    ld a,D         
    and H           
and1:
    ld h,a         
    push hl          
    jp (iy)           
    
                        
pipe_: 		 
    pop de                  ; Bitwise or the top 2 elements of the stack
    pop hl
    ld a,E
    or L
    ld L,A
    ld a,D
    or h
    jr and1

caret_:		 
    pop     de              ; Bitwise XOR the top 2 elements of the stack
xor1:
    pop     hl
    ld      a,E
    XOR     L
    ld      L,A
    ld      a,D
    XOR     H
    jr and1

tilde_:                               
invert:				        ; Bitwise INVert the top member of the stack
    ld de, $FFFF            ; by xoring with $FFFF
    jr xor1        

plus_:                           ; add the top 2 members of the stack
    pop     de                 
    pop     hl                 
    add     hl,de              
    push    hl                 
    jp carry              
                             
call_:
    ld a,(bc)
    call lookupRef1
    ld E,(hl)
    inc hl
    ld D,(hl)
    jp go1

dot_:       
    pop hl
    call printDec
dot2:
    ld a,' '           
    call putChar
    jp (IY)

comma_:                          ; print hexadecimal
    pop     hl
    call printhex
    jr   dot2

dquote_:        
    pop     hl              ; Duplicate the top member of the stack
    push    hl
    push    hl
    jp (IY)

    jp NEXT             ; hardwire white space to always go to NEXT (important for arrays)

percent_:  
    pop hl              ; Duplicate 2nd element of the stack
    pop de
    push de
    push hl
    push de              ; and push it to top of stack
    jp (IY)        

semi_:
    call rpop               ; Restore Instruction pointer
    ld bc,hl                
    jp (IY)             

;  Left shift { is multiply by 2		
lbrace_:   
    pop hl                  ; Duplicate the top member of the stack
    add hl,hl
    push hl                 ; shift left fallthrough into plus_     
    jp (IY)                 

			;  Right shift } is a divide by 2		
rbrace_:    
    pop hl                  ; Get the top member of the stack
shr1:
    SRL H
    RR L
    push hl
    jp (IY)                 

bang_:                      ; Store the value at the address placed on the top of the stack
assign:
    pop hl                  ; discard value of last accessed variable
    pop de                  ; new value
    ld hl,(vPointer)
    ld (hl),e          
    ld a,(vByteMode)                   
    inc a                   ; is it byte?
    jr z,assign1
    inc hl              
    ld (hl),d          
assign1:
    jp (IY)            
                              
; $ swap                    ; a b -- b a Swap the top 2 elements of the stack
dollar_:        
    pop hl
    EX (SP),hl
    push hl
    jp (IY)
    
minus_:       		        ; Subtract the value 2nd on stack from top of stack 
    inc bc                  ; check if sign of a number
    ld a,(bc)
    dec bc
    cp "0"
    jr c,sub1
    cp "9"+1
    jp c,num    
sub1:
    pop de                  
    pop hl                  
sub2:   
    and A                   
    sbc hl,de            
    push hl                 
    jp carry               
                              
eq_:    
    pop hl
    pop de
    or a               ; reset the carry flag
    sbc hl,de          ; only equality sets hl=0 here
    jp z,true_
    jp false_

gt_:    
    pop hl
    pop de
    jr lt1_
    
lt_:    
    pop de
    pop hl
    
lt1_:   
    or a                ; reset the carry flag
    sbc hl,de           ; only equality sets hl=0 here
    jp c,true_
    jp false_
    
var_:
    ld a,(bc)
    call lookupRef2
var1:
    ld (vPointer),hl
    ld d,0
    ld e,(hl)
    ld a,(vByteMode)                   
    inc a                       ; is it byte?
    jr z,var2
    inc hl
    ld d,(hl)
var2:
    push de
    jp (iy)
    
grave_:                         
str:                                                      
    inc bc
    
str1:            
    ld a, (bc)
    inc bc
    CP "`"                      ; ` is the string terminator
    jr Z,str2
    call putchar
    jr str1
str2:  
    dec bc
    jp   (IY) 

lbrack_:
arrDef:                         
    ld hl,0
    add hl,sp                   ; save 
    call rpush
    jp (iy)

num_:   
    jp num
rparen_: 
    jp again		            ; close loop
rbrack_:
    jp arrEnd
colon_:   
    jp def
lparen_: 
    jp begin

question_:
    jr arrAccess
hash_:
    jr hex
star_:   
    jr mul      
slash_:   

alt_:                           ; falls through (must be on page 4) 
;*******************************************************************
; Page 5 primitive routines 
;*******************************************************************
alt:                                
    inc bc
    ld a,(bc)
    cp "z"+1
    jr nc,alt1
    cp "a"
    jr nc,altVar
    cp BSLASH
    jr z,comment
    cp "Z"+1
    jr nc,alt1
    cp "A"
    jr nc,altCode
alt1:
    dec bc
    jp div

altVar:
    cp "i"
    ld l,0
    jp z,loopVar
    cp "j"
    ld l,8
    jr z,loopVar
    sub "a" 
    add a,a
    ld h,msb(altVars)
    ld l,A
    jp var1                    

loopVar:    
    ld h,0
    ld d,ixh
    ld e,ixl
    add hl,de
    jp var1

comment:
    inc bc                      ; point to next char
    ld a,(bc)
    CP "\r"                     ; terminate at cr 
    jr NZ,comment
    dec bc
    jp   (IY) 

altCode:
    ld hl,altCodes
    sub "A"
    add a,L
    ld L,A
    ld a,(hl)                   ;       get low jump address
    ld hl,page6
    ld L,A                      
    jp (hl)                     ;       Jump to routine

arrAccess:
    pop hl                      ; hl = index  
    pop de                      ; de = array
    ld a,(vByteMode)            ; a = data width
    inc a
    jr z,arrAccess1
    add hl,hl                   ; if data width = 2 then double 
arrAccess1:
    add hl,de                   ; hl = addr
    jp var1

hex:
    ld hl,0	    		        ; Clear hl to accept the number
hex1:
    inc bc
    ld a,(bc)		            ; Get the character which is a numeral
    BIT 6,A                     ; is it uppercase alpha?
    jp Z, hex2                  ; no a decimal
    sub 7                       ; sub 7  to make $A - $F
hex2:
    sub $30                     ; Form decimal digit
    jp C,num2
    CP $0F+1
    jp NC,num2
    add hl,hl                   ; 2X ; Multiply digit(s) in hl by 16
    add hl,hl                   ; 4X
    add hl,hl                   ; 8X
    add hl,hl                   ; 16X     
    add a,L                     ; add into bottom of hl
    ld  L,A                     
    jp  hex1

mul:                                
    pop  de                     ; get first value
    pop  hl
    push bc                     ; Preserve the IP
    ld B,H                      ; bc = 2nd value
    ld C,L
    
    ld hl,0
    ld a,16
mul2:
    add hl,hl
    RL E
    RL D
    jr NC,$+6
    add hl,bc
    jr NC,$+3
    inc de
    dec A
    jr NZ,mul2
	pop bc			    ; Restore the IP
	push hl                     ; Put the product on the stack - stack bug fixed 2/12/21
	jp (IY)

begin:
loopStart:
    ld (vTemp1),bc              ; save start
    ld e,1                      ; skip to loop end, nesting = 1
loopStart1:
    inc bc
    ld a,(bc)
    call nesting                ; affects zero flag
    jr nz,loopStart1
    pop de                      ; de = limit
    ld a,e                      ; is it zero?
    or d
    jr nz,loopStart2
    dec de                      ; de = TRUE
    ld (vElse),de
    jr loopStart4               ; yes continue after skip    
loopStart2:
    ld a,2                      ; is it TRUE
    add a,e
    add a,d
    jr nz,loopStart3                
    ld de,1                     ; yes make it 1
loopStart3:    
    ld hl,bc
    call rpush                  ; rpush loop end
    dec bc                      ; IP points to ")"
    ld hl,(vTemp1)              ; restore start
    call rpush                  ; rpush start
    ex de,hl                    ; hl = limit
    call rpush                  ; rpush limit
    ld hl,-1                    ; hl = count = -1 
    call rpush                  ; rpush count
loopstart4:    
    jp (iy)
    
again:
loopEnd:    
    ld e,(ix+2)                 ; de = limit
    ld d,(ix+3)
    ld a,e                      ; a = lsb(limit)
    or d                        ; if limit 0 exit loop
    jr z,loopEnd4                  
    inc de                      ; is limit -2
    inc de
    ld a,e                      ; a = lsb(limit)
    or d                        ; if limit 0 exit loop
    jr z,loopEnd2               ; yes, loop again
    dec de
    dec de
    dec de
    ld (ix+2),e                  
    ld (ix+3),d
loopEnd2:
    ld e,(ix+0)                 ; inc counter
    ld d,(ix+1)
    inc de
    ld (ix+0),e                  
    ld (ix+1),d
loopEnd3:
    ld de,FALSE                 ; if clause ran then vElse = FALSE    
    ld (vElse),de
    ld c,(ix+4)                 ; IP = start
    ld b,(ix+5)
    jp (iy)
loopEnd4:    
    ld de,2*4                   ; rpop frame
    add ix,de
    jp (iy)
    
; **************************************************************************
; Page 6 Alt primitives
; **************************************************************************
    .align $100
page6:

; allocates raw heap memory in bytes (ignores byte mode)
; n -- a
alloc_:
    pop de
    ld hl,(vHeapPtr)
    push hl
    add hl,de
    ld (vHeapPtr),hl
aNop_:
    jp (iy)    

; returns the size of an array
; a -- n
arrSize_:
arrSize:
    pop hl
    dec hl                      ; msb size 
    ld d,(hl)
    dec hl                      ; lsb size 
    ld e,(hl)
    push de
    jp (iy)

bmode_:
    ld hl,vByteMode
    jp toggle

break_:
while_:
while:
    pop hl
    ld a,l
    or h
    jr nz,while2
    ld c,(ix+6)                 ; IP = )
    ld b,(ix+7)
    jp loopEnd4
while2:
    jp (iy)

depth_:
depth:
    ld hl,0
    add hl,SP
    EX de,hl
    ld hl,DSTACK
    or A
    sbc hl,de
    jp shr1

printChar_:
    pop hl
    ld a,L
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

go_:				    
    pop de
go1:
    ld a,D                      ; skip if destination address is null
    or E
    jr Z,go3
    ld hl,bc
    inc bc                      ; read next char from source
    ld a,(bc)                   ; if ; to tail call optimise
    CP ";"                      ; by jumping to rather than calling destination
    jr Z,go2
    call rpush                  ; save Instruction Pointer
go2:
    ld bc,de
    dec bc
go3:
    jp (IY)                     

key_:
    call getchar
    ld H,0
    ld L,A
    push hl
    jp (IY)

inPort_:			    ; \<
    pop hl
    ld a,C
    ld C,L
    IN L,(C)
    ld H,0
    ld C,A
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

;*******************************************************************
; Subroutines
;*******************************************************************

editDef:                        ; lookup up def based on number
    pop hl                      ; pop ret address
    EX (SP),hl                  ; swap with TOS                  
    ld a,L
    EX AF,AF'
    ld a,l
    call lookupRef1
    ld E,(hl)
    inc hl
    ld D,(hl)
    ld a,D
    or E
    ld hl,TIB
    jr Z,editDef3
    ld a,":"
    call writeChar
    EX AF,AF'
    call writeChar
    jr editDef2
editDef1:
    inc de
editDef2:        
    ld a,(de)
    call writeChar
    CP ";"
    jr NZ,editDef1
editDef3:        
    ld de,TIB
    or A
    sbc hl,de
    ld (vTIBPtr),hl
    ret

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

;*******************************************************************
; Page 5 primitive routines continued
;*******************************************************************

def:                                ; Create a colon definition
    inc bc
    ld  a,(bc)                  ; Get the next character
    cp ":"                      ; is it anonymouse
    jr nz,def0
    inc bc
    ld de,(vHeapPtr)            ; return start of definition
    push de
    jr def1
def0:    
    ld (vLastDef),a
    call lookupRef1
    ld de,(vHeapPtr)            ; start of defintion
    ld (hl),E                   ; Save low byte of address in CFA
    inc hl              
    ld (hl),D                   ; Save high byte of address in CFA+1
    inc bc
def1:                               ; Skip to end of definition   
    ld a,(bc)                   ; Get the next character
    inc bc                      ; Point to next character
    ld (de),A
    inc de
    CP ";"                      ; Is it a semicolon 
    jr Z, def2                  ; end the definition
    jr  def1                    ; get the next element
def2:    
    dec bc
def3:
    ld (vHeapPtr),de            ; bump heap ptr to after definiton
    jp (IY)       

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
    inc a
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

div:
    ld hl,bc                    ; hl = IP
    pop bc                      ; bc = denominator
    ex (sp),hl                  ; save IP, hl = numerator  
    ld a,h
    xor b
    push af
    xor b
    jp p,absbc
;absHL
    xor a  
    sub l  
    ld l,a
    sbc a,a  
    sub h  
    ld h,a
absbc:
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
    ld (vRemain),hl             ; remainder
    jp (iy)

false_:
    ld hl,FALSE
    jr true1

true_:
    ld hl,TRUE
true1:
    push hl
    jp (iy)


