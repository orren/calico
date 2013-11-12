{
  open Lexing
  open Lexutil
}

(* Commonly used regex *)
let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

rule funparse = parse
  | whitespace+        { funparse lexbuf }
  | "("                { parenset 0 lexbuf }
  | _ as c             { unexpected_char lexbuf c "Expected open paren after fun name" }
and parenset depth = parse
  | "("                { parenset (depth + 1) lexbuf }
  | ")"                { if depth = 0
                         then String.concat "" (List.rev (body 0 [] lexbuf))
                         else parenset (depth - 1) lexbuf }
  | _                  { parenset depth lexbuf }
and body depth lst = parse
  | "{"                { body (depth + 1) ("{"::lst) lexbuf }
  | "}"                { if depth = 1
                         then ("}"::lst)
                         else body (depth - 1) ("}"::lst) lexbuf }
  | _                  { body depth ((lexeme lexbuf)::lst) lexbuf }


