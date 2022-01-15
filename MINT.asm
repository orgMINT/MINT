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

        DSIZE       EQU $80
        RSIZE       EQU $80
        TIBSIZE     EQU $100
        TRUE        EQU 1
        FALSE       EQU 0
        EMPTY       EQU 0

        NSNUM       EQU 5       ; namespaces 
        NSSIZE      EQU $80

.macro LITDAT,len
        DB len
.endm

.macro REPDAT,len,data
        
        DB (len | $80)
        DB data
.endm

.macro ENDDAT
        DB 0
.endm

; **************************************************************************
; Page 0  Initialisation
; **************************************************************************		

		.ORG ROMSTART + $180		

; ***********************************************************************
; Initial values for user mintVars		
; ***********************************************************************		
iAltVars:
        DW dStack               ; a vS0
        DW FALSE                ; b vBase16
        DW 0                    ; c vTIBPtr
        DW NS0                  ; d vNS
        DW 65                   ; e vLastDef "A"
        DW 0                    ; f 
        DW page6                ; g 
        DW HEAP                 ; h vHeapPtr

etx:                                ;=12
        LD HL,-DSTACK
        ADD HL,SP
        JR NC,etx1
        LD SP,DSTACK
etx1:
        JR interpret

start:
        LD SP,DSTACK
        CALL init
        CALL printStr
        .cstr "MINT V1.1\r\n"

interpret:
        call prompt

        LD BC,0                 ; load BC with offset into TIB         
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
        CALL getchar            ; loop around waiting for character
        CP $20
        JR NC,waitchar1
        CP $0                   ; is it end of string?
        JR Z,waitchar4
        CP '\r'                 ; carriage return?
        JR Z,waitchar3
        ; LD D,0
macro:                          ;=25
        LD (vTIBPtr),BC
        LD HL,ctrlCodes
        ADD A,L
        LD L,A
        LD E,(HL)
        LD D,msb(macros)
        PUSH DE
        call ENTER
        .cstr "\\^"
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
        LD BC,TIB               ; Instructions stored on heap at address HERE
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

NEXT:                               ;=9 
        INC BC                      ;       Increment the IP
        LD A, (BC)                  ;       Get the next character and dispatch
        LD L,A                      ;       Index into table
        LD H,msb(opcodes)           ;       Start address of jump table         
        LD L,(HL)                   ;       get low jump address
        LD H,msb(page4)             ;       Load H with the 1st page address
        JP (HL)                     ;       Jump to routine

; ARRAY compilation routine
compNEXT:                       ;=20
        POP DE          ; DE = return address
        LD HL,(vHeapPtr)    ; load heap ptr
        LD (HL),E       ; store lsb
        LD A,(vByteMode)
        INC HL          
        OR A
        JR NZ,compNext1
        LD (HL),D
        INC HL
compNext1:
        LD (vHeapPtr),HL    ; save heap ptr
        JR NEXT

init:
        LD IX,RSTACK
        LD IY,NEXT			    ; IY provides a faster jump to NEXT
        LD HL,ialtVars
        LD DE,altVars
        LD BC,8 * 2
        LDIR
        
        LD HL,NS0              ; init namespaces to 0
        LD DE,HL
        INC DE
        LD (HL),0
        LD BC,NSNUM*NSSIZE
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

enter:                              ;=9
        LD HL,BC
        CALL rpush                  ; save Instruction Pointer
        POP BC
        DEC BC
        JP (IY)                    

NSLookup:
        LD D,0
NSLookup0:
        CP "a"
        JR NC,NSLookup2
NSLookup1:
        SUB "A"
        LD E,0
        JR NSLookup3        
NSLookup2:
        SUB "a"
        LD E,26*2
NSLookup3:
        ADD A,A
        ADD A,E
        LD HL,(vNS)
        ADD A,L
        LD L,A
        LD A,0
        ADC A,H
        LD H,A
        XOR A
        OR E                        ; sets Z flag if A-Z
        RET

printdec:                           ;=36
        LD DE,-10000
        CALL printdec1
        LD DE,-1000
        CALL printdec1
        LD DE,-100
        CALL printdec1
        LD E,-10
        CALL printdec1
        LD E,-1
printdec1:	    
        LD A,'0'-1
printdec2:	    
        INC A
        ADD HL,DE
        JR C,printdec2
        SBC HL,DE
        JP putchar

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

; **************************************************************************
; Macros must be written in Mint and end with ; 
; this code must not span pages
; **************************************************************************
macros:

.include "MINT-macros.asm"

iOpcodes:
        LITDAT 4
        DB    lsb(exit_)    ;   NUL 
        DB    lsb(nop_)     ;   SOH 
        DB    lsb(nop_)     ;   STX 
        DB    lsb(etx_)     ;   ETX 

        REPDAT 29, lsb(nop_)

        LITDAT 15
        DB    lsb(store_)   ;   !            
        DB    lsb(dup_)     ;   "
        DB    lsb(hex_)    ;    #
        DB    lsb(swap_)   ;    $            
        DB    lsb(over_)   ;    %            
        DB    lsb(and_)    ;    &
        DB    lsb(drop_)   ;    '
        DB    lsb(begin_)  ;    (        
        DB    lsb(again_)  ;    )
        DB    lsb(mul_)    ;    *            
        DB    lsb(add_)    ;    +
        DB    lsb(hdot_)   ;    ,            
        DB    lsb(sub_)    ;    -
        DB    lsb(dot_)    ;    .
        DB    lsb(div_)    ;    /

        REPDAT 10, lsb(num_)

        LITDAT 7
        DB    lsb(def_)    ;    :        
        DB    lsb(ret_)    ;    ;
        DB    lsb(lt_)     ;    <
        DB    lsb(eq_)     ;    =            
        DB    lsb(gt_)     ;    >            
        DB    lsb(key_)    ;    ?   ( -- val )  read a char from input
        DB    lsb(fetch_)  ;    @    

        REPDAT 26, lsb(call_)

        LITDAT 6
        DB    lsb(arrDef_) ;    [
        DB    lsb(alt_)    ;    \
        DB    lsb(arrEnd_) ;    ]
        DB    lsb(xor_)    ;    ^
        DB    lsb(neg_)    ;    _
        DB    lsb(str_)    ;    `            

        REPDAT 26, lsb(var_)

        LITDAT 5
        DB    lsb(shl_)    ;    {
        DB    lsb(or_)     ;    |            
        DB    lsb(shr_)    ;    }            
        DB    lsb(rot_)    ;    ~ ( a b c -- b c a ) rotate            
        DB    lsb(nop_)    ;    backspace

        LITDAT 17
        DB     lsb(EMPTY)       ; NUL ^@        
        DB     lsb(EMPTY)       ; SOH ^A  1
        DB     lsb(toggleBase_) ; STX ^B  2
        DB     lsb(EMPTY)       ; ETX ^C  3
        DB     lsb(EMPTY)       ; EOT ^D  4
        DB     lsb(edit_)       ; ENQ ^E  5
        DB     lsb(EMPTY)       ; ACK ^F  6
        DB     lsb(EMPTY)       ; BEL ^G  7 
        DB     lsb(backsp_)     ; BS  ^H  8
        DB     lsb(EMPTY)       ; TAB ^I  9
        DB     lsb(reedit_)     ; LF  ^J 10
        DB     lsb(EMPTY)       ; VT  ^K 11
        DB     lsb(list_)       ; FF  ^L 12
        DB     lsb(EMPTY)       ; CR  ^M 13
        DB     lsb(EMPTY)       ; SO  ^N 14
        DB     lsb(EMPTY)       ; SI  ^O 15
        DB     lsb(printStack_) ; DLE ^P 16

        REPDAT 15, lsb(EMPTY)

        LITDAT 5
        DB     lsb(aNop_)       ;a0    SP  
        DB     lsb(anonDef_)    ;a1    \!            
        DB     lsb(aNop_)       ;a2    \"  
        DB     lsb(util_)       ;a3    \#  utility command
        DB     lsb(newln_)      ;a4    \$  prints a newline to output

        REPDAT 3, lsb(aNop_)

        LITDAT 8
        DB     lsb(ifte_)       ;a8    (  ( b -- )              
        DB     lsb(aNop_)       ;a9    )                
        DB     lsb(aNop_)       ;aa    *                
        DB     lsb(aNop_)       ;ab    +                
        DB     lsb(emit_)       ;ac    ,  ( b -- ) prints a char              
        DB     lsb(aNop_)       ;ad    -                
        DB     lsb(prnStr_)     ;ae    .  ( b -- )              
        DB     lsb(aNop_)       ;af    /                

        REPDAT 5, lsb(NSRef_)
        REPDAT 5, lsb(aNop_)

        LITDAT 7
        DB     lsb(altDef_)     ;ba    :  ( -- adr) returns adr of anonymous command  
        DB     lsb(aNop_)       ;bb    ;    
        DB     lsb(aNop_)       ;bc    <    
        DB     lsb(i_)          ;bd    =  ( -- adr) returns address of index variable  
        DB     lsb(prompt_)     ;be    >            
        DB     lsb(getRef_)     ;bf    ?
        DB     lsb(cFetch_)     ;c0    @      

        REPDAT 26, lsb(altCall_)

        LITDAT 6
        DB     lsb(cArrDef_)    ;db    [
        DB     lsb(comment_)    ;dc    \  comment text, skips reading until end of line
        DB     lsb(aNop_)       ;dd    ]
        DB     lsb(go_)         ;de    ^  ( -- ? ) execute mint definition
        DB     lsb(break_)      ;df    _  break loop if true
        DB     lsb(strDef_)     ;e0    `  ( -- adr ) defines a string \` string `            

        REPDAT 8, lsb(altVar_)  ;e1

        LITDAT 1
        DB     lsb(i_)          ;e9    i  ; returns index variable of current loop          

        REPDAT 17, lsb(altVar_)

        LITDAT 5
        DB     lsb(NSEnter_)    ;fb    {
        DB     lsb(aNop_)       ;fc    |            
        DB     lsb(NSExit_)     ;fd    }            
        DB     lsb(aNop_)       ;fe    ~           
        DB     lsb(aNop_)       ;ff    BS		
        
        ENDDAT 

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

inv_:						    ; Bitwise INVert the top member of the stack
        LD DE, $FFFF            ; by xoring with $FFFF
        JR xor1        
   
add_:                           ; Add the top 2 members of the stack
        POP     DE                 
        POP     HL                 
        ADD     HL,DE              
        PUSH    HL                 
        JP (IY)              
                                 

arrDef_:    
arrDef:                         ;=18
        LD A,FALSE
arrDef1:      
        LD IY,compNEXT
        LD (vByteMode),A
        LD HL,(vHeapPtr)        ; HL = heap ptr
        CALL rpush              ; save start of array \[  \]
        JP NEXT                 ; hardwired to NEXT

call_:
        LD A,(BC)
        CALL NSLookup1
        LD E,(HL)
        INC HL
        LD D,(HL)
        JP go1

dot_:       
        POP HL
        CALL printdec
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
etx_:
        JP ETX
        
exit_:
        INC BC
        LD DE,BC                
        CALL rpop               ; Restore Instruction pointer
        LD BC,HL
        EX DE,HL
        JP (HL)
        
fetch_:                         ; Fetch the value from the address placed on the top of the stack      
        POP HL              
fetch1:
        LD E,(HL)         
        INC HL             
        LD D,(HL)         
        PUSH DE              
        JP (IY)           


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
        
sub_:       				    ; Subtract the value 2nd on stack from top of stack 
        
        POP DE              ;    
        POP HL              ;      Entry point for INVert
sub2:   
        AND A               ;      Entry point for NEGate
        SBC HL,DE           ; 15t
        PUSH HL              ;    
        JP (IY)            ;   
                                ; 5  
neg_:   
        LD HL, 0    		    ; NEGate the value on top of stack (2's complement)
        POP DE                  ;    
        JR sub2                 ; use the SUBtract routine
    
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
		JR Z,less         ; equality returns 0  KB 25/11/21
        LD HL, 0
        JP M,less
equal:  
        INC L              ; HL = 1    
less:     
        PUSH HL
        JP (IY) 
        
var_:
        LD A,(BC)
        CALL NSLookup2
        PUSH HL
        JP (IY)

again_: JP again

alt_:   JP alt

arrEnd_:JP arrEnd

mul_:   JP mul      

hex_:   JP hex

def_:   JP def

str_:                       
        JP str
        
num_:   JR  num

div_:   JR div

begin_: JR begin

;*******************************************************************
; Page 5 primitive routines 
;*******************************************************************
        ;falls through 
; *************************************
; Loop Handling Code
; *************************************
        	                        ;=23                     
begin:                              ; Left parentesis begins a loop
        POP HL
        LD A,L                      ; zero?
        OR H
        JR Z,begin1
        
        DEC HL
        LD DE,-6
        ADD IX,DE
        LD (IX+0),0                 ; loop var
        LD (IX+1),0                 
        LD (IX+2),L                 ; loop limit
        LD (IX+3),H                 
        LD (IX+4),C                 ; loop address
        LD (IX+5),B                 

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
begin3:
        JP (IY)

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
         
num:                                ;=23
		LD HL,$0000				    ;     Clear HL to accept the number
		LD A,(BC)				    ;     Get the character which is a numeral
        
num1:                               ; corrected KB 24/11/21

        SUB $30                     ;       Form decimal digit
        ADD A,L                     ;       Add into bottom of HL
        LD  L,A                     ;   
        LD A,00                     ;       Clear A
        ADC	A,H	                    ; Add with carry H-reg
	    LD	H,A	                    ; Put result in H-reg
      
        INC BC                      ;       Increment IP
        LD A, (BC)                  ;       and get the next character
        CP $30                      ;       Less than $30
        JR C, num2                  ;       Not a number / end of number
        CP $3A                      ;       Greater or equal to $3A
        JR NC, num2                 ;       Not a number / end of number
                                    ; Multiply digit(s) in HL by 10
        ADD HL,HL                   ;        2X
        LD  E,L                     ;        LD DE,HL
        LD  D,H                     ;    
        ADD HL,HL                   ;        4X
        ADD HL,HL                   ;        8X
        ADD HL,DE                   ;        2X  + 8X  = 10X
                                    ; 52t cycles

        JR  num1
                
num2:
        DEC BC
        PUSH HL                     ;       Put the number on the stack
        JP (IY)                     ; and process the next character

; ********************************************************************
; 16-bit division subroutine.
;
; BC: divisor, DE: dividend, HL: remainder

; *********************************************************************            
; This divides DE by BC, storing the result in DE, remainder in HL
; *********************************************************************

; 1382 cycles
; 35 bytes (reduced from 48)
		

div:                                ;=24
        POP  DE                     ; get first value
        POP  HL                     ; get 2nd value
        PUSH BC                     ; Preserve the IP
        LD B,H                      ; BC = 2nd value
        LD C,L		
		
        LD HL,0    	                ; Zero the remainder
        LD A,16    	                ; Loop counter

div1:		                        ;shift the bits from BC (numerator) into HL (accumulator)
        SLA C
        RL B
        ADC HL,HL

        SBC HL,DE			        ;Check if remainder >= denominator (HL>=DE)
        JR C,div2
        INC C
        JR div3
div2:		                        ; remainder is not >= denominator, so we have to add DE back to HL
        ADD hl,de
div3:
        DEC A
        JR NZ,div1
        LD D,B                      ; Result from BC to DE
        LD E,C
div4:    
        POP  BC                     ; Restore the IP
        PUSH DE                     ; Push Result
        PUSH HL                     ; Push remainder             

        JP (IY)


hex:                                ;=26
	    LD HL,0		    		    ;     Clear HL to accept the number
hex1:
        INC BC
        LD A,(BC)				    ;     Get the character which is a numeral
        BIT 6,A                     ;       is it uppercase alpha?
        JR Z, hex2                  ; no a decimal
        SUB 7                       ; sub 7  to make $A - $F
hex2:
        SUB $30                     ;       Form decimal digit
        JP C,num2
        CP $0F+1
        JP NC,num2
        ADD HL,HL                   ;        2X ; Multiply digit(s) in HL by 16
        ADD HL,HL                   ;        4X
        ADD HL,HL                   ;        8X
        ADD HL,HL                   ;       16X     
        ADD A,L                     ;       Add into bottom of HL
        LD  L,A                     ;   
        JR  hex1

arrEnd:                             ;=27
        CALL rpop                   ; DE = start of array
        PUSH HL
        EX DE,HL
        LD HL,(vHeapPtr)            ; HL = heap ptr
        OR A
        SBC HL,DE                   ; bytes on heap 
        LD A,(vByteMode)
        OR A
        JR NZ,arrEnd2
        SRL H                       ; BC = m words
        RR L
arrEnd2:
        PUSH HL 
        LD IY,NEXT
        JP (IY)                     ; hardwired to NEXT


; **************************************************************************             
; def is used to create a colon definition
; When a colon is detected, the next character (usually uppercase alpha)
; is looked up in the vector table to get its associated code field address
; This CFA is updated to point to the character after uppercase alpha
; The remainder of the characters are then skipped until after a semicolon  
; is found.
; ***************************************************************************
                                    ;=31
def:                                ; Create a colon definition
        INC BC
        LD  A,(BC)                  ; Get the next character
        LD (vLastDef),A
        INC BC
        CALL NSLookup
        LD DE,(vHeapPtr)            ; start of defintion
        LD (HL),E                   ; Save low byte of address in CFA
        INC HL              
        LD (HL),D                   ; Save high byte of address in CFA+1
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
        
again:                              ;=51
        LD E,(IX+0)                 ; peek loop var
        LD D,(IX+1)                 
        
        LD A,D                      ; check if IFTEMode
        AND E
        INC A
        JR NZ,again1
        INC DE
        PUSH DE                     ; push FALSE condition
        LD DE,2
        JR again3                   ; drop IFTEMode

again1:
        LD L,(IX+2)                 ; peek loop limit
        LD H,(IX+3)                 
        OR A
        SBC HL,DE
        JR Z,again2
        INC DE
        LD (IX+0),E                 ; poke loop var
        LD (IX+1),D                 
        LD C,(IX+4)                 ; peek loop address
        LD B,(IX+5)                 
        JP (IY)
again2:   
        LD DE,6                     ; drop loop frame
again3:
        ADD IX,DE
        JP (IY)

; **************************************************************************
; Page 6 Alt primitives
; **************************************************************************
        .align $100
page6:

altCall_:
        JP (IY)           

altDef_:
        JP (IY)           

anonDef_:
        JP anonDef

cArrDef_:                           ; define a byte array
        LD A,TRUE
        JP arrDef1

cFetch_:
        POP     HL          
        LD      D,0            
        LD      E,(HL)         
        PUSH    DE              
anop_:
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
                             
emit_:
        POP HL
        LD A,L
        CALL putchar
        JP (IY)

ifte_:
        POP DE
        LD A,E
        OR D
        JR NZ,ifte1
        INC DE
        PUSH DE                     ; push TRUE on stack for else clause
        JP begin1                   ; skip to closing ) works with \) too 
ifte1:
        LD HL,-1                    ; push -1 on return stack to indicate IFTEMode
        CALL rpush
        JP (IY)

getRef_:
getRef:                             ;=8
        INC BC
        LD A,(BC)
        CALL NSLookup
        JP fetch1

go_:
        POP DE
go1:
        LD A,D
        OR E
        JR Z,go2
        LD HL,BC
        CALL rpush                  ; save Instruction Pointer
        LD BC,DE
        DEC BC
go2:
        JP (IY)                     

NSRef_:                             ;=25
        LD IY,rpop2                 ; rewire NEXT to simply return
        CALL NSEnter1               ; enter namespace return here on NEXT
        LD A,(BC)
        CALL NSLookup
        JR NZ,NSRef2
        PUSH HL
        LD IY,NEXT                  ; restore NEXT
        CALL enter                  ; enter MINT interpreter with TOS=command 
        .cstr "@\\^"                ; execute and restore namespace
        JR NSExit_
NSRef2:                            ;=25
        PUSH HL
        LD IY,NEXT                  ; restore NEXT
NSExit_:                            
        call rpop
        LD (vNS),HL
        JP (IY)
        
prompt_:
        CALL prompt
        JP (IY)

altVar_:
        LD A,(BC)
        SUB "a" - ((altVars - mintVars)/2) 
        ADD A,A
        LD H,msb(mintVars)
        LD L,A
        PUSH HL
        JP (IY)                    

i_:
        PUSH IX
        JP (IY)

newln_:
        call crlf
        JP (IY)        

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

NSEnter_:
        INC BC
NSEnter1:
        LD A,(BC)                   ; read NS ASCII code
        SUB "0"                     ; convert to number
        INC BC
        LD D,A                      ; multiply by 64
        LD E,0
        SRL D
        RR E
        SRL D
        RR E
        LD HL,(vNS)               ; 
        call rpush
        LD HL,NS0
        ADD HL,DE
        LD (vNS),HL
        JP (IY)                    

strDef_:
        JR strDef
        
prnStr_:
prnStr:
        POP HL
        CALL putStr
        JP (IY)

util_:
        JP util
        
; **************************************************************************
; Page 6 primitive routines 
; **************************************************************************
        ; falls through
; **************************************************************************             
; copy definition to text input buffer
; update TIBPtr
; **************************************************************************             

strDef:                         ;=21
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

anonDef:                             ; Create a colon definition
        INC BC
        LD DE,(vHeapPtr)            ; start of defintion
        PUSH DE
anonDef1:                            ; Skip to end of definition   
        LD A,(BC)                   ; Get the next character
        INC BC                      ; Point to next character
        LD (DE),A
        INC DE
        CP ";"                      ; Is it a semicolon 
        JR Z, anonDef2               ; end the definition
        JR  anonDef1                 ; get the next element
anonDef2:    
        DEC BC
        LD (vHeapPtr),DE            ; bump heap ptr to after definiton
        JP (IY)       


;*******************************************************************
; Page 5 primitive routines continued
;*******************************************************************

alt:                                ;=11
        INC BC
        LD A,(BC)
        LD HL,altCodes
        ADD A,L
        LD L,A
alt2:
        LD A,(HL)                   ;       get low jump address
        LD HL,(vAltPage)
        LD L,A                      
        JP (HL)                     ;       Jump to routine

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

; ********************************************************************
; 16-bit multiply  
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
		POP BC				        ; Restore the IP
		PUSH HL                     ; Put the product on the stack - stack bug fixed 2/12/21
		JP (IY)

util:
        INC BC
        LD A,(BC)
        SUB "0"
        LD H,msb(utilTable)
        LD L,A
        LD L,(HL)
        LD H,msb(utilCode)
        JP (HL)

        .align $100
utilTable:
        DB lsb(outPort_)    ;0    ( val port -- )
        DB lsb(inPort_)     ;1    ( port -- val )   
        DB lsb(exec_)       ;2    
        DB lsb(depth_)      ;3    ( -- val ) depth of data stack  
        DB lsb(printStk_)   ;4    ( -- ) non-destructively prints stack
        DB lsb(editDef_)    ;5    

utilCode:

exec_:
        CALL exec1
        JP (IY)
exec1:
        POP HL
        EX (SP),HL
        JP (HL)

depth_:
        LD HL,0
        ADD HL,SP
        EX DE,HL
        LD HL,DSTACK
        OR A
        SBC HL,DE
        JP shr1

printStk_:
printStk:                           ;=40
        ; MINT: \a@2- \#3 1- ("@ \b@ \(,)(.) 2-) '             
        call ENTER
        .cstr "`=> `\\a@2-\\#3 1-(",$22,"@\\b@\\(,)(.)2-)'\\$"             
        JP (IY)

editDef_:
        call editDef
        JP (IY)

inPort_:
        POP HL
        LD A,C
        LD C,L
        IN L,(C)
        LD H,0
        LD C,A
        PUSH HL
        JP (IY)        

outPort_:
        POP HL
        LD E,C
        LD C,L
        POP HL
        OUT (C),L
        LD C,E
        JP (IY)        

;*******************************************************************
; Subroutines
;*******************************************************************
editDef:                            ;=50 lookup up def based on number
        POP HL                      ; pop ret address
        EX (SP),HL                  ; swap with TOS                  
        LD A,L
        EX AF,AF'
        LD A,L
        CALL NSLookup
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
writeChar:                          ;=5
        LD (HL),A
        INC HL
        JP putchar

printhex:                           ;=11  
                                    ; Display HL as a 16-bit number in hex.
        PUSH BC                     ; preserve the IP
        LD A,H
        CALL printhex2
        LD A,L
        CALL printhex2
        POP BC
        RET
printhex2:		                    ;=20
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

printStr:                           ;=14
        EX (SP),HL
        CALL putStr
        INC HL
        EX (SP),HL
        RET

putStr0:
        CALL putchar
        INC HL
putStr:
        LD A,(HL)
        OR A
        JR NZ,putStr0
        RET

