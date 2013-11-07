open Lexing

exception Lexer_error of Range.t * string

(* Creates a Range.pos from the Lexing.position data *)
let pos_of_lexpos (p:Lexing.position) : Range.pos =
  Range.mk_pos (p.pos_lnum) (p.pos_cnum - p.pos_bol)

(* Creates a Range.t from two Lexing.positions *)
let mk_lex_range (p1:Lexing.position) (p2:Lexing.position) : Range.t =
  Range.mk_range p1.pos_fname (pos_of_lexpos p1) (pos_of_lexpos p2)

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

let unexpected_char lexbuf (c:char) : 'a =
  raise (Lexer_error (lex_range lexbuf,
                      Printf.sprintf "Unexpected character: '%c'" c))

