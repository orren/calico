(* Simple driver to help debug the parser *)
open Parsedriver
open Ast

;; let ic = (open_in (Array.get Sys.argv 1) ) in
   Printf.printf "Parse result: \n%s\n"
     (String.concat "\n"
        (List.map str_of_pelem (parse_file "sample.c" ic).elements));
   close_in ic

