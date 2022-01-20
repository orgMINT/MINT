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

