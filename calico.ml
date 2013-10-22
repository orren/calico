open Printf
open List

type property = { input_prop: string list; output_prop: string }
type annotatedFunction = {annotations: string; return_type: string; fun_name: string;
                          parameters: string list; body: string; properties: property list }
type sourceUnderTest = { file_name: string; top_source: string list; functions: annotatedFunction list}

let prop1: property = {input_prop = ["multiply(A, 2, length)"; "id"] ; output_prop = "double"}
let prop2: property = {input_prop = ["multiply(A, -1, length"; "id"] ; output_prop = "negate"}

let fun1: annotatedFunction = {annotations = "/**\n* Sums the elements of an array?\n*\n* @input-prop multiply(A, 2, length), id\n* @output-prop double\n*/";
        return_type = "int"; fun_name = "sum"; 
        parameters = [ "int A[]" ; "int length" ] ;
        body = "int i, sum = 0;\nfor (i = 0; i < length; i++) sum += A[i];\nreturn sum;\n" ;        properties = [prop1; prop2]}

let rec merge (l1:'a list) (l2:'a list) : 'a list =
  begin match (l1, l2) with
  | ([], []) -> []
  | ([], n) -> n
  | (n, []) -> n
  | ((n1 :: rest1), (n2 :: rest2)) -> n1 :: n2 :: (merge rest1 rest2)
  end ;;

let instrument_function (f : annotatedFunction) : string =
    (* original version of the function with underscores *)
    f.return_type ^ " __" ^ f.fun_name ^
    "(" ^ String.concat ", " f.parameters ^ ") {\n" ^ f.body ^ "\n}\n" ^

    (* instrumented version *)
    f.annotations ^ f.return_type ^ f.fun_name ^
    "(" ^ String.concat ", " f.parameters ^ ") {\n" ^

    (* fork *)
    "    int key = 9487\n" ^ (* why this number? *)
    "    int numProps = " ^ string_of_int (length f.properties) ^ "\n" ^
    "    int* shmids = malloc(numProps * sizeof(int));\n" ^
    "    int procNum = -1;\n" ^ (* -1 for parent, 0 and up for children *)
    "    int i;\n" ^
    "    for (i = 0; i < numProps; i += 1) {\n" ^
    "        if (procNum == -1) {\n" ^
    "            shmids[i] = shmget(key + i, sizeof(" ^ f.return_type ^ "), IPC_CREAT | 0666)\n" ^
    "            fork();\n" ^
    "            procNum = i;\n" ^
    "        } else {\n" ^
    "            break;\n" ^
    "        }\n"

let write_source (source: sourceUnderTest) : int =
    let out = open_out source.file_name in
    let instrumented = map instrument_function source.functions in
        fprintf out "%s\n" (String.concat "\n" (merge source.top_source instrumented));
        close_out out;
        1
