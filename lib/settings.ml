type stage =
  | Lex
  | Parse
  | Validate
  | Tacky
  | Codegen
  | Assembly
  | Obj
  | Executable

type target = OS_X | Linux

(* Control which extra-credit features are enabled (to test the test suite) *)
type extra_credit =
  | Bitwise
  | Compound
  | Increment
  | Goto
  | Switch
  | Nan
  | Union

let platform = ref OS_X (* default to OS_X *)
let extra_credit_flags = ref []
let int_only = ref false

type optimizations = {
  constant_folding : bool;
  dead_store_elimination : bool;
  unreachable_code_elimination : bool;
  copy_propagation : bool;
}

type debug_options = {
  (* dumping intermediate representations *)
  dump_tacky : bool;
  dump_asm : bool;
  (* dumping extra info about specific optimizations*)
  dump_optimizations : optimizations;
  (* If specified, we dump optimization info only for this function;
   * otherwise dump for all functions
   * doesn't impact dump_tacky/dump_asm, which always dump the whole program *)
  dump_fun : string option;
}

let debug =
  ref
    {
      dump_tacky = false;
      dump_asm = false;
      dump_optimizations =
        {
          constant_folding = false;
          dead_store_elimination = false;
          unreachable_code_elimination = false;
          copy_propagation = false;
        };
      dump_fun = None;
    }
