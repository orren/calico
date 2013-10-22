
type property = { input_prop: string list; output_prop: string }

type annotatedFunction = { code: string; properties: property list; }

let prop1: property = {input_prop = ["multiply(A, 2, length)"; "id"] ; output_prop = "double"}
let prop2: property = {input_prop = ["multiply(A, -1, length"; "id"] ; output_prop = "negate"}
let fun1: annotatedFunction = { code = "int sum(int A[], int length) {\n
											int i, sum = 0;\n
											for (i = 0; i < length; i++) sum += A[i];\n
											return sum;\n
										}" ; properties = [prop1; prop2]}

let functionsUnderTest: annotatedFunction list = [fun1]