cstore_     ;a1     \!  byte store     
anonDef_    ;ba     \:  return add of a anon def, \: 1 2 3;    \\ ret add of this                
cFetch_     ;c0     \@  byte fetch
cArrDef_    ;db     \[
comment_    ;dc     \\  comment text, skips reading until end of line

break_      ;       \B \~ ( b -- ) conditional break from loop            
depth_      ;       \D \-  num items on stack
emit_       ;ac     \E \,  ( b -- ) prints a char              
go_         ;de     \G \^  execute mint definition a is address of mint code
inPort_     ;bc     \I \<  ( port -- val )
editDef_    ;a3     \L \#  edit definition 				
newln_      ;a4     \N \$  prints a newline to output	
outPort_    ;be     \O \>  ( val port -- )
prompt_     ;bf     \P \?  print MINT prompt
printStk_   ;       \S \_  non-destructively prints stack       
break_      ;       \W \~ ( b -- ) conditional break from loop            
exec_       ;bb     \X \;  execute machine code              