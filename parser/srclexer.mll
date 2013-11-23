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
  | "("                { parenset 0 [] lexbuf }
  | _ as c             { unexpected_char lexbuf c "Expected open paren after fun name" }
and parenset depth lst = parse
  | "("    { parenset (depth + 1) ("("::lst) lexbuf }
  | ")"    { if depth = 0
             then let (header, (bodylist, srcrest)) = (ff [] lexbuf) in
                  (String.concat "" (List.rev (header@(")"::lst@["("]))),
                   String.concat "" (List.rev bodylist),
                   srcrest)
             else parenset (depth - 1) (")"::lst) lexbuf }
  | _      { parenset depth ((lexeme lexbuf)::lst) lexbuf }
and ff lst = parse
  | "{"    { (lst , body 1 ["{"] lexbuf) }
  | _      { ff ((lexeme lexbuf)::lst) lexbuf }
and body depth lst = parse
  | "{"                { body (depth + 1) ("{"::lst) lexbuf }
  | "}"                { if depth = 1
                         then ("}"::lst, rest lexbuf)
                         else body (depth - 1) ("}"::lst) lexbuf }
  | _                  { body depth ((lexeme lexbuf)::lst) lexbuf }
and rest = parse
  | _*                  { lexeme lexbuf }

