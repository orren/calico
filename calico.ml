open Printf
open List

type property = { input_prop: string list; output_prop: string }
type parameter = { param_type: string; param_name: string; is_pointer: bool }
type annotatedFunction = { annotations: string; return_type: string; return_is_pointer: bool; fun_name: string; parameters: parameter list; body: string; properties: property list }
type sourceUnderTest = { file_name: string; top_source: string list; functions: annotatedFunction list }

let key_number : string = "9847"

let prop1: property = {input_prop = ["multiply_int_array(A, 2, length)"; "length"] ; output_prop = "multiply_int(result, 2)"}
let prop2: property = {input_prop = ["multiply_int_array(A, -1, length)"; "length"] ; output_prop = "multiply_int(result, -1)"}

let fun1: annotatedFunction = {annotations = "/**\n * Sums the elements of an array?\n *\n * @input-prop multiply(A, 2, length), length\n * @output-prop multiply_int(result, 2)\n */";
        return_type = "int"; return_is_pointer = false; fun_name = "sum"; 
        parameters = [ {param_type = "int"; param_name = "A"; is_pointer = true};
                       {param_type = "int"; param_name = "length"; is_pointer = false} ] ;
        body = "    int i, sum = 0;\n    for (i = 0; i < length; i++) sum += A[i];\n    return sum;" ; properties = [prop1; prop2]}

let prop3: property = {input_prop = ["multiply_double(a, -1)"]; output_prop = "result"}

let fun2: annotatedFunction = {annotations = "/**\n * Returns a pointer to an integer that is the absolute value of a\n *\n * @input-prop multiply_double(a, -1)\n * @output-prop result\n */";
        return_type = "int *"; return_is_pointer = true; fun_name = "absolute";
        parameters = [ {param_type = "double"; param_name = "a"; is_pointer = false} ] ;
        body = "    int *answer = malloc(sizeof(int));\n    *answer = abs(a);\n    return answer;"
        ; properties = [prop3]}

(* TODO: certain includes will always be necessary. We must check the first element of top_source to make sure those includes are already present, otherwise we must add them *)
let simpleTestSUT : sourceUnderTest = {
    file_name = "simple_test" ;
    top_source = ["#include <unistd.h>\n#include <sys/types.h>\n#include <sys/ipc.h>\n#include <sys/shm.h>\n#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>\n#include <math.h>"; "// some comment or whatever"] ;
    functions = [fun1; fun2] }

let rec range_list (i : int) (j : int) (acc : int list) : int list = 
    if i > j then acc
    else range_list i (j - 1) (j :: acc)

let rec merge (l1:'a list) (l2:'a list) : 'a list =
    begin match (l1, l2) with
    | ([], []) -> []
    | ([], l) -> l
    | (l, []) -> l
    | ((n1 :: rest1), (n2 :: rest2)) -> n1 :: n2 :: (merge rest1 rest2)
    end ;;

let write_param (param : parameter) : string = 
    param.param_type ^ (if param.is_pointer then " *" else " ") ^ param.param_name

let input_transformation (param : parameter) (prop : string) : string =
    (if param.is_pointer then "" else param.param_name ^ " = ") ^ prop

let output_transformation (is_pointer : bool) (prop : string) : string =
    (if is_pointer then "memcpy(result, " ^ prop ^ ")" else "*result = ") ^ prop

let transformed_call (return_type : string) (return_is_pointer : bool) (fun_name : string)
    (params : parameter list) (p : property) (procNum : int) : string =
    "    if (procNum == " ^ (string_of_int procNum) ^ ") {\n" ^
    "        int shmid = shmget(key + procNum, result_size, 0666);\n" ^
    "        result = shmat(shmid, NULL, 0);\n" ^ 
    "        " ^ String.concat ";\n        "
    (* apply input transformations *)
    (map2 input_transformation params p.input_prop) ^ ";\n" ^
    (* run inner function *)
    "        " ^ (if return_is_pointer then "" else "*") ^ "result = __" ^
    fun_name ^ "(" ^ String.concat ", "
             (map (fun (p : parameter) -> p.param_name) params) ^ ");\n" ^
    (* apply output transformations *)
    "        " ^ output_transformation return_is_pointer p.output_prop ^ ";\n" ^ 
    "        shmdt(result);\n" ^
    "        return 0;\n" ^
    "    }\n"

let property_assertion (p: property) (procNum : int) : string =
    "    result = shmat(shmids[" ^ (string_of_int procNum) ^ "], NULL, 0);\n" ^
    (* TODO: for compound data types, we need the tester to supply a notion of equality *)
    "    if (orig_result != *result) {\n" ^
    (* TODO: in order to print the actual and expected results, we need a printing interface *)
    "        printf(\"a property has been violated:\\ninput_prop: " ^ 
        (String.concat ", " p.input_prop) ^ "\\noutput_prop: " ^ p.output_prop ^ "\");\n" ^
    "    }\n"

let instrument_function (f : annotatedFunction) : string =
    (* each child process will have a number *)
    let child_indexes = (range_list 0 ((length f.properties) - 1) []) in

    (* original version of the function with underscores *)
    f.return_type ^ " __" ^ f.fun_name ^
    "(" ^ String.concat ", " (map write_param f.parameters) ^ ") {\n" ^ f.body ^ "\n}\n\n" ^

    (* instrumented version *)
    f.annotations ^ "\n" ^ f.return_type ^ " " ^ f.fun_name ^
    "(" ^ String.concat ", " (map write_param f.parameters) ^ ") {\n" ^

    (* fork *)
    "    int key = " ^ key_number ^ ";\n" ^ (* why this number? *)
    "    size_t result_size = sizeof(" ^ f.return_type ^ ");\n" ^
    "    int numProps = " ^ string_of_int (length f.properties) ^ ";\n" ^
    "    int* shmids = malloc(numProps * sizeof(int));\n" ^
    "    int procNum = -1;\n" ^ (* -1 for parent, 0 and up for children *)
    "    int i;\n" ^
    "    " ^ f.return_type ^ " orig_result;\n" ^
    "    " ^ f.return_type ^ " *result;\n\n" ^
    "    for (i = 0; i < numProps; i += 1) {\n" ^
    "        if (procNum == -1) {\n" ^
    "            shmids[i] = shmget(key + i, result_size, IPC_CREAT | 0666);\n" ^
    "            fork();\n" ^
    "            procNum = i;\n" ^
    "        } else {\n" ^
    "            break;\n" ^
    "        }\n" ^
    "    }\n\n" ^

    (* parent runs original inputs and waits for children *)
    "    if (procNum == -1) {\n" ^
    "        orig_result = __" ^ f.fun_name ^
             "(" ^ String.concat ", " (map (fun (p : parameter) -> p.param_name) f.parameters) ^ ");\n" ^
    "        for (i = 0; i < numProps; i += 1) {\n" ^
    "            wait(NULL);\n" ^
    "        }\n" ^
    "    }\n\n" ^

    (* children run transformed inputs and transform the result *)
    String.concat "\n" (map2
        (transformed_call f.return_type f.return_is_pointer f.fun_name f.parameters)
        f.properties child_indexes) ^ "\n" ^

    (* make assertions about the results *)
    String.concat "\n" (map2 property_assertion f.properties child_indexes) ^ "\n" ^

    (* cleanup *)
    "    free(shmids);\n" ^
    "    return orig_result;\n" ^
    "}"

let write_source (source: sourceUnderTest) : int =
    let out = open_out ("calico_" ^ source.file_name ^ ".c") in
    let instrumented = map instrument_function source.functions in
        fprintf out "#include \"calico_prop_library.h\"\n%s\n"
        (String.concat "\n\n" (merge source.top_source instrumented));
        close_out out;
        1

;; write_source simpleTestSUT