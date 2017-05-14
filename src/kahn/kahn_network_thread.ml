module Net: Kahn.S = struct
  let port = ref 80000

  type 'a process = (unit -> 'a)

  type 'a in_port = in_channel
  type 'a out_port = out_channel

  let new_channel () =
    let ad = Unix.ADDR_INET (Unix.inet_addr_loopback, !port) in
    port := !port + 1;

    let in_s = Unix.socket (Unix.domain_of_sockaddr ad) Unix.SOCK_STREAM 0 in
    let out_s = Unix.socket (Unix.domain_of_sockaddr ad) Unix.SOCK_STREAM 0 in
        
    Unix.bind out_s ad;
    Unix.listen out_s 1;

    Unix.connect in_s ad;

    let out_s, _ = Unix.accept out_s in
    Unix.in_channel_of_descr in_s, Unix.out_channel_of_descr out_s
    
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
