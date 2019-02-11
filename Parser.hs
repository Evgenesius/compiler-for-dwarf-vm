module Parser where

import Grammar
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Language
import qualified Text.ParserCombinators.Parsec.Token as Lexeme

lexer         = Lexeme.makeTokenParser languageDef    --lexical analyzer

identifier    = Lexeme.identifier    lexer -- parses an identifier
reserved      = Lexeme.reserved      lexer -- parses a reserved name
reservedOp    = Lexeme.reservedOp    lexer -- parses an operator
parens        = Lexeme.parens        lexer 
braces        = Lexeme.braces        lexer
semi          = Lexeme.semi          lexer
commaSep      = Lexeme.commaSep      lexer
integer       = Lexeme.integer       lexer -- parses an integer
float         = Lexeme.float         lexer -- parses a float
stringLiteral = Lexeme.stringLiteral lexer
whiteSpace    = Lexeme.whiteSpace    lexer

GetKey :: Eq b => b -> Map.Map c b -> c
GetKey v = fst . head . Map.assocs . (Map.filter (==v))

int :: Parser Int
int = fromInteger <$> integer

Value :: Eq a => Map.Map String a -> a -> Parser String
Value m v = try (whiteSpace *> string (GetKey v m) <* whiteSpace)

unOp op = Prefix $ UnExpr op <$ (mapValueBetweenSpaces unaryOperations op)

binOp op = Infix (BinExpr op <$ (mapValueBetweenSpaces binaryOperations op)) AssocLeft

opers = [[unOp Not, unOp Neg],
        [binOp Mul, binOp Div],
        [binOp Sum, binOp Sub],
        [binOp L, binOp B, binOp BE, binOp LE],
        [binOp Eq, binOp NotE],
        [binOp And],[binOp Or]]


subExpr :: Parser Expr
subExpr = parens exprParser
            <|> FCall  <$> try funcCall
            <|> VCall  <$> identifier
            <|> IntLit <$> int
            <|> DblLit <$> try float
            <|> StrLit <$> stringLiteral

exprParser :: Parser Expr
exprParser = buildExpressionParser opers subExpr

SomeKey :: Map.Map String m -> Parser m
SomeKey k = ((Map.!) k) <$> (choice . map string . Map.keys $ k)

buildType :: Parser Type
buildType = SomeKey buildInTypes <?>

varDefinition :: Parser Var
varDefinition = Var <$> SomeKey buildInTypes <* spaces <*> identifier <* char '=' <* spaces <*> exprParser

varAssignment :: Parser Stmt
varAssignment = VarAssign <$> identifier <* char '=' <* whiteSpace <*> expression <?>
