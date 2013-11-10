{
  open Lexing
  open Lexutil
  open Range
}

(* Commonly used regex *)
let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

let lowercase = ['a'-'z']
let uppercase = ['A'-'Z']
let digit = ['0'-'9']
let alphachar = uppercase | lowercase
let idchar = alphachar | '_' (* start of a legal identifier *)
let ident = idchar (idchar | digit)*

(* Returns a token of type as specified in parser.mly

   Each token carries a Range.t value indicating its
   position in the file.
*)
rule funparse = parse
  | whitespace+        { funparse lexbuf }
  | "("                { Printf.printf "Entering parenset at %d\n" lexbuf.lex_curr_pos;
                         parenset 0 lexbuf }
  | _ as c             { unexpected_char lexbuf c "Expected open paren after fun name" }
and parenset depth = parse
  | "("                { parenset (depth + 1) lexbuf }
  | ")"                { Printf.printf "Closing parenset %d at %d\n" depth lexbuf.lex_curr_pos;
                         if depth = 0
                         then String.concat "" (List.rev (body 0 [] lexbuf))
                         else parenset (depth - 1) lexbuf }
  | _                  { parenset depth lexbuf }
and body depth lst = parse
  | "{"                { body (depth + 1) ("{"::lst) lexbuf }
  | "}"                { Printf.printf "Closing brace set %d at %d\n" depth lexbuf.lex_curr_pos;
                         if depth = 1
                         then ("}"::lst)
                         else body (depth - 1) ("}"::lst) lexbuf }
  | _                  { body depth ((lexeme lexbuf)::lst) lexbuf }


