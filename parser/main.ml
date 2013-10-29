open Ast

(* invoke the parser top level function using the generated
 * token function available in the lexer to create the
 * token stream.
 *)

let parse (filename:string) (buf:Lexing.lexbuf) : unit =
  try
    Lexer.reset_lexbuf filename buf;
    Printf.printf "Prelex result: \n%s\n" (str_of_prog
                                             (Prelex.prog_elements [] buf))
  with Parsing.Parse_error ->
    failwith (Printf.sprintf "Parse error at %s."
        (Range.string_of_range (Lexer.lex_range buf)))

  (* try *)
  (*   Lexer.reset_lexbuf filename buf; *)
  (*   Parser.toplevel Lexer.token buf *)
  (* with Parsing.Parse_error -> *)
  (*   failwith (Printf.sprintf "Parse error at %s." *)
  (*       (Range.string_of_range (Lexer.lex_range buf))) *)

let parse_file () : unit =
  let fname = "sum_example.c" in
  let ic = open_in fname in
  try
    Printf.printf "Parsing %s ... \n" fname;
    parse fname (Lexing.from_channel ic)
    (* let ast = parse fname (Lexing.from_channel ic) in *)
    (* Printf.printf "Parsed: %s\n" (str_of_annot ast); *)
  with
    | Lexer.Lexer_error (r,m) ->
      failwith (Printf.sprintf "Lexing error at %s: %s."
                  (Range.string_of_range r) m)
;;
parse_file ()
