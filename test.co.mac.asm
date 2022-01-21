.macro coDefs
    DB ":T $ \\#1 \\#1 ;"     ; val --    2tor 2>r
    DB ":F \\#2 \\#2 $ ;"     ; -- val    2rfrom 2r>

    DB ":Y F $ T ;"
    DB ":P 1_( 100+ Q Y ) ;"        ; endless
    DB ":C \\$ 0 P 1_( Q.\\$ 1000 > \\_ Y ) ' B ;"
.endm
