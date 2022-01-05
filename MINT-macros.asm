empty_:
        DB ";"

backsp_:
        DB "\\c@0=0=(1_\\c\\+`\b \b`);"

reedit_:
        DB "\\e\\@\\Z;"

edit_:
        .cstr "`?`\\K\\>\\Z;"

list_:
        .cstr "\\N26(\\i@\\^A+\\Z\\c@0>(\\N))\\>;"

printStack_:
        .cstr "`=> `\\P\\N\\>;"        

toggleBase_:
        .cstr "\\b@0=\\b!;"

