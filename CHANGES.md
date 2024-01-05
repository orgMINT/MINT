# Changes in v1.1

### Removed or renamed

| Symbol | Description                               | Effect         |         |          |
| ------ | ----------------------------------------- | -------------- | ------- | -------- |
| \\j    | outer loop counter variable               | -- adr         | removed |          |
| \\Q    | quits from Mint interpreter               | --             | removed |          |
| \~     | 16-bit bitwise inversion INV              | a -- b         | removed |          |
| \\B    | if true break out of loop                 | b --           | renamed | now \\\_ |
| \\D    | depth of the stack                        | -- n           | renamed | now \\#3 |
| \\E    | prints a character to output              | val --         | renamed | now \\,  |
| \\G    | execute mint code at address              | adr -- ?       | renamed | now \\^  |
| \\I    | input from a I/O port                     | port -- val    | renamed | now \\<  |
| \\K    | read a char from input                    | -- val         | renamed | now ?    |
| \\N    | prints a CRLF to output                   | --             | renamed | now \\$  |
| \\O    | output to an I/O port                     | val port --    | renamed | now \\>  |
| \\P    | non-destructively prints stack            | --             | renamed | now \\#4 |
| \\R    | rotate the top 2 members of the stack ROT | a b c -- b c a | renamed | now ~    |
| \\X    | execute machine code at address           | adr -- ?       | renamed | now \\#0 |
| \\Z    | edit command                              | n --           | renamed | now \\#6 |

### Stack Operations

| Symbol | Description                               | Effect         |          |         |
| ------ | ----------------------------------------- | -------------- | -------- | ------- |
| ~      | rotate the top 2 members of the stack ROT | a b c -- b c a | new name | was \\R |

### Input & Output Operations

| Symbol | Description                    | Effect      |          |         |
| ------ | ------------------------------ | ----------- | -------- | ------- |
| \\.    | print a null terminated string | adr --      | added    |         |
| \\$    | prints a CRLF to output        | --          | new name | was \\N |
| \\,    | prints a character to output   | val --      | new name | was \\E |
| \\>    | output to an I/O port          | val port -- | new name | was \\O |
| \\<    | input from a I/O port          | port -- val | new name | was \\I |
| ?      | read a char from input         | -- val      | new name | was \\K |

### Miscellaneous

| Symbol | Description                  | Effect   |          |         |
| ------ | ---------------------------- | -------- | -------- | ------- |
| \\^    | execute mint code at address | adr -- ? | new name | was \\X |

### Utility commands

| Symbol | Description                     | Effect   |          |         |
| ------ | ------------------------------- | -------- | -------- | ------- |
| \\#0   | execute machine code at address | adr -- ? | new name | was \\X |
| \\#1   | push to return stack            | val --   | added    |
| \\#2   | pop from return stack           | -- val   | added    |
| \\#3   | depth of stack                  | -- val   | new name | was \\D |
| \\#4   | print stack                     | --       | new name | was \\P |
| \\#5   | print prompt                    | --       | new name | was \\> |
| \\#6   | edit command                    | val --   | new name | was \\Z |

### User Definitions

| Symbol    | Description                 | Effect |          |       |
| --------- | --------------------------- | ------ | -------- | ----- |
| \\:       | define an anonymous command | -- adr |          |       |
| \\?<CHAR> | get the address of the def  | -- adr | new name | was ? |

### Loops and conditional execution

| Symbol | Description               | Effect |          |         |
| ------ | ------------------------- | ------ | -------- | ------- |
| \\\_   | if true break out of loop | b --   | new name | was \\B |

### Memory and Variable Operations

| Symbol | Description               | Effect |       |
| ------ | ------------------------- | ------ | ----- |
| \\`    | begin a string definition | -- adr | added |
