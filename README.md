# MINT Language 1.3

MINT is a minimalist character-based interpreter but one which aims at fast performance, readability and ease of use. It is written for the Z80 microprocessor and is 2K.

<!-- vscode-markdown-toc -->

- 1. [Reverse Polish Notation (RPN)](<#reverse-polish-notation-(rpn)>)
- 2. [Numbers in MINT](#numbers-in-mint)
  - 2.1. [Decimal numbers](#decimal-numbers)
  - 2.2. [Hexadecimal numbers](#hexadecimal-numbers)
  - 2.3. [Formatting numbers](#formatting-numbers)
- 3. [Basic arithmetic operations](#basic-arithmetic-operations)
- 4. [Variables and Variable Assignment](#variables-and-variable-assignment)
- 5. [Variable operators](#variable-operators)
- 6. [Strings](#strings)
  - 6.1. [Printing values](#printing-values)
- 7. [Logical operators](#logical-operators)
- 8. [Conditional code](#conditional-code)
- 9. [Functions in MINT](#functions-in-mint)
  - 9.1. [Function with Multiple Arguments](#function-with-multiple-arguments)
  - 9.2. [Calling functions](#calling-functions)
  - 9.3. [Assigning Functions to Variables](#assigning-functions-to-variables)
  - 9.4. [Using Functions](#using-functions)
  - 9.5. [SYSTEM VARIABLES](#system-variables)
  - 9.6. [Using MINT on the TEC-1](#using-mint-on-the-tec-1)
  - 9.7. [Loops](#loops)
- 10. [Arrays](#arrays)
  - 10.1. [List of operators](#list-of-operators)
  - 10.2. [Maths Operators](#maths-operators)
  - 10.3. [Logical Operators](#logical-operators-1)
  - 10.4. [Stack Operations](#stack-operations)
  - 10.5. [Input & Output Operations](#input-&-output-operations)
  - 10.6. [Loops and conditional execution](#loops-and-conditional-execution)
  - 10.7. [Memory and Variable Operations](#memory-and-variable-operations)
  - 10.8. [System Variables](#system-variables-1)
  - 10.9. [Miscellaneous](#miscellaneous)
  - 10.10. [Utility commands](#utility-commands)
  - 10.11. [Control keys](#control-keys)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## 1. <a name='reverse-polish-notation-(rpn)'></a>Reverse Polish Notation (RPN)

RPN is a [concatenative](https://concatenative.org/wiki/view/Concatenative%20language)
way of writing expressions in which the operators come after their operands.
This makes it very easy to evaluate expressions, since the operands are already on the stack.

Here is an example of a simple MINT program that uses RPN:

```
10 20 + .
```

This program pushes the numbers `10` and `20` are operands which are followed by an
operator `+` which adds the two operands together. The result becomes operand for
the `.` operator which prints the sum.

## 2. <a name='numbers-in-mint'></a>Numbers in MINT

MINT on the Z80 uses 16-bit integers to represent numbers. A valid (but not very
interesting) MINT program can be simply a sequence of numbers. Nothing will happen
to them though until the program encounters an operator.

There are two main types of numbers in MINT: decimal numbers and hexadecimal numbers.

### 2.1. <a name='decimal-numbers'></a>Decimal numbers

Decimal numbers are represented in MINT in the same way that they are represented
in most other programming languages. For example, the number `12345` is represented
as `12345`. A negative number is preceded by a `-` as in `-786`.

### 2.2. <a name='hexadecimal-numbers'></a>Hexadecimal numbers

Hexadecimal numbers are represented in MINT using the uppercase letters `A` to `F`
to represent the digits `10` to `15`. Hexadecimal numbers are prefixed with a `#`.
So for example, the hexadecimal number `1F3A` is represented as `#1F3A`.
Unlike decimal numbers, hexadecimal numbers are assumed to be positive in MINT.

### 2.3. <a name='formatting-numbers'></a>Formatting numbers

MINT provides commands for formatting hexadecimal and decimal numbers. The print
operator `.` prints numbers in decimal. The `,` operator prints in hexadecimal.

## 3. <a name='basic-arithmetic-operations'></a>Basic arithmetic operations

```
5 4 * .
```

In this program the numbers `5` and `4` are operands to the operator `*` which
multiplies them together. The `.` operator prints the result of the
multiplication.

```
10 20 - .
```

This program subtracts `20` from `10` which results in the negative value `-10`
The `.` operator prints the difference.

```
5 4 / . .
```

This program divides 5 with 4 prints the remainder and the quotient.

## 4. <a name='variables-and-variable-assignment'></a>Variables and Variable Assignment

Variables are named locations in memory that can store data. MINT has a limited
number of global variables which have single letter names. In MINT a variable can
be referred to by a singer letter from `a` to `z` so there are 26
global variables in MINT. Global variables can be used to store numbers, strings, arrays, blocks, functions etc.

To assign the value `10` to the global variable `x` use the `!` operator.

```
10 x !
```

In this example, the number `10` is assigned to the variable `x`

To access a value in a variable `x`, use the `@` operator.
The code below adds `3` to the value stored in variable `x` and then prints it.

```
3 x@ + .
```

The following code assigns the hexadecimal number `#3FFF` to variable `a`
The second line fetches the value stored in `a` and prints it.

```
#3FFF a !
a@ .
```

In this longer example, the number `10` is stored in `a` and the number `20` is
stored in `b`. The values in these two variables are then added together and the answer
`30` is stored in `z`. Finally `z` is printed.

```
10 a !
20 b !
a@ b@ + z !
z@ .
```

MINT allows the user to easily print literal text by using \` quotes.

For example

```
100 x !
`The value of x is ` x .
```

prints `The value of x is 100`

## 7. <a name='logical-operators'></a>Logical operators

MINT uses numbers to define boolean values.

- false is represented by the number `0`
- true is represented by the number `1`.

```
3 0 = .
```

prints `0`

```
0 0 = .
```

prints `1`

MINT has a set of bitwise logical operators that can be used to manipulate bits. These operators are:

`&` performs a bitwise AND operation on the two operands.
`|` performs a bitwise OR operation on the two operands.
`^` performs a bitwise XOR operation on the two operands.
`{` shifts the bits of the operand to the left by the specified number of positions.
`}` shifts the bits of the operand to the right by the specified number of positions.

The bitwise logical operators can be used to perform a variety of operations on bits, such as:

- Checking if a bit is set or unset.
- Setting or clearing a bit.
- Flipping a bit.
- Counting the number of set bits in a number.

Here is an example of how to use the bitwise logical operators in MINT:

Check if the first bit of the number 10 is set

```
10 & 1 .
```

this will print `1`

Set the fourth bit of the number 10

```
1 {{{ 1 | .
```

prints #0009

Flip the third bit of the number 10

```
1 {{ #0F ^ .
```

prints #000B

## 8. <a name='conditional-code'></a>Conditional code

Code blocks are useful when it comes to conditional code in MINT.

The syntax for a MINT IF-THEN-ELSE or "if...else" operator in MINT is:

```
condition code-block-then code-block-else ?
```

If the condition is true, then code-block-then is evaluated and its value is returned.
Otherwise, code-block-else is evaluated and its value is returned.

Here is an example of a "if...else" operator in MINT:

```
10 x !
20 y !

x@ y@ > ( `x is greater than y` )( `y is greater than x` )

```

In this example, the variable x is assigned the value 10 and the variable y is assigned the value 20. The "if...else" operator then checks to see if x is greater than y. If it is, then the string "x is greater than y" is returned. Otherwise, the string "y is greater than x" is returned. The value of the "if...else" operator is then assigned to the variable z. Finally, the value of z is printed to the console.

Here is another example of the "if...else" operator in MINT. This time, instead of creating a string just to print it, the following
code conditionally prints text straight to the console.

```
18 a !

`This person` a@ 18 > (`can`)(`cannot`) `vote`
```

In this example, the variable a is assigned the value 18. The "if...else" operator
then checks to see if age is greater than or equal to the voting age of 18. If it is,
then the text "can" is printed to the console. Otherwise, the string "cannot" is printed to the console.

## 9. <a name='functions-in-mint'></a>Functions in MINT

You can put any code inside `:` and `;` block which tells MINT to "execute this later".

Functions are stored variables with uppercase letters.

Storing a code block in the variable `Z`.

```
:Z `hello` 1. 2. 3. ;
```

Running the code block by stored in uppercase `Z` by referring to it

```
Z
```

will print out.

```
hello 1 2 3
```

A basic function with a single argument is represented as follows:

```
:F a ! a@ . ;
```

This function takes a single argument `a` and prints its value using the `.` operator.

Example: a function to square a value a

```
:F a ! a@ a@ * ;
```

### 9.1. <a name='function-with-multiple-arguments'></a>Function with Multiple Arguments

You can also define functions with multiple arguments. For example:

```
:F $ . . ;
```

This function swaps the top two arguments on the stack and then prints them using `.`.

### 9.2. <a name='calling-functions'></a>Calling functions

Functions are called by referring to them

```
:F * ;
30 20 F .
```

This code passes the numbers `30` and `20` to a function which multiplies them and returns
the result which is then printed.

### 9.3. <a name='assigning-functions-to-variables'></a>Assigning Functions to Variables

In MINT, you can assign functions to variables just like any other value.
Variables in MINT are limited to a single uppercase or lowercase letter. To
assign a function to a variable, use the `=` operator.

Let's see some examples:

Here's a function to print a number between after a `$` symbol and storing t in variable `A`

```
:A `$` . ;
```

And calling it:

```
100 A
```

The `100` is passed to the function as argument `a`. The function first prints `$` followed by `1001

Here's a function to square a number by duplicating the value on the stack and then multiplying the two numbers. The function is stored in variable S

```
:S " * ;
```

Calling it:

```
4 S .
```

### 9.4. <a name='using-functions'></a>Using Functions

Once you've assigned functions to variables, you can use them in your MINT code.

Example:

```
10 A       // prints 10
3 7 B      // prints 10, the sum of 3 and 7
```

In the first line, we execute the function stored in variable `A` with the argument `10`,
which prints `10`. In the second line, we execute the function stored in variable `B` with
arguments `3` and `7`, which results in `10` being printed (the sum of the two arguments).

### 9.5. <a name='system-variables'></a>SYSTEM VARIABLES

System variables contain values which MINT uses internally but are available for programmatic use. These are the lowercase letters preceded by a \ e.g. \a, \b, \c etc. However MINT only uses a few of these variables so the user may use the other ones as they like.

### 9.6. <a name='using-mint-on-the-tec-1'></a>Using MINT on the TEC-1

MINT was designed for for small Z80 based systems but specifically with the small memory configuration of the TEC-1 single board computer. It is only 2K to work with the original TEC-1 and interfaces to the serial interface via a simple adapter.

On initialisation it will present a user prompt ">" followed by a CR and LF. It is now ready to accept commands from the keyboard.

### 9.7. <a name='loops'></a>Loops

0(this code will not be executed but skipped)
1(this code will be execute once)
10(this code will execute 10 times)

You can use the comparison operators < = and > to compare 2 values and conditionally execute the code between the brackets.

## 10. <a name='arrays'></a>Arrays

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

[1 2 3 4 5 6 7 8 9 0]

Defining an array puts its start address onto the stack

These can then be allocated to a variable, which acts as a pointer to the array in memory

[1 2 3 4 5 6 7 8 9 0] a!

The swap $ is used to get the starting address onto the top of the stack and then store that into the variable a.

To fetch the Nth member of the array, we can create a colon definition N

:N @ $ {+ @. ;

### 10.1. <a name='list-of-operators'></a>List of operators

MINT is a bytecode interpreter - this means that all of its instructions are 1 byte long. However, the choice of instruction uses printable ASCII characters, as a human readable alternative to assembly language. The interpreter handles 16-bit integers and addresses which is sufficient for small applications running on an 8-bit cpu.

### 10.2. <a name='maths-operators'></a>Maths Operators

| Symbol | Description                               | Effect   |
| ------ | ----------------------------------------- | -------- |
| -      | 16-bit integer subtraction SUB            | a b -- c |
| /      | 16-bit by 8-bit division DIV              | a b -- c |
| +      | 16-bit integer addition ADD               | a b -- c |
| \*     | 8-bit by 8-bit integer multiplication MUL | a b -- c |
| \>     | 16-bit comparison GT                      | a b -- c |
| <      | 16-bit comparison LT                      | a b -- c |
| =      | 16 bit comparison EQ                      | a b -- c |
| {      | shift left                                | --       |
| }      | shift right                               | --       |

### 10.3. <a name='logical-operators-1'></a>Logical Operators

| Symbol | Description        | Effect   |
| ------ | ------------------ | -------- |
| \|     | 16-bit bitwise OR  | a b -- c |
| &      | 16-bit bitwise AND | a b -- c |

Note: logical NOT can be achieved with 0=

### 10.4. <a name='stack-operations'></a>Stack Operations

| Symbol | Description                                                          | Effect         |
| ------ | -------------------------------------------------------------------- | -------------- |
| '      | drop the top member of the stack DROP                                | a a -- a       |
| "      | duplicate the top member of the stack DUP                            | a -- a a       |
| ~      | rotate the top 3 members of the stack ROT                            | a b c -- b c a |
| %      | over - take the 2nd member of the stack and copy to top of the stack | a b -- a b a   |
| $      | swap the top 2 members of the stack SWAP                             | a b -- b a     |
| \D     | stack depth                                                          | -- val         |

### 10.5. <a name='input-&-output-operations'></a>Input & Output Operations

| Symbol | Description                                    | Effect      |
| ------ | ---------------------------------------------- | ----------- |
| ?      | read a char from input                         | -- val      |
| .      | print the number on the stack as a decimal     | a --        |
| ,      | print the number on the stack as a hexadecimal | a --        |
| \`     | print the literal string between \` and \`     | --          |
| \\E    | prints a character to output                   | val --      |
| \\O    | output to an I/O port                          | val port -- |
| \\I    | input from a I/O port                          | port -- val |
| #      | the following number is in hexadecimal         | a --        |

| Symbol  | Description                     | Effect   |
| ------- | ------------------------------- | -------- |
| ;       | end of user definition END      |          |
| :<CHAR> | define a new command DEF        |          |
| \\:     | define an anonymous command DEF |          |
| \\G     | execute mint code at address    | adr -- ? |
| \\X     | execute machine code at address | adr -- ? |

NOTE:
<CHAR> is an uppercase letter immediately following operation which is the name of the definition
<NUM> is the namespace number. There are currently 5 namespaces numbered 0 - 4

### 10.6. <a name='loops-and-conditional-execution'></a>Loops and conditional execution

| Symbol | Description                            | Effect |
| ------ | -------------------------------------- | ------ |
| (      | BEGIN a loop which will repeat n times | n --   |
| )      | END a loop code block                  | --     |
| \\B    | if false break out of loop             | b --   |

NOTE 1: a loop with a boolean value for a loop limit (i.e. 0 or 1) is a conditionally executed block of code

e.g. 0(`will not execute`)
1(`will execute`)

NOTE 2: if you _immediately_ follow a code block with another code block, this second code block will execute
if the condition is 0 (i.e. it is an ELSE clause)

e.g. 0(`will not execute`)(`will execute`)
1(`will execute`)(`will not execute`)

### 10.7. <a name='memory-and-variable-operations'></a>Memory and Variable Operations

| Symbol | Description                   | Effect         |
| ------ | ----------------------------- | -------------- |
| !      | STORE a value to memory       | val adr --     |
| @      | FETCH a value from memory     | adr -- val     |
| \\!    | STORE a byte to memory        | val adr --     |
| \\@    | FETCH a byte from memory      | -- val         |
| [      | begin an array definition     | --             |
| ]      | end an array definition       | -- adr         |
| \_     | get address of array item     | adr idx -- adr |
| \\S    | array size                    | adr -- val     |
| \\[    | begin a byte array definition | -- adr         |

### 10.8. <a name='system-variables-1'></a>System Variables

| Symbol | Description                        | Effect |
| ------ | ---------------------------------- | ------ |
| \\a    | data stack start variable          | -- adr |
| \\b    | base16 flag variable               | -- b   |
| \\c    | carry flag variable                | -- adr |
| \\d    | start of user definitions          | -- adr |
| \\h    | heap pointer variable              | -- adr |
| \\i    | loop counter variable              | -- adr |
| \\j    | outer loop counter variable        | -- adr |
| \\t    | text input buffer pointer variable | -- adr |

### 10.9. <a name='miscellaneous'></a>Miscellaneous

| Symbol | Description                                   | Effect |
| ------ | --------------------------------------------- | ------ |
| \\\\   | comment text, skips reading until end of line | --     |

### 10.10. <a name='utility-commands'></a>Utility commands

| Symbol | Description   | Effect |
| ------ | ------------- | ------ |
| \\N    | prints a CRLF | --     |
| \\L    | edit command  | --     |
| \\P    | print prompt  | --     |
| \\T    | print stack   | --     |

### 10.11. <a name='control-keys'></a>Control keys

| Symbol | Description       |
| ------ | ----------------- |
| ^E     | edit a definition |
| ^H     | backspace         |
| ^J     | re-edit           |
| ^L     | list definitions  |
| ^P     | print stack       |
