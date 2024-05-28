open Cmdliner
open Nqcc

(* what platform are we on? *)
let current_platform =
  let uname_output =
    String.lowercase_ascii (snd (Batteries.Unix.run_and_read "uname"))
  in
  if String.starts_with ~prefix:"darwin" uname_output then Settings.OS_X
  else Settings.Linux

(* Utilities *)
let validate_extension filename =
  let ext = Filename.extension filename in
  if ext = ".c" || ext = ".h" then ()
  else failwith "Expected C source file with .c or .h extension"

let replace_extension filename new_extension =
  let base = Filename.chop_extension filename in
  base ^ new_extension

let run_command cmd =
  if Sys.command cmd <> 0 then failwith ("Command failed: " ^ cmd)

(* main driver *)
let preprocess src =
  let _ = validate_extension src in
  let output = replace_extension src ".i" in
  let preprocess_cmd = Printf.sprintf "gcc -E -P %s -o %s" src output in
  let _ = run_command preprocess_cmd in
  output

let compile stage preprocessed_src =
  let _ = Compile.compile stage preprocessed_src in
  (* remove preprocessed src *)
  let cleanup_preprocessed = Printf.sprintf "rm %s" preprocessed_src in
  run_command cleanup_preprocessed;
  replace_extension preprocessed_src ".s"

let assemble_and_link ?(link = true) ?(cleanup = true) ?(libs = []) src =
  let link_option = if link then "" else "-c" in
  let lib_options = List.map (fun l -> "-l" ^ l) libs |> String.concat " " in
  let assembly_file = replace_extension src ".s" in
  let output_file =
    if link then Filename.chop_extension src else replace_extension src ".o"
  in
  let assemble_cmd =
    Printf.sprintf "gcc %s %s %s -o %s" link_option assembly_file lib_options
      output_file
  in
  let _ = run_command assemble_cmd in
  (* cleanup .s files *)
  if cleanup then
    let cleanup_cmd = Printf.sprintf "rm %s" assembly_file in
    run_command cleanup_cmd

let driver target debug libs extra_credit stage src =
  let _ =
    Settings.platform := target;
    Settings.debug := debug;
    Settings.extra_credit_flags := extra_credit
  in
  let preprocessed_name = preprocess src in
  let assembly_name = compile stage preprocessed_name in
  match stage with
  | Settings.Executable ->
      assemble_and_link ~link:true ~cleanup:(not debug) ~libs assembly_name
  | Settings.Obj ->
      assemble_and_link ~link:false ~cleanup:(not debug) assembly_name
  | _ -> ()

(* Command-line options *)
let stage =
  let lex =
    let doc = "Run the lexer" in
    (Settings.Lex, Arg.info [ "lex" ] ~doc)
  in
  let parse =
    let doc = "Run the lexer and parser" in
    (Settings.Parse, Arg.info [ "parse" ] ~doc)
  in
  let validate =
    let doc = "Run the lexer, parser, and semantic analysis " in
    (Settings.Validate, Arg.info [ "validate" ] ~doc)
  in
  let tacky =
    let doc = "Run the lexer, parser, semantic analysis, and tacky generator" in
    (Settings.Tacky, Arg.info [ "tacky" ] ~doc)
  in
  let codegen =
    let doc = "Run through code generation but stop before emitting assembly" in
    (Settings.Codegen, Arg.info [ "codegen" ] ~doc)
  in
  let assembly =
    let doc = "Stop before assembling (keep .s file)" in
    (Settings.Assembly, Arg.info [ "s"; "S" ] ~doc)
  in
  let obj =
    let doc = "Stop before invoking linker (keep .o file)" in
    (Settings.Obj, Arg.info [ "c" ] ~doc)
  in
  Arg.(
    value
    & vflag Settings.Executable
        [ lex; parse; validate; tacky; obj; codegen; assembly ])

let libs =
  let doc = "Link against library (passed through to assemble/link command)" in
  Arg.(value & opt_all Arg.string [] & info [ "l" ] ~doc)

let target =
  let doc = "Choose target platform" in
  let target = Arg.enum [ ("linux", Settings.Linux); ("osx", Settings.OS_X) ] in
  Arg.(value & opt target current_platform & info [ "t"; "target" ] ~doc)

let extra_credit =
  let bitwise =
    let doc = "Enable bitwise operations (&, |, ^, <<, >>)" in
    (Settings.Bitwise, Arg.info [ "bitwise" ] ~doc)
  in
  let compound =
    let doc = "Enable compound assignment operations (+=, -=,*=, /=, %=)" in
    (Settings.Compound, Arg.info [ "compound" ] ~doc)
  in
  let increment =
    let doc = "Enable prefix and postfix increment and decrement (++/--)" in
    (Settings.Increment, Arg.info [ "increment" ] ~doc)
  in
  let goto =
    let doc = "Enable goto and labeled statements" in
    (Settings.Goto, Arg.info [ "goto" ] ~doc)
  in
  let switch =
    let doc = "Enable switch statements" in
    (Settings.Switch, Arg.info [ "switch" ] ~doc)
  in
  let nan =
    let doc = "Enable support for nan" in
    (Settings.Nan, Arg.info [ "nan" ] ~doc)
  in
  Arg.(value & vflag_all [] [ bitwise; compound; increment; goto; switch; nan ])

let debug =
  let doc =
    "Write out pre- and post-register-allocation assembly and DOT files of \
     interference graphs."
  in
  Arg.(value & flag & info [ "d" ] ~doc)

let src_file =
  Arg.(required & pos 0 (some non_dir_file) None & info [] ~docv:"files")

let cmd =
  let doc = "A not-quite-C compiler" in
  let info = Cmd.info "nqcc" ~doc in
  Cmd.v info
    Term.(
      const driver $ target $ debug $ libs $ extra_credit $ stage $ src_file)

let main () = exit (Cmd.eval cmd)
let () = main ()
