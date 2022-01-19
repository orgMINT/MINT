.macro tester, test1, expect1
    DB "`.`\\#3\\t!"
    DB " ",test1," "
    DB "K\\#3\\t!"                          ; ( -- hash1 )
    DB " ",expect1," "
    DB "K=0=(\\$`fail: ",test1," expected: "
    DB expect1,"`\\$\\$",0,")"
.endm
