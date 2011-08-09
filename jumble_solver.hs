#! /usr/bin/env runhaskell

import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.List as List
import Data.Maybe
import Data.Char
import Control.Monad
import System.IO
import qualified System.Environment as System.Environment


type SortedToOrigs = Map.Map String (Set.Set String)


main = do
    dictFileNames <- System.Environment.getArgs
    if length dictFileNames == 0
        then putStrLn "usage: jumble_solver.hs DICT_FILE [DICT_FILE] ..."
        else do
            sortedToOrigs <- makeSTO dictFileNames
            putStr "$ "
            hFlush stdout
            content <- getContents
            mapM_ (solveJumble sortedToOrigs) (lines content)
            putStrLn ""


makeSTO :: [FilePath] -> IO SortedToOrigs
makeSTO fileNames = do
    contents <- liftM concat (mapM readFile fileNames)
    let lowerCaseContents = map toLower contents
    return $ foldl
        (\ sortedToOrigs word ->
            Map.insertWith Set.union (List.sort word) (Set.singleton word)
                sortedToOrigs)
        Map.empty (lines lowerCaseContents)


solveJumble :: SortedToOrigs -> String -> IO()
solveJumble sto jumbledWord = do
    let realWords = Map.lookup (List.sort (map toLower jumbledWord)) sto
    if isJust realWords
        then putStr $ unwords (Set.toList (fromJust realWords)) ++ "\n$ "
        else putStr "no anagrams in dictionary\n$ "
    hFlush stdout


