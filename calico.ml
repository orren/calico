open Printf
open List

type property = { input_prop: string list; output_prop: string }
type parameter = { param_type: string; param_name: string; is_array: bool }
type annotatedFunction = { annotations: string; return_type: string; fun_name: string;
                          parameters: parameter list; body: string; properties: property list }
type sourceUnderTest = { file_name: string; top_source: string list; functions: annotatedFunction list }

let prop1: property = {input_prop = ["multiply(A, 2, length)"; "id"] ; output_prop = "double"}
let prop2: property = {input_prop = ["multiply(A, -1, length"; "id"] ; output_prop = "negate"}

let fun1: annotatedFunction = {annotations = "/**\n * Sums the elements of an array?\n *\n * @input-prop multiply(A, 2, length), id\n * @output-prop double\n */";
        return_type = "int"; fun_name = "sum"; 
        parameters = [ {param_type = "int"; param_name = "A"; is_array = true};
                       {param_type = "int"; param_name = "length"; is_array = false} ] ;
        body = "    int i, sum = 0;\n    for (i = 0; i < length; i++) sum += A[i];\n    return sum;" ; properties = [prop1; prop2]}

let simpleTestSUT : sourceUnderTest = {
    file_name = "simple_test" ;
    top_source = ["#include <sys/types.h>\n#include <sys/ipc.h>\n#include <sys/shm.h>\n#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>"; "// some comment or whatever"] ;
    functions = [fun1]
    }

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
    param.param_type ^ " " ^ param.param_name ^ (if param.is_array then "[]" else "")

let transformed_call (return_type : string) (fun_name : string)
                     (p : property) (procNum : int) : string = 
    "    if (procNum == " ^ (string_of_int procNum) ^ ") {\n" ^
    "        int shmid = shmget(key + procNum, result_size, 0666);\n" ^
    "        " ^ return_type ^ " *result = shmat(shmid, NULL, 0);\n" ^
    "        *result = __" ^ fun_name ^ "(" ^ String.concat ", " p.input_prop ^ ");\n" ^
             (* TODO: clarify output annotation syntax *)
    "        *result = " ^ p.output_prop ^ "(*result);\n" ^ 
    "        shmdt(result);\n" ^
    "        return 0;\n" ^
    "    }\n"

let property_assertion (p: property) (procNum : int) : string =
    "    trans_result = shmat(shmids[" ^ (string_of_int procNum) ^ "], NULL, 0);\n" ^
    (* TODO: for compound data types, we need the tester to supply a notion of equality *)
    "    if (*result != *trans_result) {\n" ^
    (* TODO: in order to print the actual and expected results, we need a printing interface *)
    "        printf(\"a property has been violated:\\ninput_prop: %s\\noutput_prop: %s, " ^
    (String.concat ", " p.input_prop) ^ "\", " ^ p.output_prop ^ ");\n" ^
    "    }"

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
    "    int key = 9487;\n" ^ (* why this number? *)
    "    size_t result_size = sizeof(" ^ f.return_type ^ ");\n" ^
    "    int numProps = " ^ string_of_int (length f.properties) ^ ";\n" ^
    "    int* shmids = malloc(numProps * sizeof(int));\n" ^
    "    int procNum = -1;\n" ^ (* -1 for parent, 0 and up for children *)
    "    int i;\n\n" ^
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
    "        " ^ f.return_type ^ " result = __" ^ f.fun_name ^
             "(" ^ String.concat ", " (map (fun (p : parameter) -> p.param_name) f.parameters) ^ ");\n" ^
    "        for (i = 0; i < numProps; i += 1) {\n" ^
    "            wait();\n" ^
    "        }\n" ^
    "    }\n\n" ^

    (* children run transformed inputs and transform the result *)
    String.concat "\n" (map2 (transformed_call f.return_type f.fun_name)
        f.properties child_indexes) ^ "\n" ^

    (* make assertions about the results *)
    "    " ^ f.return_type ^ " *trans_result;\n" ^
    String.concat "\n" (map2 property_assertion f.properties child_indexes) ^

    (* cleanup *)
    "    dealloc(chmids);\n" ^
    "    return result;\n" ^
    "}"

let write_source (source: sourceUnderTest) : int =
    let out = open_out ("calico_" ^ source.file_name ^ ".c") in
    let instrumented = map instrument_function source.functions in
        fprintf out "%s\n" (String.concat "\n\n" (merge source.top_source instrumented));
        close_out out;
        1

;; write_source simpleTestSUT