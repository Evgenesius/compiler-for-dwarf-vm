module Grammar where

import qualified Data.Map as Map
import Text.ParserCombinators.Parsec.Language
import Text.ParserCombinators.Parsec
import qualified Text.ParserCombinators.Parsec.Token as Lexeme

data Type = Int | Double | String deriving Show

data Var = Var { varType :: Type, varName :: String} deriving Show

buildInTypes = Map.fromList [("int", Int), ("double", Double), ("string", String)]

data UnaryOperation = Not | Neg deriving (Show, Eq)

unaryOperations :: Map.Map String UnaryOperation
unaryOperations = Map.fromList [("!", Not), ("-", Neg)]

data BinaryOperation = And | Or | Eq | B | L | BE | LE | NotE | Sum | Sub | Mul | Div deriving (Show, Eq)

binaryOperations :: Map.Map String BinaryOperation
binaryOperations = Map.fromList [("and", And), ("or", Or),("==", Eq),
                                 (">", B), ("<", L), (">=", BE),
                                 ("<=", LE), ("!=", NotE),("+", Sum),
                                 ("-", Sub), ("*", Mul), ("/", Div)]

data Func = Func { returnType :: Maybe Type
                 , funcName :: String
                 , args :: [Var]
                 , body :: FuncBody
                 } deriving Show

data FunctionCall = FunctionCall String [Expr] deriving Show

data Expr = IntLit Int
          | DblLit Double
          | StrLit String
          | UnaryExpression UnaryOperation Expr
          | BinaryExpression BinaryOperation Expr Expr
          | FCall FunctionCall
          | VarCall String deriving Show

data Stmt = VarDef Var
          | VarAssign String Expr
          | FuncDef Func
          | If Expr [Stmt] [Stmt]
          | While Expr [Stmt] 
          | FuncCall FunctionCall
          | Return (Maybe Expr) deriving Show

type FuncBody = [Stmt]

type ASTree = [Func]

languageDef =
   emptyDef { Lexeme.identStart      = letter
            , Lexeme.identLetter     = alphaNum
            , Lexeme.reservedNames   = [ 
                                        "int"
                                      , "double"
                                      , "string"
                                      , "if"
                                      , "else"
                                      , "while"
                                      , "return"
                                     
                                      , "void"
                                      ]
            , Lexeme.reservedOpNames = Map.keys binaryOperations ++ Map.keys unaryOperations
                                       
            }


