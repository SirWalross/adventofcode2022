import Data.Bits
import Data.List
import Debug.Trace
import System.Directory.Internal.Prelude
import Data.Set (Set)
import qualified Data.Set as Set

data Position = Position Int Int deriving (Eq, Ord)

instance Show Position where
  show (Position x y) = "(" ++ show x ++ ", " ++ show y ++ ")"

data Blizzard = Blizzard Position Int deriving (Show) -- Position and Direction of blizzard

data Valleymap = Valleymap Int Int Position Position -- width and height of map, position of entrence and exit

instance Show Valleymap where
  show (Valleymap width height entrence exit) = "(Valleymap entrence: " ++ show entrence ++ ", exit: " ++ show exit ++ ")"

-- calc entry or exit position
entry :: (Num b) => String -> b
entry [] = error "empty list"
entry (value : xs)
  | value == '.' = 0
  | otherwise = 1 + entry xs

-- get direction of blizzard
getDirection :: Char -> Int
getDirection char
  | char == '>' = 0
  | char == 'v' = 1
  | char == '<' = 2
  | otherwise = 3

-- offset
offset :: Blizzard -> Int -> Int -> Blizzard
offset (Blizzard (Position x y) direction) width height
  | direction == 0 = Blizzard (Position (if x == width - 2 then 1 else x + 1) y) direction
  | direction == 1 = Blizzard (Position x (if y == height - 2 then 1 else y + 1)) direction
  | direction == 2 = Blizzard (Position (if x == 1 then width - 2 else x - 1) y) direction
  | otherwise = Blizzard (Position x (if y == 1 then height - 2 else y - 1)) direction

-- parse map
parse :: Int -> Int -> [String] -> (Valleymap, [Blizzard])
parse width height lines =
  let blizzards = [Blizzard (Position (i `mod` width) (i `div` width)) (getDirection char) | (char, i) <- zip (intercalate "" lines) [0 ..], char /= '#' && char /= '.']
   in  (Valleymap width height (Position (entry (head lines)) 0) (Position (entry (last lines)) (height - 1)), blizzards)

-- bitwise or list
sumBitwise :: [Integer] -> Integer
sumBitwise [] = 0
sumBitwise [left] = left
sumBitwise (left : right : xs) = sumBitwise $ (.|.) left right : xs

-- calculate first 1000 blizzard states
calculateBlizzards :: Valleymap -> [Blizzard] -> [[Integer]] -> [[Integer]]
calculateBlizzards valleymap@(Valleymap width height _ _) blizzards occupation_maps = 
  let new_blizzards = [offset blizzard width height | blizzard <- blizzards]
      occupation_maps' = occupation_maps ++ [[sumBitwise [1 `shiftL` (x - 1) | (Blizzard (Position x y) _) <- new_blizzards, y == i] | i <- [0 .. (height - 1)]]]
   in (if length occupation_maps' >= 1000 then occupation_maps' else calculateBlizzards valleymap new_blizzards occupation_maps')

-- return possible moves
possibleMoves :: Valleymap -> Position -> [Position]
possibleMoves (Valleymap width height entrence exit) (Position x y)  =
  [Position (x + 1) y | x < width - 2 && y /= 0 && y /= (height - 1)]
    ++ [Position (x - 1) y | x > 1 && y /= 0 && y /= (height - 1)]
    ++ [Position x (y + 1) | y < height - 2 || (Position x (y + 1) == exit)]
    ++ [Position x (y - 1) | y > 1 || (Position x (y - 1) == entrence)]
    ++ [Position x y]

-- calculate wether position is unoccupied
unoccupied :: Position -> [Integer] -> Bool
unoccupied (Position x y) occupation_map = (.&.) (occupation_map !! y) (1 `shiftL` (x - 1)) == 0

-- minimum with no thrown exception
minimum' :: [Int] -> Int
minimum' [] = maxBound :: Int
minimum' xs = minimum xs

fastestRoute :: Valleymap -> [[Integer]] -> Position -> Int -> [Position] -> Int
fastestRoute valleymap occupation_maps goal step_no positions =
  let queue = Set.toList (Set.fromList (concat [[Position x y | (Position x y) <- possibleMoves valleymap player, unoccupied (Position x y) (occupation_maps !! step_no)] | player <- positions]))
      finished = any (\player -> player == goal) queue
   in if finished then step_no else fastestRoute valleymap occupation_maps goal (step_no + 1) queue

main = do
  args <- getArgs
  content <- readFile "input"
  let linesOfFiles = lines content
  let (valleymap@(Valleymap _ _ entrance exit), blizzards) = parse (length $ head linesOfFiles) (length linesOfFiles) linesOfFiles
  let occupation_maps = calculateBlizzards valleymap blizzards []
  let first_round = fastestRoute valleymap occupation_maps exit 0 [entrance] + 1
  let second_round = fastestRoute valleymap occupation_maps entrance (first_round + 1) [exit] + 1
  print $ fastestRoute valleymap occupation_maps exit (second_round + 1) [entrance] + 1