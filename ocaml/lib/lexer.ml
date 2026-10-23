module Token = struct
    type token_type =
        (* single char tokens *)
        | LEFT_PAREN | RIGHT_PAREN | LEFT_BRACE | RIGHT_BRACE | COMMA | DOT | MINUS | PLUS | SEMICOLON | SLASH | STAR

        (* one or two char tokens *)
        | BANG | BANG_EQUAL | EQUAL | EQUAL_EQUAL | GREATER | GREATER_EQUAL | LESS | LESS_EQUAL

        (* literals *)
        | IDENTIFIER | STRING | NUMBER

        (* keywords *)
        | AND | CLASS | ELSE | FALSE | FUN | FOR | IF | NIL | OR | PRINT | RETURN | SUPER | THIS | TRUE | VAR | WHILE

        | EOF

    type literal =
        | String of string
        | Bool of bool
        | Number of float

    type t = {
        typ : token_type;
        lexeme : string;
        literal : literal option;
        line : int;
    }

    let create typ lexeme literal line =
        {
            typ = typ;
            lexeme = lexeme;
            literal = literal;
            line = line;
        }

    let to_string tok =
        (* TODO: fix this *)
        tok.lexeme
end
