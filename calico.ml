open Printf
open Parsedriver
open Calico_writer
open Array
open Sys

let () =
	if (Array.length Sys.argv) != 2
	then printf "usage: calico <name of C source file>"
	else write_source (parse_file (get 1 Sys.argv))