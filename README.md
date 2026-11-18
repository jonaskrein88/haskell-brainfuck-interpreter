### Basic interpreter for the [Brainfuck programming language](https://esolangs.org/wiki/Brainfuck) in Haskell


## usage

Open a text file and execute
```Haskell
import Brainfuck
import Data.Maybe (listToMaybe)
import System.Environment


main :: IO ()
main = getArgs >>= (\args ->
	case listToMaybe args of
		Nothing   -> putStrLn "No filepath provided"
		Just file -> readFile file >>= run_brainfuck)
```

There will be a runtime error if a path is supplied but does not point to an existing file.

## Brainfuck Language Overview
Brainfuck is a Turing-complete esoteric programming language created by Urban Müller in 1993. It uses only eight commands to manipulate an array of memory cells.
```brainfuck
Here are all the valid Brainfuck commands:

> 	move the pointer to the right
< 	move the pointer to the left
+ 	increment value at the pointer
- 	decrement value at the pointer
. 	output the character at the pointer
, 	input a character and store it in the cell at the pointer
[ 	jump past the matching ] if the value pointer is 0
] 	jump back to the matching [ if the value under the pointer is greater than zero
```
