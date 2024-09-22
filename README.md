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
variable(i.e. anonymously) by using the `:@` operator. A function declared this way puts
the address of the function on the stack.

A function at an address can be executed with the `/G` operator.

This code declares an anonymous function and stores its address in `a`. This function will
increment its argument by 1.

The next line pushs the number 3 on the stack and executes the function in `a`.
The function adds 1 and prints 4 to the console.

```
:@ 1+ ; a!
3 a /G .
```

Anonymous functions can be stored in arrays and can even be used as a kind of "switch" statement.
This code declares an array containing 3 anonymous functions. The next line accesses the array at
index 2 and runs it. "two" is printed to the console.

```
[:@ `zero` ; :@ `one` ; :@ `two` ;] b!
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

| Symbol   | Description                     | Effect |
| -------- | ------------------------------- | ------ |
| :A ... ; | define a new command DEF        | --     |
| :@ ... ; | define an anonymous command DEF | -- a   |
| /G       | execute mint code at address    | a -- ? |
| /X       | execute machine code at address | a -- ? |

where "A" represents any uppcase letter

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

## Algorithm Examples

### 1. Fibonacci Sequence

A loop that prints the first 10 numbers of the Fibonacci sequence.

```
:F n !        // Pop the number of iterations (n) from the stack
0 a ! 1 b !   // Initialize a = 0, b = 1
n (           // Loop n times
  a .         // Print current Fibonacci number
  a b + c !   // c = a + b
  b a !       // a = b
  c b !       // b = c
)
;
```

- **`n !`**: Pops the number of iterations from the stack and assigns it to `n`.
- The loop runs `n` times, printing `a` and updating `a` and `b` in each iteration.

### Example of Calling the Function:

```
10 F  // Print the first 10 Fibonacci numbers
```

### 2. Factorial Function

A recursive function that calculates the factorial of a number.

```
:F
  "           // Duplicate n
  1 >         // Check if n > 1
  (           // If true
    " 1 - F * // n * factorial(n - 1)
  ) /E (      // Else condition wrapped in parentheses
    1         // Return 1
  )
;
5 F .         // Calculate factorial of 5, prints: 120
```

- This function recursively calculates the factorial of a number `n`.
- If `n > 1`, it calls itself with `n - 1` and multiplies `n` by the result.
- If `n` is 1 or less, it returns 1, which is the base case to stop recursion.

### 3. Sieve of Eratosthenes

A simple implementation of the Sieve of Eratosthenes to find prime numbers up to 30.

```
:S l !             // Pop the limit from the stack
2 p !              // Initialize p to 2 (start from the first prime)
l 2 - (            // Loop from 2 to the limit
  /T f !           // Set flag assuming p is prime
  p 2 * l < (      // Loop for multiples of p within the limit
    p i % 0 = (    // If p is divisible by i
      /F f !       // Set flag to false if divisible
    )
  )
  f /T = (         // If the flag is still true, print the prime
    p .
  )
  p 1 + p !        // Increment p
)
;
```

### Explanation:

- **`S l !`**: The limit `l` (e.g., 30) is passed from the stack and stored in `l`.
- **`2 p !`**: The starting number for checking primes is set to `2` (the first prime number).
- **Loop**: The loop iterates over numbers from 2 to `l - 1`.
  - **`/T f !`**: A flag `f` is initially set to true, assuming the number is prime.
  - **Multiples Check**: For each number `p`, another loop checks if `p` is divisible by any number between `2` and `p - 1`. If `p` is divisible by `i` (i.e., `p % i == 0`), the flag `f` is set to false (`/F f !`).
  - **Prime Check**: After checking all divisors, if the flag `f` remains true (`f /T =`), the number `p` is prime and is printed (`p .`).
  - **Increment**: After each iteration, `p` is incremented by 1 (`p 1 + p !`).

### Example of Calling the Function:

```
30 S  // Set the limit to 30 and call the sieve function
```

### 4. Greatest Common Divisor (GCD) using Euclidean Algorithm

This program finds the GCD of two numbers using the Euclidean algorithm.

```
:A b ! a !    // Pop two numbers from the stack in LIFO order (b first, then a)
/U (          // Begin an unlimited loop
  b 0 > /W    // Continue while b > 0 (break if b == 0)
  a b % a !   // a = a mod b
  a b !       // Swap: b = old a, repeat
)
a .           // Print the GCD
;
```

- **`/W` as a Loop-While**: The `/W` construct functions as a loop-while, where the loop continues as long as the condition is **true** (non-zero). When the condition becomes **false** (zero), the loop terminates.
- **`b 0 > /W`**: This checks if `b` is greater than 0 at each iteration. The loop continues while `b > 0` and breaks when `b == 0`, completing the Euclidean algorithm.

### Example of Calling the Function:

```
30 20 A       // Calculates the GCD of 30 and 20, prints GCD: 10
```

### Example:

To find the GCD of 30 and 20, you would call the function like this:

```
30 20 A       // Call the GCD function with 30 and 20, prints GCD: 10
```

### 5. Bubble Sort

```
:S l !                         // Store the list passed from the stack into variable l
l /S s !                       // Get the size of the list and store it in s
/T c !                         // Initialize the continue flag (c) to true
/U (                           // Start an unlimited loop for swapping
  c /W                         // Break the loop early if no swaps occurred (c == false)
  s 1 - (                      // Iterate over the list (size - 1 times)
    l i ? x !                  // Store l[i] in x
    l i 1 + ? y !              // Store l[i+1] in y
    x y > (                    // Compare x and y (l[i] and l[i+1])
      y l i !                  // Move y (l[i+1]) to l[i]
      x l i 1 + !              // Move x (l[i]) to l[i+1]
      /F c !                   // Set the continue flag to false (indicating a swap occurred)
    )
  )
)
;
```

- **Temporary Variables**: `x` stores `l[i]` and `y` stores `l[i+1]` to avoid repetition when swapping elements.
- **Continue Flag Initialization**: The continue flag `c` is initialized to **true** (`/T c !`) once at the start before the loop begins.
- **Early Check for Continue Flag**: The loop checks `c /W` early in each pass. If `c == false` (no swaps occurred in the previous pass), the loop terminates early.

### Example of Calling the Function:

```
[5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]
```

### Example of Calling the Function:

```
[5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]
```

### Example of Calling the Function:

```
[5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]
```

### 6. Binary Search

A binary search algorithm that searches for a value in a sorted array.

```
:B h ! l !             // Pop high and low indices from the stack (LIFO order)
l h <= (               // While low <= high
  m l h + 2 / !        // Find the middle index
  m a ? t = (          // If value at m is target
    m .                // Print index
  ) /E (               // Else block for equality wrapped in parentheses
    m a ? t < (        // If target is smaller, search left half
      m 1 - h !
    ) /E (             // Else block for greater condition wrapped
      l m 1 + !
    )
  )
)
;
```

- **`h ! l !`**: Pops the high (`h`) and low (`l`) indices from the stack in the correct LIFO order. When the function is called, you push the high value first, followed by the low value.
- The binary search logic proceeds as normal:
  - **Find the middle**: `m l h + 2 / !` calculates the middle index.
  - **Compare**: If the middle value matches the target, print the index. Otherwise, adjust the search range accordingly (either update `l` or `h`).

### Example of Calling the Function:

```
0 9 B       // Searches in a sorted array from index 0 to 9
```

### 7. Quick Sort

An implementation of the Quick Sort algorithm.

```
:Q s ! l !       // Pop the list and its size from the stack (LIFO order)
l s > 1 (        // If list length is greater than 1
  l p c !        // Choose a pivot element
  l s p p !      // Partition list around pivot
  s Q ! p Q !    // Recursively sort partitions
)
;
```

- **`s ! l !`**: Pops the list `l` and its size `s` from the stack in the correct LIFO order.
- **`l s > 1`**: Checks if the list length is greater than 1 to determine whether sorting is necessary.
- **Recursive Sorting**: It partitions the list around a pivot and recursively sorts both partitions until the base case is reached.

### Example of Calling the Function:

```
[5 3 8 4 2] 5 Q  // Sort the list [5, 3, 8, 4, 2]
```

### 8. Tower of Hanoi

```
:H s ! t ! f ! n !      // Pop the number of disks and rods (source, target, spare) from the stack
n 1 = (                 // If there is only 1 disk
  f t m !               // Move from source to destination
) /E (                  // Else
  n 1 - f t s H !       // Move n-1 disks from source to spare
  f t m !               // Move nth disk to destination
  s t f H !             // Move n-1 disks from spare to destination
)
;
```

- **`s ! t ! f ! n !`**: Pops the number of disks `n`, source rod `f`, target rod `t`, and spare rod `s` from the stack in the correct LIFO order.
- **Recursive Steps**:
  - If there's only 1 disk, it moves directly from the source to the destination.
  - If there are more than 1 disk, it recursively moves `n-1` disks to the spare rod, moves the nth disk to the target, and then moves the `n-1` disks from the spare to the target.

### Example of Calling the Function:

```
3 f t s H .  // Solve Tower of Hanoi for 3 disks
```

### 9. Insertion Sort

An implementation of the insertion sort algorithm.

```
:I l !         // Pop the list from the stack
l /S s !       // Get the size of the list
s 2 > (        // If list has more than 1 element
  s 1 to (     // Loop through the list starting from index 1
    l i ? k !  // Assign key from list element at index i
    i 1 - j !  // Initialize j to i - 1
    j 0 > k l j ? < (  // While j > 0 and key is less than list[j]
      l j 1 + l j !    // Shift elements to the right
      j 1 - j !        // Decrement j
    )
    k l j 1 + !        // Place the key at the correct position
  )
)
;
```

- **`l !`**: Pop the list from the stack.
- **`l /S s !`**: Use `/S` to get the size of the list and store it in `s`.
- **Key and Comparison**: Iterates over the list starting from index 1, compares the current element (`k`) with previous elements, and shifts larger elements to the right until the correct position for `k` is found.

### Example of Calling the Function:

```
[5 3 8 4 2] I  // Sort the list [5, 3, 8, 4, 2]
```

### 10. Dijkstra's Algorithm (Shortest Path)

An implementation of Dijkstra's algorithm to find the shortest path in a graph.

```
:N g !           // Pop the graph from the stack
  u 0 !          // Initialize u (index) to 0
  g /S (         // Loop over all nodes in the graph
    u g ? d < (  // If the node at index u has a smaller distance
      u g !      // Update u to be the new minimum
    )
    u 1 + u !    // Increment u
  )
  u !            // Return the index of the minimum distance node
;

:D g ! s ! d !   // Pop the graph, start node, and distances from the stack
  d ! v /F !     // Initialize distances and visited nodes
  g /S (         // Loop over all nodes in the graph
    N m !        // Get the minimum distance node using N
    m u !        // Update distances of neighboring nodes
  )
  d .            // Print the shortest path
;
```

### Example of Calling the Function:

```
[ 0 7 9 0 0 14 0 0 10 15 0 11 0 6 ] g !  // Graph (Adjacency matrix)
[ 0 999 999 999 999 ] d !               // Distances (start at 0, others infinity)
0 s !                                   // Start node is 0
g s d D                                 // Call Dijkstra's algorithm
```

### Explanation:

- **Graph**: `[ 0 7 9 0 0 14 0 0 10 15 0 11 0 6 ]` represents an adjacency matrix.
- **Distances**: `[ 0 999 999 999 999 ]` represents the distances from the start node to all other nodes, initialized with infinity (or a large value) except the start node (which is 0).
- **Start Node**: `s = 0` sets the start node to 0.
