import Data.Word (Word8)
import Data.Maybe (mapMaybe, listToMaybe)
import System.Environment
import System.Exit  
import System.IO (hSetBinaryMode, stdout, stdin, hSetBuffering, BufferMode(NoBuffering))


data Command = MoveLeft
			|MoveRight
			|Increment
			|Decrement
			|Loop_Begin
			|Loop_End
			|Read
			|Write deriving (Show)


data Tape    = Tape [Word8] Word8 [Word8] deriving (Show)
data Program = Program [Command] Command [Command] deriving (Show)




to_instruction :: Char -> Maybe Command
to_instruction '<' = Just MoveLeft
to_instruction '>' = Just MoveRight
to_instruction '+' = Just Increment
to_instruction '-' = Just Decrement
to_instruction '[' = Just Loop_Begin
to_instruction ']' = Just Loop_End
to_instruction ',' = Just Read
to_instruction '.' = Just Write
to_instruction _   = Nothing

parse :: String -> Maybe Program
parse source = 
	let tokens = mapMaybe to_instruction source
	in case tokens of
		[]     -> Nothing
		(x:xs) -> Just $ Program [] x xs


read_program :: String -> IO (Maybe Program)
read_program s = parse <$> readFile s






newTape :: Tape
newTape = Tape [] 0 []

increment :: Tape -> Tape
increment (Tape a x b) = Tape a (x+1) b 

decrement :: Tape -> Tape
decrement (Tape a x b) = Tape a (x-1) b 

move_right :: Tape -> Tape
move_right (Tape left x [])     = Tape (x:left) 0 []
move_right (Tape left x (r:rs)) = Tape (x:left) r rs

move_left :: Tape -> Tape
move_left (Tape [] x right)     = Tape [] 0 (x:right)
move_left (Tape (l:ls) x right) = Tape ls l (x:right)


print_current :: Tape -> IO ()
print_current (Tape _ x _) = putChar (toEnum (fromIntegral x))


charToWord8 :: Char -> Word8
charToWord8 c = fromIntegral (fromEnum c)

get_char :: Tape -> IO Tape
get_char (Tape l _ r) = (\x -> Tape l (charToWord8 x) r) <$> getChar




execute_command :: Program -> Tape -> IO ()
execute_command program@( Program _ Increment _ ) tape    = run_next program $ increment tape  
execute_command program@( Program _ Decrement _ ) tape    = run_next program $ decrement tape  
execute_command program@( Program _ MoveLeft _ ) tape     = run_next program $ move_left tape  
execute_command program@( Program _ MoveRight _ ) tape    = run_next program $ move_right tape  



execute_command program@( Program _ Loop_End _ ) tape@(Tape _ x _ ) | x > 0  = 
	maybe (print "ERROR while finding loop begin") (`run_next` tape) $
	find_loop_begin 0 $ prev_command program

execute_command program@( Program _ Loop_Begin _ ) tape@(Tape _ x _ ) | x == 0 = 
	maybe (print "ERROR while finding end of loop") (`run_next` tape) $
	find_loop_end 0 $ next_command program

execute_command program@( Program _ Loop_Begin _ ) tape   = run_next program tape
execute_command program@( Program _ Write _ ) tape        = print_current tape >> run_next program tape
execute_command program@( Program _ Read _ ) tape         = get_char tape >>= run_next program
execute_command p t = run_next p t 




-- returns programm with moved pointer or Nothing
next_command :: Program -> Maybe Program
next_command (Program _ _ [])      = Nothing
next_command (Program ps x (n:ns)) = Just $ Program (x:ps) n ns


prev_command :: Program -> Maybe Program
prev_command (Program [] _ _)      = Nothing
prev_command (Program (p:ps) x ns) = Just $ Program ps p (x:ns)




find_loop_begin :: Int -> Maybe Program -> Maybe Program
find_loop_begin _ Nothing = Nothing 				
find_loop_begin depth (Just program@( Program _ token _ )) = 
	case token of
		Loop_End   -> find_loop_begin (depth+1) $ prev_command program
		Loop_Begin -> if depth == 0
					then Just program
					else find_loop_begin (depth-1) $ prev_command program
		_          -> find_loop_begin depth $ prev_command program


find_loop_end :: Int -> Maybe Program -> Maybe Program
find_loop_end _ Nothing = Nothing
find_loop_end depth (Just program@( Program _ token _ )) = 
	case token of
		Loop_Begin   -> find_loop_end (depth+1) $ next_command program
		Loop_End -> if depth == 0
					then Just program
					else find_loop_end (depth-1) $ next_command program
		_          -> find_loop_end depth $ next_command program





run_next :: Program -> Tape -> IO ()
run_next program tape =
	let next = next_command program
	in case next of
		Nothing -> pure ()
		--Just p  -> print tape >> execute_command p tape
		Just p  -> execute_command p tape


-- not using do blocks cause on principle
main :: IO ()
main = hSetBuffering stdin NoBuffering
	>> hSetBinaryMode stdout True
	>> hSetBinaryMode stdin True
	>> getArgs >>= (\args ->
	case listToMaybe args of
		Nothing -> putStrLn "No filepath provided"
		Just file -> read_program file 
			-- >>= (\x -> print x >> pure x)   -- printing the tokens for testing
			>>= maybe (putStrLn "No valid Brainf**k code found.") (`execute_command` newTape)
	)
