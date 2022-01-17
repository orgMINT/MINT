
.macro utilDefs
    DB ":Q ",$22,";"                    ; ( n -- n n ) a convenient way to access " 
    DB ":W \\h@! 2\\h@+ \\h!;"              ; ( n -- ) compiles a word to heap
    DB ":K \\#3\\t@- 0$ ($1+^);"         ; ( x1...xn num -- hash )
.endm

.macro arrayDefs
    DB  ":H 0~~ ( $%@ 1+^ $ 2+)';"      ; arr len -- hash           hash array

    DB  ":R \\f! ( $%@ \\f@\\^ $ 2+) ' ;"   ; v0 arr len fun -- val     reduce array

    DB  ":M \\f! \\h@~~ "               ; arr len fun -- arr' len'  map array
    DB      "(Q@"
    DB      "\\f@\\^ W 2+"
    DB      ")" 
    DB  "' \\h@ % -};"

    DB  ":F \\f! \\h@ ~~ "
    DB      "(Q@Q " 
    DB      "\\f@\\^ "
    DB      "\\(W)(') 2+ "
    DB      ")"
    DB  " '  \\h@ % -};"

    DB  ":Z `[ `(Q @.2+)`]` ' ;"            ; arr len --                print array
.endm

.macro tester, test1, expect1
    DB "`.`\\#3\\t!"
    DB " ",test1," "
    DB "K\\#3\\t!"                           ; ( -- hash1 )
    DB " ",expect1," "
    DB "K=0=(\\$`fail: ",test1," expected: "
    DB expect1,"`\\$\\$",0,")"
.endm

