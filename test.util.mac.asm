.macro utilDefs
    DB ":Q ",$22,";"                        ; ( n -- n n ) a convenient way to access " 
    DB ":W \\h@! 2\\h@+ \\h!;"              ; ( n -- ) compiles a word to heap
    DB ":K \\#3\\t@- 0$ ($1+^);"            ; ( x1...xn num -- hash )
    DB ":H 0~~ ( $%@ 1+^ $ 2+)';"           ; arr len -- hash           hash array
    DB ":Z `[ `(Q @.2+)`]` ' ;"             ; arr len --                print array
.endm


