### Basic interpreter for the [Brainfuck programming language](https://esolangs.org/wiki/Brainfuck) in Haskell


Just run with source file as argument:
```
brainfuck.exe hello_world.b
```

There will be a runtime error if a path is supplied but does not point to an existing file.
Tested on Windows.

```brainfuck
Brainfuck Language Overview

> 	move the pointer to the right
< 	move the pointer to the left
+ 	increment value at the pointer
- 	decrement value at the pointer
. 	output the character at the pointer
, 	input a character and store it in the cell at the pointer
[ 	jump past the matching ] if the value pointer is 0
] 	jump back to the matching [ if the value at pointer is >0
```
