{
  open Lexing
  open Parser
  open Range
  open Ast

  exception Lexer_error of Range.t * string

  (* Creates a Range.pos from the Lexing.position data *)
  let pos_of_lexpos (p:Lexing.position) : pos =
    mk_pos (p.pos_lnum) (p.pos_cnum - p.pos_bol)

  (* Creates a Range.t from two Lexing.positions *)
  let mk_lex_range (p1:Lexing.position) (p2:Lexing.position) : Range.t =
    mk_range p1.pos_fname (pos_of_lexpos p1) (pos_of_lexpos p2)

  (* Expose the lexer state as a Range.t value *)
  let lex_range lexbuf : Range.t =
    mk_lex_range (lexeme_start_p lexbuf) (lexeme_end_p lexbuf)

  (* Reset the lexer state *)
  let reset_lexbuf (filename:string) lexbuf : unit =
    lexbuf.lex_curr_p <- {
      pos_fname = filename;
      pos_cnum = 0;
      pos_bol = 0;
      pos_lnum = 1;
    }


  (* Boilerplate to define exceptional cases in the lexer. *)
  let unexpected_char lexbuf (c:char) : 'a =
    raise (Lexer_error (lex_range lexbuf,
        Printf.sprintf "Unexpected character: '%c'" c))
}


(* Basic regular expressions for the tokens of this grammar *)
let nl = '\n'
let linewhitespace = ['\t' ' ' '\r']
let whitespace = linewhitespace | nl

let com_char = (['*'] [^ '/']) | [^ '*']
let src_char = (['/'] [^ '*']) | [^ '/']

(* A rudimentary lexer whose purpose is to break a C program into a list
   of multi-line comments and other program elements.
*)
rule prog_elements lst = parse
  | eof                                 { List.rev lst }
  | src_char* as src                    { prog_elements (SrcStr(src)::lst) lexbuf }
  | "/*"                                { comment lst lexbuf }
  | _ as c                              { unexpected_char lexbuf c }
and comment lst = parse
  | com_char* as com                    { comment (ComStr(com)::lst) lexbuf }
  | "*/"                                { prog_elements lst lexbuf }
