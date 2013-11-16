(* Simple driver to help debug the parser *)
open Parsedriver
open Ast

;; let ic = (open_in "sum_example.c") in
   Printf.printf "Parse result: \n%s\n"
     (String.concat "\n"
        (List.map str_of_pelem (parse_file "sum_example.c" ic).elements));
   close_in ic
