open Ast
open Str

(* Given the information in a comment annotation and a raw string of source,
   returns the the split of everything up to the end of the first
   occurence of the function name given by the annotation.
*)
let split_src (ac: annotated_comment) (src_str: string) : string =
  match ac with
    | AComm(_, (name, _, _), _, _) ->
      try
        let src_len = String.length src_str in
        let name_ind = (search_forward (regexp name) src_str 0) + (String.length name) in
        (String.sub src_str name_ind (src_len - name_ind))
      with
          Not_found -> failwith ("The function name " ^ name ^
                                    " was not found in the source following its annotation")

(* Test whether a comment string looks like an annotation
*)
let is_annot (com: string) : bool =
  try
    let _ = (search_forward (regexp "@fun-info") com 0) in
    true
  with
      Not_found -> (* Printf.printf "Not an annotation : %s\n" com; *) false

(* Invokes the appropriate parser for each program element. Generates
 * an annotation/function pairs when possible.
 *)
let parse_of_program (pelems: program_element list) : program_element list =
  let rec lst_rec (pelems: program_element list) (acc: program_element list) : program_element list =
    begin match pelems with
      | []                               -> List.rev acc
      | (ComStr(com)::SrcStr(src)::rest) ->
        if is_annot com
        then pair_rec com src rest acc
        else lst_rec rest (SrcStr(src)::ComStr(com)::acc)
      | (h::rest)                        -> lst_rec rest (h::acc)
    end
  and
   pair_rec com_str src_str rest acc =
    try
      (* (Printf.printf "com_str: %s\n" com_str); *)
      (* (Printf.printf "src_str: %s\n" src_str); *)
      let (acomm: annotated_comment) =
        Comparser.toplevel Comlexer.token (Lexing.from_string com_str) in
      (* (Printf.printf "Parsed comment: %s" (str_of_annot acomm)); *)
      let srcsplit = split_src acomm src_str in
      let (header, funbody, src_rest) = (Srclexer.funparse (Lexing.from_string srcsplit)) in
      lst_rec rest (SrcStr(src_rest) :: AFun (acomm, header, funbody) :: acc)
    with Parsing.Parse_error ->
      (Printf.printf "A parsing error occured parsing the comment: %s\n"
         com_str); []
      | Failure(s) ->
        (Printf.printf "A failure error occured parsing the comment: %s: %s\n" 
           s com_str);
        (* we may have run out of src in case a nested comment appeared within
           a function body. *)
        match rest with
          | (ComStr(com)::e::lrest) ->
            pair_rec com_str (src_str ^ "/*" ^ com ^ "*/" ^ (str_from_elem e)) lrest acc
          | _ -> failwith "Internal parser error: contiguous source strings."
  in
  lst_rec pelems []

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
