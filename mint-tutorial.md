Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice


# A MINT Tutorial (Updated for MINT Version 2.0)

MINT (Minimal Interpreter) is an **interactive**, stack-based programming language designed for simplicity, efficiency, and ease of use on resource-constrained systems like the Z80 microprocessor. This tutorial introduces you to the updated syntax and features of MINT Version 2.0.

---

## Table of Contents

- [Introduction to MINT](#introduction-to-mint)
- [Getting Started](#getting-started)
- [Numbers and Arithmetic](#numbers-and-arithmetic)
- [Stack Manipulation](#stack-manipulation)
- [Variables and Memory](#variables-and-memory)
- [Arrays](#arrays)
- [Control Structures](#control-structures)
- [Functions and Definitions](#functions-and-definitions)
- [Input and Output](#input-and-output)
- [Comments and Documentation](#comments-and-documentation)
- [Programming Style in MINT](#programming-style-in-mint)
- [Glossary of Commands](#glossary-of-commands)

---

## Introduction to MINT

MINT is a minimalist, interactive programming language that uses **Reverse Polish Notation (RPN)** and a stack-based architecture. It is particularly suitable for systems with limited resources, such as the Z80 microprocessor. MINT focuses on:

- **Interactivity**: You can type commands directly and see immediate results.
- **Conciseness**: Programs are compact, using concise syntax and commands.
- **Efficiency**: Designed to perform well even on limited hardware.

---

## Getting Started

When you start the MINT interpreter, you'll see a prompt:

```
MINT v2.0

>
```

You can now enter MINT commands directly at the prompt. MINT processes input line by line, executing commands when you press **Enter**.

---

## Numbers and Arithmetic

### Entering Numbers

MINT supports both **decimal** and **hexadecimal** numbers:

- **Decimal Numbers**: Entered as usual (e.g., `42`, `-15`).
- **Hexadecimal Numbers**: Prefixed with `#` (e.g., `#1F`, `#FFEE`).

### Basic Arithmetic Operations

MINT uses RPN, so operators come **after** their operands:

- **Addition (`+`)**:

  ```
  > 2 3 + .
  5
  ```

- **Subtraction (`-`)**:

  ```
  > 10 4 - .
  6
  ```

- **Multiplication (`*`)**:

  ```
  > 7 6 * .
  42
  ```

- **Division (`/`)**:

  ```
  > 20 5 / .
  4
  ```

  Note: MINT uses integer division.

### Printing Numbers

- **Decimal Print (`.`)**: Prints the top of the stack in decimal.

  ```
  > 255 .
  255
  ```

- **Hexadecimal Print (`,`):** Prints the top of the stack in hexadecimal.

  ```
  > 255 ,
  00FF
  ```

---

## Stack Manipulation

The **stack** is central to MINT programming. Here are key stack operations:

- **Duplicate (`"` or `dup`)**: Duplicates the top element.

  ```
  > 5 "
  > . .
  5
  5
  ```

- **Drop (`'` or `drop`)**: Removes the top element.

  ```
  > 10 20 '
  > .
  10
  ```

- **Swap (`$` or `swap`)**: Swaps the top two elements.

  ```
  > 1 2 $
  > . .
  1
  2
  ```

- **Over (`%` or `over`)**: Copies the second element to the top.

  ```
  > 3 4 %
  > . . .
  4
  3
  4
  ```

- **Rotate (`~` or `rot`)**: Rotates the third element to the top.

  ```
  > 1 2 3 ~
  > . . .
  1
  3
  2
  ```

---

## Variables and Memory

### Variables

MINT provides **26 global variables** named `a` to `z`.

- **Store a Value (`!`)**:

  ```
  > 100 x !
  ```

- **Retrieve a Value (simply reference the variable)**:

  ```
  > x .
  100
  ```

- **Example**:

  ```
  > 10 a !
  > 20 b !
  > a b + c !
  > c .
  30
  ```

### Memory Allocation

You can allocate memory on the heap using the `/A` operator:

- **Allocate Memory**:

  ```
  > 1000 /A m !
  ```

  This allocates 1000 bytes and stores the pointer in `m`.

---

## Arrays

### Defining Arrays

- **Word Arrays**:

  ```
  > [ 1 2 3 ] arr !
  ```

- **Byte Arrays** (use `\` to enter byte mode):

  ```
  > \[ 10 20 30 ] byte_arr !
  ```

### Accessing Array Elements

- **Get Element (`?`)**:

  ```
  > arr 2? .
  3
  ```

  Retrieves the element at index 2.

- **Array Size (`/S`)**:

  ```
  > arr /S .
  3
  ```

---

## Control Structures

### Loops

- **Simple Loop**:

  ```
  > 5 ( `Hello` /N )
  Hello
  Hello
  Hello
  Hello
  Hello
  ```

- **Loop with Counter (`/i`)**:

  ```
  > 5 ( /i . )
  0
  1
  2
  3
  4
  ```

- **Unlimited Loop (`/U`)**:

  ```
  > /U ( `Infinite Loop` /N )
  ```

  Use `/W` to break the loop based on a condition.

### Conditionals

- **If-Else Structure**:

  ```
  > x 5 > ( `x is greater than 5` ) /E ( `x is 5 or less` )
  ```

  Executes the first block if the condition is true, else the second block.

---

## Functions and Definitions

### Defining Functions

Functions are defined using `:` and `;`, and stored in uppercase variables `A` to `Z`.

- **Define a Function**:

  ```
  > :S " * ;
  ```

  This function squares the top of the stack.

### Calling Functions

- **Call a Function**:

  ```
  > 4 S .
  16
  ```

### Anonymous Functions

You can define anonymous functions using `:@` and store them in variables.

- **Define and Use an Anonymous Function**:

  ```
  > :@ 1+ ; inc !
  > 5 inc /G .
  6
  ```

  Here, `/G` executes the function at the address stored in `inc`.

---

## Input and Output

### Printing Text

- **Literal Text (` `...` `)**:

  ```
  > `Hello, MINT!` /N
  Hello, MINT!
  ```

### Printing Numbers

- **Decimal (`.`) and Hexadecimal (`,`)**:

  ```
  > 255 .
  255
  > 255 ,
  00FF
  ```

### Reading Input

- **Read a Character (`/K`)**:

  ```
  > /K .     (Waits for input, then prints ASCII code)
  ```

- **Print a Character (`/C`)**:

  ```
  > 65 /C    (Prints 'A')
  A
  ```

---

## Comments and Documentation

Use `//` for comments. MINT ignores everything after `//` on a line.

```
> // This is a comment
> 10 20 + .     // Adds 10 and 20, prints the result
30
```

---

## Programming Style in MINT

- **Keep Functions Short**: Limit functions to a single purpose.
- **Use Meaningful Variable Names**: Although limited to single letters, use consistent conventions.
- **Avoid Deep Nesting**: Simplify code to improve readability.
- **Use Comments**: Document your code for clarity.
- **Factor Repeated Code**: Create functions for repeated operations.

---

## Glossary of Commands

### Arithmetic Operators

| Symbol | Description                       | Stack Effect      |
| ------ | --------------------------------- | ----------------- |
| `+`    | Addition                          | `a b -- (a + b)`  |
| `-`    | Subtraction                       | `a b -- (a - b)`  |
| `*`    | Multiplication                    | `a b -- (a * b)`  |
| `/`    | Division (Integer)                | `a b -- (a / b)`  |
| `{`    | Shift Left (Multiply by 2)        | `a -- (a * 2)`    |
| `}`    | Shift Right (Divide by 2)         | `a -- (a / 2)`    |
| `%`    | Modulo (Remainder)                | `a b -- (a % b)`  |

### Logical and Comparison Operators

| Symbol | Description              | Stack Effect     |
| ------ | ------------------------ | ---------------- |
| `=`    | Equal To                 | `a b -- (a == b)`|
| `>`    | Greater Than             | `a b -- (a > b)` |
| `<`    | Less Than                | `a b -- (a < b)` |
| `&`    | Bitwise AND              | `a b -- (a & b)` |
| `|`    | Bitwise OR               | `a b -- (a | b)` |
| `^`    | Bitwise XOR              | `a b -- (a ^ b)` |
| `~`    | Bitwise NOT              | `a -- (~a)`      |

### Stack Manipulation

| Symbol | Description        | Stack Effect               |
| ------ | ------------------ | -------------------------- |
| `"`    | Duplicate (`dup`)  | `a -- a a`                 |
| `'`    | Drop (`drop`)      | `a --`                     |
| `$`    | Swap (`swap`)      | `a b -- b a`               |
| `%`    | Over (`over`)      | `a b -- a b a`             |
| `~`    | Rotate (`rot`)     | `a b c -- b c a`           |
| `/D`   | Stack Depth        | `-- depth`                 |

### Variables and Memory

| Symbol | Description              | Stack Effect       |
| ------ | ------------------------ | ------------------ |
| `!`    | Store Value              | `value var --`     |
| `@`    | Fetch Value              | `var -- value`     |
| `/A`   | Allocate Memory          | `size -- address`  |

### Arrays

| Symbol | Description              | Stack Effect            |
| ------ | ------------------------ | ----------------------- |
| `[`    | Begin Array Definition   | `--`                    |
| `]`    | End Array Definition     | `-- address`            |
| `?`    | Get Array Element        | `array index -- value`  |
| `/S`   | Get Array Size           | `array -- size`         |
| `\`    | Enter Byte Mode          | `--`                    |
| `\?`   | Get Byte Array Element   | `array index -- value`  |

### Control Structures

| Symbol | Description           | Stack Effect       |
| ------ | --------------------- | ------------------ |
| `(`    | Begin Loop/Conditional| `n --`             |
| `)`    | End Loop/Conditional  | `--`               |
| `/E`   | Else Condition        | `--`               |
| `/W`   | While Loop Control    | `condition --`     |
| `/U`   | Unlimited Loop        | `--`               |
| `/F`   | False Constant (`0`)  | `-- 0`             |
| `/T`   | True Constant (`1`)   | `-- 1`             |
| `/i`   | Loop Counter          | `-- counter`       |
| `/j`   | Outer Loop Counter    | `-- counter`       |

### Functions

| Symbol | Description                    | Stack Effect       |
| ------ | ------------------------------ | ------------------ |
| `:`    | Begin Function Definition      | `--`               |
| `;`    | End Function Definition        | `--`               |
| `:@`   | Begin Anonymous Function       | `-- address`       |
| `/G`   | Execute Function at Address    | `address --`       |

### Input and Output

| Symbol | Description                    | Stack Effect       |
| ------ | ------------------------------ | ------------------ |
| `.`    | Print Decimal                  | `value --`         |
| `,`    | Print Hexadecimal              | `value --`         |
| `` ` ``| Print Literal String           | `--`               |
| `/N`   | Newline                        | `--`               |
| `/C`   | Print Character                | `value --`         |
| `/K`   | Read Character                 | `-- value`         |

### System Variables

| Symbol | Description              | Stack Effect       |
| ------ | ------------------------ | ------------------ |
| `/c`   | Carry Variable           | `-- value`         |
| `/h`   | Heap Pointer             | `-- address`       |
| `/r`   | Remainder/Overflow       | `-- value`         |

---

## Comments and Documentation

- **Single-Line Comments (`//`)**:

  ```
  > // This is a comment
  ```

- **Inline Comments**:

  ```
  > 10 20 + .     // Adds 10 and 20
  30
  ```

---

## Programming Style in MINT

- **Use Descriptive Names**: Even with single-letter variables, be consistent (e.g., `n` for counts).
- **Factor Code**: Break repetitive code into functions.
- **Comment Generously**: Explain complex logic.
- **Keep Functions Focused**: Each function should perform a single task.

---

 
