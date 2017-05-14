open Kahn

module Seq: S = struct
  type 'a process = ('a -> unit) -> unit

  type 'a channel = 'a Queue.t
  type 'a in_port = 'a channel
  type 'a out_port = 'a channel

  type task = unit -> unit
  let tasks = Queue.create ()

  let new_channel () =
    let q = Queue.create () in
    q, q

  let rec put v c =
    fun next_p ->
      if Queue.is_empty c then (
        Queue.add v c;
        Queue.add next_p tasks
      ) else
        Queue.add (fun () -> put v c next_p) tasks

  let rec get c =
    fun next_p ->
      if Queue.is_empty c then
        Queue.add (fun () -> get c next_p) tasks
      else
        Queue.add (fun () -> next_p (Queue.take c)) tasks

  let doco l =
    fun next_p ->
      let nb_remaining_p = ref (List.length l) in
      List.iter (fun p ->
        Queue.add (fun () -> p (fun () -> nb_remaining_p := !nb_remaining_p - 1)) tasks
      ) l;
      let rec end_p () =
        if !nb_remaining_p = 0 then
          next_p ()
        else
          Queue.add end_p tasks
      in end_p ()

  let return v =
    fun next_p -> Queue.add (fun () -> next_p v) tasks

  let bind e e' =
    fun next_p ->
      e (fun v -> e' v next_p)

  let run p =
    let res = ref [] in
    p (fun v -> res := v::!res);
    while not(Queue.is_empty tasks) do
      (Queue.take tasks) ()
    done;
    List.hd !res
end
