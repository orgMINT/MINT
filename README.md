# MINT Language 2.0

MINT is a minimalist character-based interpreter but one which aims at fast performance, readability and ease of use. It is written for the Z80 microprocessor and is 2K.

- [What is MINT?](#what-is-mint)
- [Reverse Polish Notation (RPN)](<#reverse-polish-notation-(rpn)>)
- [Numbers in MINT](#numbers-in-mint)
  - [Decimal numbers](#decimal-numbers)
  - [Hexadecimal numbers](#hexadecimal-numbers)
  - [Formatting numbers](#formatting-numbers)
- [Printing](#printing)
  - [Printing numbers](#printing-numbers)
  - [Printing text](#printing-text)
- [Stack Manipulation in MINT](#stack-maniplation-in-mint)
  - [Duplicate](#duplicate)
  - [Drop](#drop)
  - [Swap](#swap)
  - [Over](#over)
  - [Rotate](#rotate)
- [Basic arithmetic operations](#basic-arithmetic-operations)
- [Logical operators](#logical-operators)
- [Variables](#variables)
- [Arrays](#arrays)
  - [Basic arrays](#basic-arrays)
  - [Array size](#array-size)
  - [Nested arrays](#nested-arrays)
  - [Byte arrays](#byte-arrays)
  - [Memory allocation](#memory-allocation)
- [Loops](#loops)
- [Conditional code](#conditional-code)
- [Functions in MINT](#functions-in-mint)
  - [Function with multiple arguments](#function-with-multiple-arguments)
  - [Calling functions](#calling-functions)
  - [Using functions](#using-functions)
  - [Anonymous functions](#anonymous-functions)
- [Appendices](#appendices)
  - [Using MINT on the TEC-1](#using-mint-on-the-tec-1)
  - [List of operators](#list-of-operators)
  - [Maths Operators](#maths-operators)
  - [Logical Operators](#logical-operators-1)
  - [Stack Operations](#stack-operations)
  - [Input & Output Operations](#input-&-output-operations)
  - [Functions](#functions)
  - [Loops and conditional execution](#loops-and-conditional-execution)
  - [Memory and Variable Operations](#memory-and-variable-operations)
  - [Array Operations](#array-operations)
  - [Byte Mode Operations](#byte-mode)
  - [System variables](#system-variables)
  - [Miscellaneous](#miscellaneous)
  - [Utility commands](#utility-commands)
  - [Control keys](#control-keys)

## <a name='what-is-mint'></a>What is MINT?

MINT is a bytecode interpreter - this means that all of its instructions are 1 byte long. However,
the choice of instruction uses printable ASCII characters, as a human readable alternative to assembly
language. The interpreter handles 16-bit integers and addresses which is sufficient for small applications
running on an 8-bit cpu.

## <a name='reverse-polish-notation-(rpn)'></a>Reverse Polish Notation (RPN)

RPN is a [concatenative](https:/concatenative.org/wiki/view/Concatenative%20language)
way of writing expressions in which the operators come after their operands. Concatenative
languages make use of a stack which is uses to collect data to do work on. The results
are pushed back on the stack.

Here is an example of a simple MINT program that uses RPN:

```
10 20 + .
```

As the interpreter encounters numbers it pushes them on to the stack. Then it encounters the
`+` operator which is uses to add the two items on the stack and pushes the result back on the stack.
The result becomes the data for the `.` operator which prints the number to the console.

## <a name='numbers-in-mint'></a>Numbers in MINT

MINT on the Z80 uses 16-bit integers to represent numbers. A valid (but not very
interesting) MINT program can be simply a sequence of numbers. Nothing will happen
to them though until the program encounters an operator.

There are two main types of numbers in MINT: decimal numbers and hexadecimal numbers.

### <a name='decimal-numbers'></a>Decimal numbers

Decimal numbers are represented in MINT in the same way that they are represented
in most other programming languages. For example, the number `12345` is represented
as `12345`. A negative number is preceded by a `-` as in `-786`.

### <a name='hexadecimal-numbers'></a>Hexadecimal numbers

Hexadecimal numbers are represented in MINT using the uppercase letters `A` to `F`
to represent the digits `10` to `15`. Hexadecimal numbers are prefixed with a `#`.
So for example, the hexadecimal number `1F3A` is represented as `#1F3A`.
Unlike decimal numbers, hexadecimal numbers are assumed to be positive in MINT.

## <a name='printing'></a>Printing

### <a name='printing-numbers'></a>Printing numbers

MINT provides commands for printing numbers in decimal and hexadecimal format.

The `.` operator prints numbers to the console in decimal.
The `,` operator prints numbers to the console in hexadecimal.

### <a name='printing-text'></a>Printing text

MINT allows the user to easily print literal text by using \` quotes.

For example

```
100 x !
`The value of x is ` x .
```

prints `The value of x is 100`

## <a name='stack-maniplation-in-mint'></a>Stack Manipulation in MINT

In MINT, the stack is a central data structure that stores values temporarily.
It's essential to master stack manipulation to write effective code. Let's explore
some fundamental operator that help you manage the stack

### <a name='duplicate'></a>Duplicate

The `"` or "dup" operator _duplicates_ the top element of the stack.

```
10 " . .
```

The code prints `10 10`

### <a name='drop'></a>Drop

The `'` or "drop" removes the top element of the stack.

```
20 30 ' .
```

The code prints `20`

### <a name='swap'></a>Swap

The `$` of "swap" operator exchanges the positions of the top two elements on the stack.

```
40 50 $ . .
```

The code prints `50 40`

### <a name='over'></a>Over

The `%` of "over" operator copies the second element from the top of the stack and
places it on top.

```
60 70 % . . .
```

The code prints `70 60 70`

## <a name='basic-arithmetic-operations'></a>Basic arithmetic operations

```
10 20 + .
```

This program adds `20` from `10` which results in the value `30`
The `.` operator prints the sum.

```
5 4 * .
```

In this program the numbers `5` and `4` are operands to the operator `*` which
multiplies them together. The `.` operator prints the result of the
multiplication.

NOTE: For multiplications that result in a value greater than #FFFF, the `overflow` of the
last multiplication operation is available in the /r system variable.

```
/r .
```

```
10 20 - .
```

This program subtracts `20` from `10` which results in the negative value `-10`
The `.` operator prints the difference.

```
5 4 / .
```

This program divides 5 with 4 prints the result.

The remainder of the last division operation is available in the /r
system variable.

```
/r .
```

## <a name='logical-operators'></a>Logical operators

MINT uses numbers to define boolean values.

- false is represented by the number `0` or `/F`
- true is represented by the number `1` or `/T`

```
3 0 = .
```

prints `0`

```
0 0 = .
```

prints `1`

MINT has a set of bitwise logical operators that can be used to manipulate bits. These operators are:

```
& performs a bitwise AND operation on the two operands.
| performs a bitwise OR operation on the two operands.
^ performs a bitwise XOR operation on the two operands.
{ shifts the bits of the operand to the left by one.
} shifts the bits of the operand to the right by one.
```

The bitwise logical operators can be used to perform a variety of operations on bits, such as:

- Checking if a bit is set or unset.
- Setting or clearing a bit.
- Flipping a bit.
- Counting the number of set bits in a number.

Here is an example of how to use the bitwise logical operators in MINT:

Check if the first bit of the number 10 is set

```
11 1 & ,
```

this will print 0001

Shift 1 three times to the left (i.e. multiple by 8) and then OR 1 with the least significant bit.

```
1 {{{ 1 | ,
```

prints 0009

Shift 1 two times to the left (i.e. multiple by 4) and then XOR #000F and then mask with #000F.

```
1 {{ #F ^ #F & ,
```

prints 000B

## <a name='variables'></a>Variables

Variables are named locations in memory that can store data. MINT has a limited
number of global variables which have single letter names. In MINT a variable can
be referred to by a singer letter from `a` to `z` so there are 26
global variables in MINT. Global variables can be used to store numbers, strings, arrays, blocks, functions etc.

To assign the value `10` to the global variable `x` use the `!` operator.

```
10 x !
```

In this example, the number `10` is assigned to the variable `x`

To access a value in a variable `x`, simply refer to it in your code.
The code below adds `3` to the value stored in variable `x` and then prints it.

```
3 x + .
```

The following code assigns the hexadecimal number `#3FFF` to variable `a`
The second line fetches the value stored in `a` and prints it.

```
#3FFF a !
a .
```

In this longer example, the number 10 is stored in `a` and the number `20` is
stored in `b`. The values in these two variables are then added together and the answer
`30` is stored in `z`. Finally `z` is printed.

```
10 a !
20 b !
a b + z !
z .
```

## <a name='arrays'></a>Arrays

### <a name='basic-arrays'></a>Basic arrays

MINT arrays are a type of data structure that can be used to store a collection of elements. Arrays are indexed, which means that each element in the array has a unique number associated with it. This number is called the index of the element.
In MINT, array indexes start at 0

To create a MINT array, you can use the following syntax:

_[ element1 element2 ... ]_

for example

```
[ 1 2 3 ]
```

Arrays can be assigned to variables just like number values

```
[ 1 2 3 ] a !
```

An array of 16-bit numbers can be defined by enclosing them within square brackets:

```
[ 1 2 3 4 5 6 7 8 9 0 ]
```

Defining an array puts its start address onto the stack

These can then be allocated to a variable, which acts as a pointer to the array in memory

```
[ 1 2 3 4 5 6 7 8 9 0 ] a !
```

To fetch the Nth member of the array, we can create use the index operator `?`

The following prints the item at index 2 (which is 3).

```
[ 1 2 3 ] 2?  .
```

### <a name='array-size'></a>Array size

The size of an array can be determined with the `/S` operator which puts the number
of items in the array on the stack.

The following prints 5 on the console.

```
[ 1 2 3 4 5 ] /S .
```

### <a name='nested-arrays'></a>Nested arrays

In MINT arrays can be nested inside one another.

The following code shows an array with another array as its second item.
This code accesses the second item of the first array with `1?`. It then accesses
the first item of the inner array with `0?` and prints the result (which is 2).

```
[1 [2 3]] 1?  0?  .
```

### <a name='byte-arrays'></a>Byte arrays

MINT by default declares arrays of 16 bit words however it is also possible to declare
and array of 8 bit byte values by using `\` which puts MINT into `byte mode`.

```
 \[1 2 3]
```

The size of a byte array can be determined with the `/S` operator.
The following code prints 3.

```
 \[1 2 3] /S .
```

The following prints 2

```
 \[1 2 3] 1\?   .
```

Note: MINT will leave byte mode (and return to normal word mode) after it executes a `]`, `?` or `!`

### <a name='memory-allocation'></a>Memory allocation

The final kind of memory allocation in MINT is the simplest raw memory allocation on the heap.

This type of allocation is similar to arrays of bytes and are created using the `/A` allocation operator.

```
1000 /A
```

This code allocates a 1000 byte block of uninitialized memory and returns a pointer to the start of this block.

## <a name='loops'></a>Loops

Looping in MINT is of the form

```
number (code to execute)
```

The number represents the number of times the code between parentheses will be repeated. If the number is zero then the code will be skipped. If the number
is ten it will be repeated ten times. If the number is -1 then the loop will repeat forever.

```
0(this code will not be executed but skipped)
1(this code will be execute once)
10(this code will execute 10 times)
/F(this code will not be executed but skipped)
/T(this code will be execute once)
/U(this code will be execute forever)
```

This code following prints ten x's.

```
10 (`x`)
```

The following code repeats ten times and adds 1 to the variable `t` each time.
When the loop ends it prints the value of t which is 10.

```
0t! 10( t 1+ t! ) t .
```

MINT provides a special variable `/i` which acts as a loop counter. The counter counts up from zero. Just before the
counter reaches the limit number it terminates.

This prints the numbers 0 to 9.

```
10 ( /i . )
```

Loops can repeat forever by specifying an "unlimited" loop with /U. These can be controlled with the "while" operator `/W`. Passing a false value to /W will terminate the loop.

This code initialises `t` to zero and starts a loop to repeat 10 times.
The code to repeat accesses the `/i` variable and compares it to 4. When `/i` exceeds 4 it breaks the loop.
Otherwise it accesses `t` and adds 1 to it.

Finally when the loop ends it prints the value of t which is 5.

```
0t! /U(/i 4 < /W /i t 1+ t!) t .
```

Loops can be nested and then special `/j` variable is provided to access the counter of the outer loop.

The following has two nested loops with limits of 2. The two counter variables are summed and added to `t`.
When the loop ends `t` prints 4.

```
0t! 2(2(/i /j + t + t! )) t .
```

## <a name='conditional-code'></a>Conditional code

MINT's looping mechanism can also be used to execute code conditionally. In MINT boolean `false` is represented
by 0 or `/F` and `true` is represented by 1 or `/T`.

```
/F(this code will not be executed but skipped)
/T(this code will be execute once)
```

The following tests if `x` is less that 5.

```
3 x!
x 5 < (`true`)
```

The syntax for a MINT IF-THEN-ELSE or "if...else" operator in MINT is and
extension of the loop syntax.

```
boolean (code-block-then) /E (code-block-else)
```

If the condition is true, then code-block-then is executed. Otherwise, code-block-else is executed.

Here is an example of a "if...else" operator in MINT:

```
10 x !
20 y !

x y > ( `x is greater than y` ) /E ( `y is greater than x` )

```

In this example, the variable x is assigned the value 10 and the variable y is assigned the value 20.
The "if...else" operator then checks to see if x is greater than y. If it is, then the string
"x is greater than y" is returned. Otherwise, the string "y is greater than x" is returned.

Here is another example of the "if...else" operator in MINT. This time, instead of creating a string just to print it, the following
code conditionally prints text straight to the console.

```
18 a !

`This person` a 17 > (`can`) /E (`cannot`) `vote`
```

In this example, the variable a is assigned the value 18. The "if...else" operator
then checks to see if age is greater than 17. If it is,
then the text "can" is printed to the console. Otherwise, the string "cannot" is printed.

## <a name='functions-in-mint'></a>Functions in MINT

You can put any code inside `:` and `;` block which tells MINT to "execute this later".

Functions are stored in variables with uppercase letters. There are 26 variables
for storing functions in MINT and use the uppercase letter A to Z.

The following stores a function in the variable `Z`.

```
:Z `hello` 1. 2. 3. ;
```

Running the function by stored in uppercase `Z` by referring to it

```
Z
```

will print out.

```
hello 1 2 3
```

A basic function to square a value.

```
:F " * ;
```

The function stored in F duplicates the value on the stack and then multiplies them together.

```
4 F .
```

Calling the function with 4 returns 16 which is then printed.

### <a name='function-with-multiple-arguments'></a>Function with multiple arguments

You can also define functions with multiple arguments. For example:

```
:F $ . . ;
```

This function swaps the top two arguments on the stack and then prints them using `.`.

### <a name='calling-functions'></a>Calling functions

Functions are called by referring to them

```
:F * ;
30 20 F .
```

This code passes the numbers `30` and `20` to a function which multiplies them and returns
the result which is then printed.

### <a name='using-functions'></a>Using functions

Once you've assigned functions to variables, you can use them in your MINT code.

Example:

```
10 A       / prints 10
3 7 B      / prints 10, the sum of 3 and 7
```

In the first line, we execute the function stored in variable `A` with the argument `10`,
which prints `10`. In the second line, we execute the function stored in variable `B` with
arguments `3` and `7`, which results in `10` being printed (the sum of the two arguments).

### <a name='anonymous-functions'></a>Anonymous functions

MINT code is not restricted to upper case variables. Functions an be declared without a
variable(i.e. anonymously) by using the `::` operator. A function declared this way puts
the address of the function on the stack.

A function at an address can be executed with the `/G` operator.

This code declares an anonymous function and stores its address in `a`. This function will
increment its argument by 1.

The next line pushs the number 3 on the stack and executes the function in `a`.
The function adds 1 and prints 4 to the console.

```
:: 1+ ; a!
3 a /G .
```

Anonymous functions can be stored in arrays and can even be used as a kind of "switch" statement.
This code declares an array containing 3 anonymous functions. The next line accesses the array at
index 2 and runs it. "two" is printed to the console.

```
[:: `zero` ; :: `one` ; :: `two` ;] b!
b 2? /G
```

## <a name='appendices'></a>Appendices

### <a name='using-mint-on-the-tec-1'></a>Using MINT on the TEC-1

MINT was designed for for small Z80 based systems but specifically with the small memory configuration
of the TEC-1 single board computer. It is only 2K to work with the original TEC-1 and interfaces to the
serial interface via a simple adapter.

On initialisation it will present a user prompt ">" followed by a CR and LF. It is now ready to accept
commands from the keyboard.

### <a name='list-of-operators'></a>List of operators

### <a name='maths-operators'></a>Maths Operators

| Symbol | Description                               | Effect   |
| ------ | ----------------------------------------- | -------- |
| -      | 16-bit integer subtraction SUB            | n n -- n |
| /      | 16-bit by 8-bit division DIV              | n n -- n |
| +      | 16-bit integer addition ADD               | n n -- n |
| \*     | 8-bit by 8-bit integer multiplication MUL | n n -- n |

### <a name='logical-operators-1'></a>Logical Operators

| Symbol | Description          | Effect   |
| ------ | -------------------- | -------- |
| >      | 16-bit comparison GT | n n -- b |
| <      | 16-bit comparison LT | n n -- b |
| =      | 16 bit comparison EQ | n n -- b |
| &      | 16-bit bitwise AND   | n n -- b |
| \|     | 16-bit bitwise OR    | n n -- b |
| ^      | 16-bit bitwise XOR   | n n -- b |
| ~      | 16-bit NOT           | n -- n   |
| {      | shift left           | n -- n   |
| }      | shift right          | --       |

### <a name='stack-operations'></a>Stack Operations

| Symbol | Description                                                          | Effect       |
| ------ | -------------------------------------------------------------------- | ------------ |
| '      | drop the top member of the stack DROP                                | m n -- m     |
| "      | duplicate the top member of the stack DUP                            | n -- n n     |
| %      | over - take the 2nd member of the stack and copy to top of the stack | m n -- m n m |
| $      | swap the top 2 members of the stack SWAP                             | m n -- n m   |
| /D     | stack depth                                                          | -- n         |

### <a name='input-&-output-operations'></a>Input & Output Operations

| Symbol | Description                                    | Effect |
| ------ | ---------------------------------------------- | ------ |
| .      | print the number on the stack as a decimal     | n --   |
| ,      | print the number on the stack as a hexadecimal | n --   |
| \`     | print the literal string between \` and \`     | --     |
| /C     | prints a character to output                   | n --   |
| /K     | read a char from input                         | -- n   |
| /O     | output to an I/O port                          | n p -- |
| /I     | input from a I/O port                          | p -- n |

### <a name='functions'></a>Functions

| Symbol | Description                     | Effect |
| ------ | ------------------------------- | ------ |
| ;      | end of user definition END      | --     |
| :      | define a new command DEF        | --     |
| ::     | define an anonymous command DEF | -- a   |
| /G     | execute mint code at address    | a -- ? |
| /X     | execute machine code at address | a -- ? |

### <a name='loops-and-conditional-execution'></a>Loops and conditional execution

| Symbol | Description                            | Effect |
| ------ | -------------------------------------- | ------ |
| (      | BEGIN a loop which will repeat n times | n --   |
| )      | END a loop code block                  | --     |
| /U     | unlimited loop constant                | -- b   |
| /W     | if false break out of loop             | b --   |
| /E     | else condition                         | -- b   |
| /F     | false constant                         | -- b   |
| /T     | true constant                          | -- b   |

### <a name='memory-and-variable-operations'></a>Memory and Variable Operations

| Symbol | Description             | Effect |
| ------ | ----------------------- | ------ |
| a..z   | variable access         | -- n   |
| !      | STORE a value to memory | n a -- |
| /V     | address of last access. | -- a   |

### <a name='array-operations'></a>Array Operations

| Symbol | Description               | Effect   |
| ------ | ------------------------- | -------- |
| [      | begin an array definition | --       |
| ]      | end an array definition   | -- a     |
| ?      | get array item            | a n -- n |
| /S     | array size                | a -- n   |
| /A     | allocate heap memory      | n -- a   |

### <a name='byte-mode'></a>Byte Mode Operations

| Symbol | Description                   | Effect   |
| ------ | ----------------------------- | -------- |
| \\     | put MINT into byte mode       | --       |
| \\!    | STORE a byte to memory        | b a --   |
| \\[    | begin a byte array definition | --       |
| \\?    | get byte array item           | a n -- b |

### <a name='system-variables'></a>System variables

| Symbol | Description                              | Effect |
| ------ | ---------------------------------------- | ------ |
| /c     | carry variable                           | -- n   |
| /h     | heap pointer variable                    | -- a   |
| /i     | loop variable                            | -- n   |
| /j     | outer loop variable                      | -- n   |
| /k     | (internal) offset into text input buffer | -- a   |
| /r     | remainder/overflow of last div/mul       | -- n   |
| /s     | address of start of stack                | -- a   |
| /z     | (internal) name of last defined function | -- c   |

### <a name='miscellaneous'></a>Miscellaneous

| Symbol | Description                                   | Effect |
| ------ | --------------------------------------------- | ------ |
| //     | comment text, skips reading until end of line | --     |

### <a name='utility-commands'></a>Utility commands

| Symbol | Description   | Effect |
| ------ | ------------- | ------ |
| /N     | prints a CRLF | --     |
| /P     | print prompt  | --     |

### <a name='control-keys'></a>Control keys

| Symbol | Description       |
| ------ | ----------------- |
| ^E     | edit a definition |
| ^H     | backspace         |
| ^L     | list definitions  |
| ^R     | re-edit           |
| ^S     | print stack       |


# Appendix

# MINT with machine code, handling interrupts


Let's break this down to make it more understandable, step by step, with an emphasis on integrating MINT with machine code, handling interrupts, and managing the stack correctly.

### Summary of Key Ideas

1. **Machine Code Routine and MINT:**
   John is explaining how you can write a machine code routine that enters the MINT environment (a high-level interpreted language). This routine can execute MINT code (like reading from the 9511 port), handle an interrupt, and then return control back to the machine code.

2. **Software Interrupt (RST 38):**
   The `RST 38` instruction is a software interrupt. It behaves similarly to a hardware interrupt but is triggered manually in code. This is the first step to testing your interrupt handling routine before moving to actual hardware interrupts.

3. **Stack Management in MINT:**
   MINT uses two stacks:
   - **Data Stack:** Used for storing intermediate values.
   - **Return Stack:** Used for storing return addresses when jumping between subroutines.

   When you combine MINT with machine code, you need to carefully manage what's on the stack, especially since MINT's data stack also acts as its program stack. This can get tricky when handling interrupts and returning from routines.

### Step-by-Step Breakdown

1. **Step 1: Test with RST 38 (Software Interrupt)**
   - The first thing John suggests is to write a routine that is triggered by the `RST 38` instruction. This simulates what happens during a hardware interrupt but is controlled by your software.
   
   ```assembly
   RST 38H    ; Trigger interrupt manually
   ; Interrupt service routine at $38 is called
   ```

   This will help you test whether you can handle an interrupt and safely return to your main program.

2. **Step 2: Return from the Interrupt Safely**
   - After the interrupt, you need to ensure you can return to the main machine code routine properly. This involves restoring the program counter (PC) and stack state, making sure nothing is left on the stack that could cause problems later.

   - If MINT leaves something on the stack after an interrupt, you must pop those values off and store them in variables or registers temporarily so that the return address is properly restored.

3. **Step 3: Execute MINT Code in the Interrupt Routine**
   - Once you’ve tested the `RST 38` routine and confirmed it returns safely, the next step is to try running a MINT routine within the interrupt handler.
   
   Example:
   ```forth
   call enter .cstr "3 2 + a !" ret  ; MINT code that adds 3 + 2, stores in 'a', and returns
   ```

   This MINT routine does not return anything on the stack. Instead, it stores the result in a variable (`a`). This keeps the stack clean and simplifies returning from the interrupt.

4. **Step 4: Triggering with a Hardware Interrupt**
   - Once you’ve successfully handled a software interrupt (`RST 38`), you can move to triggering interrupts using hardware. This could involve reading from the 9511 math chip or handling other hardware events.

5. **Handling MINT's Data and Return Stacks in Machine Code**
   - In MINT, the **data stack** doubles as the **program stack** (holding both data and return addresses). For machine code, it’s crucial to keep track of what MINT leaves on the stack when returning from a routine. You may need to pop extra data left on the stack to access the return address.
   
   - The idea is to ensure that the stack is clean when returning to machine code, so it doesn’t crash the program by accidentally jumping to the wrong address.

### What You Need to Do:
1. **Write a test routine triggered by `RST 38`.** This will simulate the interrupt mechanism and help you debug whether you can safely return to your main program.

2. **Execute a MINT routine inside the interrupt handler** that doesn’t return any values on the stack (e.g., `3 2 + a !` to store a result in a variable instead of returning it on the stack).

3. **Ensure stack cleanliness** by managing what’s left on the stack and making sure your return address is accessible.

4. **Move to hardware interrupts** once the software interrupt mechanism works reliably.

### Example Process:

```assembly
; Machine code routine
RST 38H    ; Simulate interrupt
; Jump to ISR at $38
...
; Handle the interrupt, call MINT
...
; Return to machine code
```

In MINT:
```forth
: test-routine 3 2 + a ! ; Simple routine that adds 3 and 2, and stores in 'a'
```

Test the routine in the ISR, ensure no values are left on the stack, and confirm proper return to the main machine code.

Let me know if you need further clarification on any part of this!
