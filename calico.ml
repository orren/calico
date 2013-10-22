
type property = { input_prop: string list; output_prop: string }
type parameter = { param_type: string; param_name: string }
type annotatedFunction = {annotations: string; return_type: string; fun_name: string;
						  parameters: parameter list; body: string; properties: property list }
type sourceUnderTest = { file_name: string; top_source: string list; functions: annotatedFunction list}

let prop1: property = {input_prop = ["multiply(A, 2, length)"; "id"] ; output_prop = "double"}
let prop2: property = {input_prop = ["multiply(A, -1, length"; "id"] ; output_prop = "negate"}

(* need to figure out how to better separate name and type *)
let param1: parameter = { param_type = "int" ; param_name = "A[]"}

let param2: parameter = {param_type = "int" ; param_name = "length"}
let fun1: annotatedFunction = {annotations = "/**\n* Sums the elements of an array?\n*\n* @input-prop multiply(A, 2, length), id\n* @output-prop double\n*/";
		return_type = "int"; fun_name = "sum"; 
		parameters = [ param1 ; param2 ] ;
		body = "int i, sum = 0;\nfor (i = 0; i < length; i++) sum += A[i];\nreturn sum;\n" ; 		properties = [prop1; prop2]}


let write_source (path: string) (source: sourceUnderTest) : int =
	1