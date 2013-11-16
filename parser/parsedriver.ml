open Ast
open Str

(* Given the information in a comment annotation and a raw string of source,
   returns a split of everything up to the end of the first occurence of the
   function name given by the annotation. *)
let split_src (ac: annotated_comment) (src_str: string) : string =
  match ac with
    | AComm(_, (name, _, _), _, _) ->
      try
        let name_ind = (search_forward (regexp name) src_str 0) + (String.length name) in
        String.sub src_str name_ind ((String.length src_str) - name_ind)
      with
          Not_found -> failwith ("The function name " ^ name ^
                                    " was not found in the source following its annotation")

(* Invokes the appropriate parser for each program element. Generates
 * an annotation/function pairs when possible.
 *)
let rec parse_of_program (pelems: program_element list) : program_element list =
  let pair_rec com_str src_str rest =
    try
      (* (Printf.printf "com_str: %s\n" com_str); *)
      let (acomm: annotated_comment) =
        Comparser.toplevel Comlexer.token (Lexing.from_string com_str) in
      (* (Printf.printf "Parsed comment: %s" (str_of_annot acomm));
      (Printf.printf "src_str: %s\n" src_str); *)
      let srcsplit = split_src acomm src_str in
      let funbody = Srclexer.funparse (Lexing.from_string srcsplit) in
      AFun (acomm, funbody) :: (parse_of_program rest)
    with Parsing.Parse_error ->
      (Printf.printf "A parsing error occured parsing the comment: %s\n"
         com_str);
      parse_of_program rest
  in
  begin match pelems with
    | []                                 -> []
    | ( ComStr(com)::SrcStr(src)::rest ) -> pair_rec com src rest
    | ( h::rest )                        -> h :: (parse_of_program rest)
  end

(* Primary entry point for the parser *)
let parse (fname: string) (buf: Lexing.lexbuf) : program_element list =
  try
    Lexutil.reset_lexbuf fname buf;
    let prog_prelex = Prelex.prog_elements [] buf in
    parse_of_program prog_prelex
  with Parsing.Parse_error ->
    failwith (Printf.sprintf "Parse error at %s."
        (Range.string_of_range (Lexutil.lex_range buf)))

let parse_file (fname: string) (ic: in_channel) : sourceUnderTest =
  try
    let buf = Lexing.from_channel ic in
    Printf.printf "Parsing %s ... \n" fname;
    let parsed_program = parse fname buf in
    { file_name = fname;
      elements = parsed_program }
  with
    | Lexutil.Lexer_error (r,m) ->
      failwith (Printf.sprintf "Lexing error at %s: %s."
                  (Range.string_of_range r) m)
