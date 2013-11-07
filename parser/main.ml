open Ast

(* Invokes the appropriate parser for each program element. Generates
 * an annotation/function pairs when possible.
 *)
let rec afuns_of_program (pelems: program_element list) : annotated_fun list =
  let pair_rec com_str src_str rest =
    try
      (Printf.printf "com_str: %s\n" com_str);
      let acomm = Comparser.toplevel Comlexer.token (Lexing.from_string com_str) in
      (Printf.printf "Parsed comment: %s" (str_of_annot acomm));
      (Printf.printf "src_str: %s\n" src_str);
      let fundef = Srcparser.toplevel Srclexer.token (Lexing.from_string src_str) in
      (Printf.printf "Parsed src: %s" fundef);
      AFun (acomm, fundef) :: (afuns_of_program rest)
    with Parsing.Parse_error ->
      (Printf.printf "A parsing error occured\n");
      afuns_of_program rest
  in
  begin match pelems with
    | []     -> []
    | h :: t -> begin match (h, t) with
        | ( ComStr(com), SrcStr(src)::rest ) -> pair_rec com src rest
        | ( _, _::rest )                     -> afuns_of_program t
        | (_, []) -> []
    end
  end

(* invoke the parser top level function using the generated
 * token function available in the lexer to create the
 * token stream.
 *)
let parse (filename: string) (buf: Lexing.lexbuf) : unit =
    (* Lexutil.reset_lexbuf filename buf; *)
    (* Comparser.toplevel Comlexer.token buf *)
  try
    Lexutil.reset_lexbuf filename buf;
    let prog_elements = Prelex.prog_elements [] buf in
    let afuns = afuns_of_program prog_elements in
    (* Printf.printf "Prelex result: \n%s\n" (str_of_prog prog_elements); *)
    Printf.printf "Parse result: \n%s\n" (String.concat "\n" (List.map str_of_afun afuns))
  with Parsing.Parse_error ->
    failwith (Printf.sprintf "Parse error at %s."
        (Range.string_of_range (Lexutil.lex_range buf)))

let parse_file () : unit =
  let fname = "sum_example.c" in
  let ic = open_in fname in
  try
    Printf.printf "Parsing %s ... \n" fname;
    parse fname (Lexing.from_channel ic)
  with
    | Lexutil.Lexer_error (r,m) ->
      failwith (Printf.sprintf "Lexing error at %s: %s."
                  (Range.string_of_range r) m)
;;
parse_file ()
