


import Brainfuck
import Data.Maybe (mapMaybe, listToMaybe)
import System.Environment


main :: IO ()
main = getArgs >>= (\args ->
	case listToMaybe args of
		Nothing -> putStrLn "No filepath provided"
		Just file -> readFile file >>= run_brainfuck
	)