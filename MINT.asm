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
        LSIZE       EQU $80
        TIBSIZE     EQU $100		; 256 bytes , along line!
        TRUE        EQU 1		; not FF, for MINT
        FALSE       EQU 0
        EMPTY       EQU 0		; for an empty macro, ctrl-<something>=macro, ie ctrl-h = backspace macros (in MINT)

        mintDataSize      EQU 26*2*2	; A..Z, a..z words

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

backsp_:
        DB "\\c@0=0=(\\c@1-\\c!`\b \b`);"	;ctr-h  , \ needed inside control code, escape it with anothe \
                                            	; \c tib add of tib, not visible
                                         	;@ fetch val
                                          	;1- reduce
                                          	;c! store
                                          	;`\b move cursor back, terminal command
                                          	;the space between the \b is to over write
                                            	;
	
reedit_:
        DB "\\e\\@\\#6;"			; remembers last line edited

edit_:
        .cstr "`?`?\\#5\\#6;"

list_:
        .cstr "\\$26(\\i@65+\\#6\\c@0>(\\$))\\#5;"

printStack_:
        .cstr "\\#4\\#5;"        

toggleBase_:
        .cstr "\\b@0=\\b!;"


; ***********************************************************************
; Initial values for user mintVars		
; ***********************************************************************		
iAltVars:			; value copied into tables
        DW dStack               ; a vS0 start of datastack			
        DW FALSE                ; b vBase16 
        DW 0                    ; c vTIBPtr an offset to the tib
        DW 0                    ; d 
        DW 65                   ; e vLastDef "A" last command u defined
        DW 0                    ; f 
        DW page6                ; g 256 bytes limits
        DW HEAP                 ; h vHeapPtr \h start of the free mem

iOpcodes:
        LITDAT 4		; macros for compression
        DB    lsb(exit_)    ;   NUL get least signif byte of address exit_
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
        DB    lsb(div_)    ;    /	;/MOD

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
        DB    lsb(neg_)    ;    _
        DB    lsb(str_)    ;    `    	; for printing `hello`        

        REPDAT 26, lsb(var_)		; a b c .....z

        LITDAT 5
        DB    lsb(shl_)    ;    {
        DB    lsb(or_)     ;    |            
        DB    lsb(shr_)    ;    }            
        DB    lsb(rot_)    ;    ~ ( a b c -- b c a ) rotate            
        DB    lsb(nop_)    ;    DEL	; eg 10000()

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
        DB     lsb(aNop_)       ;a0    SP  				;space
        DB     lsb(aNop_)       ;a1    \!       			; this is a bug shud be lsb(cstore_)     
        DB     lsb(aNop_)       ;a2    \"  				
        DB     lsb(util_)       ;a3    \#  utility command		; table of special routines ie #5 etc				
        DB     lsb(newln_)      ;a4    \$  prints a newline to output	

        REPDAT 3, lsb(aNop_)

        LITDAT 8
        DB     lsb(aNop_)       ;a8    \(  ( b -- )              
        DB     lsb(aNop_)       ;a9    \)                
        DB     lsb(aNop_)       ;aa    \*                
        DB     lsb(aNop_)       ;ab    \+                
        DB     lsb(emit_)       ;ac    \,  ( b -- ) prints a char              
        DB     lsb(aNop_)       ;ad    \-                
        DB     lsb(prnStr_)     ;ae    \.  ( b -- ) prints a string from add term by null char             
        DB     lsb(aNop_)       ;af    \/                

        REPDAT 10, lsb(aNop_)

        LITDAT 7
        DB     lsb(anonDef_)    ;ba    \:	return add of a anon def, \: 1 2 3;    \\ ret add of this                
        DB     lsb(aNop_)       ;bb    \;                
        DB     lsb(inPort_)     ;bc    \<  ( port -- val )
        DB     lsb(aNop_)       ;bd    \=    
        DB     lsb(outPort_)    ;be    \>  ( val port -- )
        DB     lsb(aNop_)       ;bf    \?
        DB     lsb(cFetch_)     ;c0    \@      byte fetch

        REPDAT 26, lsb(aNop_)

        LITDAT 6
        DB     lsb(cArrDef_)    ;db     \[
        DB     lsb(comment_)    ;dc     \\  comment text, skips reading until end of line
        DB     lsb(aNop_)       ;dd     \]
        DB     lsb(go_)         ;de     \^  ( -- ? ) execute mint definition a is address of mint code
        DB     lsb(eret_)       ;       \_  ( b -- ) conditional early return - stop everything           
        DB     lsb(strDef_)     ;e0     \`  ( -- adr ) defines a string \` string ` then use \. to prt            

        REPDAT 8, lsb(altVar_)  ;e1	\a...\h

        LITDAT 2
        DB     lsb(i_)          ;e9    i  ; returns index variable of current loop          
        DB     lsb(j_)          ;e9    j  ; returns index variable of outer loop     \i+6     

        REPDAT 16, lsb(altVar_)		; \k...\z

        LITDAT 5
        DB    lsb(rpop_)        ;       { ( -- n ) pop from MINT return stack 
        DB    lsb(aNop_)        ;                  
        DB    lsb(rpush_)       ;       } ( n -- ) push to return stack           
        DB    lsb(break_)       ;       ~ ( b -- ) conditional break from loop            
        DB    lsb(aNop_)        ;       DEL

        ENDDAT 

etx:                                ;=12
        LD HL,-DSTACK
        ADD HL,SP
        JR NC,etx1
        LD SP,DSTACK
etx1:
        JR interpret

start:
        LD SP,DSTACK		; start of MINT
        CALL init		; setups
        CALL printStr		; prog count to stack, put code line 235 on stack then call print
        .cstr "MINT V1.1\r\n"

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
        ; LD D,0
macro:                          ;=25
        LD (vTIBPtr),BC
        LD HL,ctrlCodes
        ADD A,L			;look up key of macros
        LD L,A
        LD E,(HL)
        LD A,E
        OR A
        JR Z,macro1
        LD D,msb(macros)
        PUSH DE
        call ENTER		;mint go operation and jump to it
        .cstr "\\^"
macro1:
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
        POP DE          	; DE = return address
        LD HL,(vHeapPtr)  	; load heap ptr
        LD (HL),E       	; store lsb
        LD A,(vByteMode)
        INC HL          
        OR A
        JR NZ,compNext1
        LD (HL),D
        INC HL
compNext1:
        LD (vHeapPtr),HL    ; save heap ptr
        JR NEXT

init:                           ;=68
        LD HL,LSTACK
        LD (vLoopSP),HL         ; Loop stack pointer stored in memory
        LD IX,RSTACK
        LD IY,NEXT		; IY provides a faster jump to NEXT
        LD HL,ialtVars
        LD DE,altVars
        LD BC,8 * 2
        LDIR
        
        LD HL,mintData          ; init namespaces to 0 using LDIR
        LD DE,HL
        INC DE
        LD (HL),0
        LD BC,mintDataSize
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

printStr:                       ;=14
        EX (SP),HL		; swap			
        CALL putStr		
        INC HL			; inc past null
        EX (SP),HL		; put it back	
        RET

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
        LD HL,mintData
        ADD A,L
        LD L,A
        LD A,0
        ADC A,H
        LD H,A
        XOR A
        OR E                        ; sets Z flag if A-Z
        RET

printdec:                           ;=36
        LD DE,-10000			; mint ., 5th location of a dev number
        CALL printdec1			; text book method look it up
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
        JP (IY)              
                                 
again_: JP again		; close loop

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
        CALL lookupRef1
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
        INC BC			; store offests into a table of bytes, smaller
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

hex_:   JP hex

key_:
        CALL getchar
        LD H,0
        LD L,A
        PUSH HL
        JP (IY)

mul_:   JP mul      

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
        
        POP DE              ;    
        POP HL              ;      Entry point for INVert
sub2:   
        AND A               ;      Entry point for NEGate
        SBC HL,DE           ; 15t
        PUSH HL             ;    
        JP (IY)             ;   
                                ; 5  
neg_:   
        LD HL, 0    		; NEGate the value on top of stack (2's complement)
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

num_:   JP  num
str_:   JR str                      
arrEnd_:JR arrEnd
def_:   JR def
div_:   JR div
begin_: JR begin

alt_:   

;*******************************************************************
; Page 5 primitive routines 
;*******************************************************************
        ;falls through 
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


str:                                ;=15                      
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

; ********************************************************************
; 16-bit division subroutine.
;
; BC: divisor, DE: dividend, HL: remainder

; *********************************************************************            
; This divides DE by BC, storing the result in DE, remainder in HL
; *********************************************************************

; 1382 cycles
; 35 bytes (reduced from 48)
		

div:                                ;=34
        POP  DE                     ; get first value
        POP  HL                     ; get 2nd value
        PUSH BC                     ; Preserve the IP
        LD B,H                      ; BC = 2nd value
        LD C,L		
		
        LD HL,0    	            ; Zero the remainder
        LD A,16    	            ; Loop counter

div1:		                    ;shift the bits from BC (numerator) into HL (accumulator)
        SLA C
        RL B
        ADC HL,HL

        SBC HL,DE		    ;Check if remainder >= denominator (HL>=DE)
        JR C,div2
        INC C
        JR div3
div2:		                    ; remainder is not >= denominator, so we have to add DE back to HL
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

depth_:
        LD HL,0
        ADD HL,SP
        EX DE,HL
        LD HL,DSTACK
        OR A
        SBC HL,DE
        JP shr1

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

prnStr_:
prnStr:
        POP HL
        CALL putStr
        JP (IY)


rpush_:
        POP HL
        CALL rpush
        JP (IY)

rpop_:
        CALL rpop
        PUSH HL
        JP (IY)

aDup_:
        JP dup_
eret_:
        POP HL
        LD A,L
        OR H
        JP NZ,ret_
        JP (IY)

strDef_:
        JR strDef

unloop_:                        ;=  ( n -- ) unloop  loop frames (n < 64)
        POP DE                  ; DE = num frames              
        SLA E                   ; E' = E * 2
        LD A,E                  ; A = E'
        SLA E                   ; E'' = E' * 2
        ADD A,E                 ; A = num frames * 6 
        LD E,A                  ; D = 0, DE = num frames * 6
        LD HL,(vLoopSP)         ; HL = loop stack ptr
        ADD HL,DE               ; pop frames
        LD (vLoopSP),HL
        JP (IY)

; **************************************************************************
; utilTable and util_ MUST be on the same page, assumes same msb  
; **************************************************************************
			    								;\#1... for machine code
utilTable:
        DB lsb(exec_)       ;\#0    ( adr -- )    if not null execute code at adr
        DB lsb(eret_)       ;\#1    ( b -- )      conditional early return  
        DB lsb(unloop_)     ;\#2    ( n -- )      pop n loop frames from loop stack
        DB lsb(depth_)      ;\#3    ( -- val )    depth of data stack  
        DB lsb(printStk_)   ;\#4    ( -- )        non-destructively prints stack
        DB lsb(prompt_)     ;\#5    ( -- )        print MINT prompt 
        DB lsb(editDef_)    ;\#6    ( char -- )   edit command    
        DB lsb(aDup_)       ;\#7    ( adr -- )    dupe (used in asm tests)

util_:
util:                           ;= 13
        INC BC
        LD A,(BC)
        SUB "0"
        LD L,lsb(utilTable)     ; H already contains msb(page6)
        ADD A,L
        LD L,A
        LD L,(HL)               ; H already contains msb(page6)
        JP (HL)

printStk_:

; **************************************************************************
; Page 6 primitive routines continued  (page 7) 
; **************************************************************************
        ; falls through to following page
        
printStk:                           ;=40
        ; MINT: \a@2- \#3 1- ("@ \b@ \(,)(.) 2-) '             
        call ENTER
        .cstr "`=> `\\a@2-\\#3 1-(",$22,"@\\b@(,)(.)2-)'\\$"             
        JP (IY)

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

;*******************************************************************
; Page 5 primitive routines continued
;*******************************************************************

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
		POP BC			    ; Restore the IP
		PUSH HL                     ; Put the product on the stack - stack bug fixed 2/12/21
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
        PUSH HL                     ; Put the number on the stack
        JP (IY)                     ; and process the next character

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

prompt:                             ;=9
        call printStr
        .cstr "\r\n> "
        RET

putStr0:
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
writeChar:                          ;=5
        LD (HL),A
        INC HL
        JP putchar

crlf:                               ;=7
        call printStr
        .cstr "\r\n"
        RET

