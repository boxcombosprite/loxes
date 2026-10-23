let (>>) f g x = g @@ f x

let read_whole_file fname =
    let ic = open_in_bin fname in
    try
        let s = really_input_string ic (in_channel_length ic) in
        close_in ic;
        s
    with e ->
        close_in_noerr ic;
        raise e

module Lox : sig
    val run_prompt : unit -> unit
    val run_file : string -> unit
end = struct
    type interp_result = InterpOk | InterpError

    let run src =
        Scanner.scan_tokens src |> List.iter (Printf.printf "%s\n");
        InterpOk

    let report line where msg =
        Printf.eprintf "[line %i] Error %s: %s\n"

    let error line msg =
        report line "" msg

    let rec run_prompt () =
        print_string "> ";
        try
            read_line () |> run |> ignore;
            run_prompt ()
        with End_of_file -> ()

    let run_file fname =
        match
        read_whole_file fname |> run
        with
        | InterpOk -> ()
        | InterpError -> exit 65

end


let print_usage () =
    print_endline "usage: oclox [script]"

let () =
    let args = Sys.argv in
    match Array.length args with
    | 1 -> Lox.run_prompt ()
    | 2 -> Lox.run_file args.(1)
    | _ -> print_usage ()
