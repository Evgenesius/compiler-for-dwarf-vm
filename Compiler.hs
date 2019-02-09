module Main where

import System.Environment

main :: IO ()
main = do
    args <- getArgs
    if length args /= 1 then do
        putStrLn "usage: cdvm <source_file.cdv>"
    else
        let file = head args in do
            content <- readFile file
            putStrLn content
