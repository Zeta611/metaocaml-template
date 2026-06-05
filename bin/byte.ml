let run = Runcode.run

let () =
  (* Stage a power function specialized for a given exponent *)
  let staged_pow n =
    .< fun x ->
         let rec pow acc i =
           if i = 0 then acc else pow (acc * x) (i - 1)
         in
         pow 1 n >.
  in
  let code = staged_pow 3 in
  Format.printf "@[%a@]@." Codelib.print_code code;
  let pow3 = run code in
  Printf.printf "pow3 2 = %d\n%!" (pow3 2)
