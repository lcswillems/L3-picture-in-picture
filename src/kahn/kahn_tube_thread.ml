module Tube: Kahn.S = struct
  type 'a process = (unit -> 'a)

  type 'a in_port = in_channel
  type 'a out_port = out_channel
  
  let new_channel () =
    let qin, qout = Unix.pipe () in
    Unix.in_channel_of_descr qin, Unix.out_channel_of_descr qout

  let put v out_p () =
    Marshal.to_channel out_p v [] ; flush out_p

  let get in_p () =
    Marshal.from_channel in_p

  let return v () =
    v

  let doco l () =
    let ths = List.map (fun f -> Thread.create f ()) l in
    List.iter (fun th -> Thread.join th) ths

  let bind e e' () =
    e' (e ()) ()

  let run e =
    e ()
end
