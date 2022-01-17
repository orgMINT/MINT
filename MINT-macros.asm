backsp_:
        DB "\\c@0=0=(\\c@1-\\c!`\b \b`);"

reedit_:
        DB "\\e\\@\\#2;"

edit_:
        .cstr "`?`?\\#1\\#2;"

list_:
        .cstr "\\$26(\\i@65+\\#2\\c@0>(\\$))\\#1;"

printStack_:
        .cstr "\\#4\\#1;"        

toggleBase_:
        .cstr "\\b@0=\\b!;"

