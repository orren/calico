open Printf
open Parsedriver
open Calico_writer
open Array
open Sys

let () =
	if (Array.length Sys.argv) != 2
	then printf "usage: calico <name of C source file>"
	else let fname = (get Sys.argv 1) in
         let ic = open_in fname in
         write_source (parse_file fname ic);
         close_in ic
