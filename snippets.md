
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

    .engine mycomputer

    .include "constants.asm"
    .include "IOSerial.asm"
    
    LD SP,DSTACK
    CALL init
    JP testsStart
    
    .include "MINT.asm"
    .include "ram.asm"
    .include "test.util.mac.asm"
    .include "test.array.mac.asm"
    .include "test.tester.mac.asm"
    
    .org $4000
    
    testsStart:
    
    CALL enter
    utilDefs
    arrayDefs
    
    tester "[1 2 3 4 5 6] \\:2/$ '; F H", "[1 3 5] H"
    tester "0 [1 4 3 6 2] \\:'1+; R", "5"
    tester "0 [1 4 3 6 2] \\:+; R", "16"
    tester "1 [1 4 3 6 2] \\:%%>\\(')($ '); R", "6"
    tester "1 [1 4 3 6 2] \\:%%<\\(')($ '); R", "1"
    tester "[1 2 3] \\:{; M H", "[2 4 6] H"

    .cstr "`Done!`"
    HALT
    
.macro arrayDefs
    DB ":R \\f! $\\a! $\\v! (\\v@ %@ \\f@\\^ \\v! 2+) ' \\v@;"   ; v0 arr len fun -- val     reduce array
    DB ":R \\f!~\\v! (\\v@ %@ \\f@\\^ \\v! 2+) ' \\v@;"   ; v0 arr len fun -- val     reduce array

    DB ":R \\f! ( $%@ \\f@\\^ $ 2+) ' ;"    ; v0 arr len fun -- val     reduce array

    DB ":M \\f! \\h@~~ "                    ; arr len fun -- arr' len'  map array
    DB     "(Q@"
    DB     "\\f@\\^ W 2+"
    DB     ")" 
    DB "' \\h@ % -};"

    DB ":F \\f! \\h@ ~~ "
    DB     "(Q@Q " 
    DB     "\\f@\\^ "
    DB     "\\(W)(') 2+ "
    DB     ")"
    DB " '  \\h@ % -};"
.endm


    .engine mycomputer

    .include "constants.asm"
    .include "IOSerial.asm"
    
    LD SP,DSTACK
    CALL init
    JP testsStart
    
    .include "MINT.asm"
    .include "ram.asm"
    .include "test.util.mac.asm"
    ; .include "test.co.mac.asm"
    .include "test.tester.mac.asm"
    
    .org $4000
    
    testsStart:
    
    CALL enter
    utilDefs

    ; does not work with loop frames on RSTACK
    ; does not work with loop stack because 2 loops exist at the same time
    ; because of coroutines

    DB ":F \\{ \\{ \\{ $~ \\} ;"        ; -- val    2rfrom 2r>
    DB ":T $ \\{ $ \\} $ \\} \\} ;"     ; val --    2tor 2>r
    DB ":Y F $ T ;"

    DB ":P 100+ Y 1000() P;"            ; endless loop
    DB ":C P 50( \\#7. Y ) \\{ ;"
    DB "C `done`\\$"

    .cstr "`Done!`"
    HALT
    
.macro coDefs
    DB ":T $ \\#1 \\#1 ;"     ; val --    2tor 2>r
    DB ":F \\#2 \\#2 $ ;"     ; -- val    2rfrom 2r>

    DB ":Y F $ T ;"
    DB ":P 1_( 100+ Q Y ) ;"        ; endless
    DB ":C \\$ 0 P 1_( Q.\\$ 1000 > \\_ Y ) ' B ;"
.endm

    .engine mycomputer

    .include "constants.asm"
    .include "IOSerial.asm"
    
    LD SP,DSTACK
    CALL init
    JP testsStart
    
    .include "MINT.asm"
    .include "ram.asm"
    .include "test.util.mac.asm"
    .include "test.tester.mac.asm"
    
    .org $4000
    
    testsStart:
    
    CALL enter
    utilDefs

    tester "1 2 3", "1 2 3"
    tester "1Q", "1 1"
    tester "25(\\i@ 2\\> 1 30(Q #40 | 1\\> { #3F & Q0=('1))') #40 1\\>", ""
    tester ":G %%> (')($ '); 5 2 G", "5"
    tester "1", "1"
    tester "#1#12#123#1234", "1 18 291 4660"
    tester "0", "0"
    tester "10", "10"
    tester "#10", "16"
    tester "#FF", "255"
    tester "2 3=", "0"
    tester "3 3=", "1"
    tester "2 3<", "1"
    tester "3 3<", "0"
    tester "3 3>", "0"
    tester "4 3>", "1"
    tester "1 2+", "3"
    tester "123 456+", "579"
    tester "64 128+", "192"
    tester "5 3-", "2"
    tester "-1 2+", "1"
    tester "-1 1+", "0"
    tester "3 5&", "1"
    tester "3 5|", "7"
    tester "1{", "2"
    tester "1}", "0"
    tester "2}", "1"
    tester "1 2 3 ' +", "3"
    tester "2 3*", "6"
    tester "1 2 3+*", "5"
    tester "1 3 Q ++", "7"
    tester "5 2/'", "2"
    tester "3 5$ -", "2"
    tester "1 2 3~''", "2"
    tester "1 2 3~+*", "8"
    tester "5 2/$ '", "1"
    tester "2 3%++", "7"
    tester "10 11 12\\#3$ ' $ ' $ '", "3"
    tester "2a!a@", "2"
    tester "3x! 1 x@+x! x@", "4"
    tester "3x! -1 x@+x! x@", "2"
    tester ":X1; X", "1"
    tester ":A100;A", "100"
    tester ":Aa!; 3A a@", "3"
    tester ":Aa!;:Ba@;4AB", "4"
    tester "\\:2; \\^", "2"
    tester "[]$ '", "0"
    tester "[3]$ '", "1"
    tester "[3]'@", "3"
    tester "[1 2 3]'@", "1"
    tester "[1 2 3]'2+@", "2"
    tester "\\h@[1]''\\h@$-", "2"
    tester "\\h@[1 2 3]''\\h@$-", "6"
    tester "\\[]$ '", "0"
    tester "\\[3]'\\@", "3"
    tester "\\[3]$ '", "1"
    tester "\\[1 2 3]'\\@", "1"
    tester "\\[1 2 3]'1+\\@", "2"
    tester "\\h@\\[1 2 3]''\\h@$-", "3"
    tester "\\h@\\[1]''\\h@$-", "1"
    tester "\\`A`\\@", "65"
    tester "0 0(1+)", "0"
    tester "0 1(1+)", "1"
    tester "0 2(1+)", "2"
    tester "0 1(0(1+))", "0"
    tester "0 1(1(1+))", "1"
    tester "0 2(1(1+))", "2"
    tester "0 2(2(1+))", "4"
    tester "0 1(\\i@+)", "0"
    tester "0 2(\\i@+)", "1"
    tester "0 3(\\i@+)", "3"
    tester "0 2(2(\\i@ \\i6+@ ++))", "4"
    tester "0t! 10(1 t@+t!) t@", "10"
    tester "0(100)(200)", "200"
    tester "1(100)(200)", "100"
    tester "0t! 10(\\i@ 4>\\~ 1 t@+t!) t@", "5"
    tester "0t! [1 2 3] $ a! ( a@ \\i@ {+ @ t@+t! ) t@", "6"

    .cstr "`Done!`"
    HALT
    
.macro tester, test1, expect1
    DB "`.`\\#3\\t!"
    DB " ",test1," "
    DB "K\\#3\\t!"                          ; ( -- hash1 )
    DB " ",expect1," "
    DB "K=0=(\\$`fail: ",test1," expected: "
    DB expect1,"`\\$\\$",0,")"
.endm

