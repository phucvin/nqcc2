[@@@coverage exclude_file]

type t = Int | Long | FunType of { param_types : t list; ret_type : t }
[@@deriving show { with_path = false }]
