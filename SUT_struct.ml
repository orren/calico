type funKind = Pure | SideEffect | PointReturn

type property = { input_prop: (string * funKind) list; output_prop: string * funKind }
type parameter = { param_type: string; param_name: string }
type annotatedFunction = { annotations: string; return_type: string; fun_kind: funKind; fun_name: string; parameters: parameter list; raw: string; properties: property list }
type sourceUnderTest = { file_name: string; top_source: string list; functions: annotatedFunction list }