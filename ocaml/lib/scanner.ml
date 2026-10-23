open Lexer

module Scanner : sig
    val scan_tokens : string -> Token.t list
end = struct
    let scan_token source : Token.t * string =
        failwith "TODO"
    let scan_tokens source : Token.t list =
        let rec aux src l =
            failwith "TODO"
        in
        aux source 1
end

