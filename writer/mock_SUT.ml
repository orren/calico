open SUT_struct
(*
let prop1 : property = {input_prop = [("multiply_int_array(A, 2, length)", SideEffect);
                                      ("length", Pure)] ;
                                      output_prop = ("multiply_int(result, 2)", Pure)}
let prop2 : property = {input_prop = [("multiply_int_array(A, -1, length)", SideEffect);
                                      ("length", Pure)] ;
                                      output_prop = ("multiply_int(result, -1)", Pure)}

let fun1 : annotatedFunction = {annotations = "/**\n * Sums the elements of an array?\n *\n * @input-prop multiply(A, 2, length), length\n * @output-prop multiply_int(result, 2)\n */";
        return_type = "int"; fun_kind = Pure; fun_name = "sum"; 
        parameters = [ {param_type = "int *"; param_name = "A";};
                       {param_type = "int"; param_name = "length"} ] ;
        raw = "(int *A, int length) {\n    int i, sum = 0;\n    for (i = 0; i < length; i++) sum += A[i];\n    return sum;\n}" ; properties = [prop1; prop2]}

let prop3 : property = {input_prop = [("multiply_double(a, -1)", Pure)];
                        output_prop = ("multiply_int(result, 2)", Pure)}

let fun2 : annotatedFunction = {annotations = "/**\n * Returns a pointer to a double that is the absolute value of a\n *\n * @input-prop multiply_double(a, -1)\n * @output-prop result\n */";
        return_type = "double *"; fun_kind = PointReturn; fun_name = "absolute";
        parameters = [ {param_type = "double"; param_name = "a"} ] ;
        raw = "(double a) {\n    double *answer = malloc(sizeof(int));\n    *answer = abs(a);\n    return answer;\n};"
        ; properties = [prop3]}

(* TODO: certain includes will always be necessary. We must check the first element of top_source to make sure those includes are already present, otherwise we must add them *)
let simpleTestSUT : sourceUnderTest = {
    file_name = "simple_test" ;
    top_source = ["#include <unistd.h>\n#include <sys/types.h>\n#include <sys/ipc.h>\n#include <sys/shm.h>\n#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>\n#include <math.h>"; "// some comment or whatever"] ;
    functions = [fun1; fun2] }

*)
