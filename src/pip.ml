let graphwidth = ref 0 and graphheight = ref 0 ;;
let init_frame imagewidth imageheight =
  if !graphwidth <> imagewidth || !graphheight <> imageheight then (
    graphwidth := imagewidth;
    graphheight := imageheight;
    Graphics.open_graph "";
    Graphics.resize_window !graphwidth !graphheight
  ) ;;

let print_frame data =
  Graphics.draw_image (Graphics.make_image (
    Array.map (fun line ->
      Array.map (fun (r, g, b) ->
        Graphics.rgb r g b
      ) line
    ) data
  )) 0 0 ;;

module Pip (K : Kahn.S) = struct
  module K = K
  module Lib = Kahn.Lib(K)
  open Lib

  (*
   I = Image
   V = Video
  *)
  module I = Image_ppm.Ppm
  module V = Video.AbstractVideo(I)

  let c1 = ref 0
  let c2 = ref 0
  let fps = 24

  (*
    m = manager
    b = blender
    tv = television
    rc = remote control
  *)

  let nb_fluxes = 3
  let fluxes_to_m = Array.init nb_fluxes (fun _ -> K.new_channel ())
  let qi_m_to_tv, qo_m_to_tv = K.new_channel ()
  let qi_m_to_b, qo_m_to_b = K.new_channel ()
  let qi_b_to_m, qo_b_to_m = K.new_channel ()
  let qi_rc_to_m, qo_rc_to_m = K.new_channel ()

  let flux_in flux_num videoname =
    let video = V.load videoname fps in
    let rec loop () =
      let image = V.new_frame video in
      (K.put image (snd fluxes_to_m.(flux_num))) >>=
      loop
    in
    loop ()

  let manager () =
    let rec loop () =
      (K.put (-1) qo_rc_to_m) >>=
      (fun () -> (K.get qi_rc_to_m)) >>=
      (fun n ->
        if(n >= 0 && n <= nb_fluxes - 1) then (
          if n = !c2 then c1 := n
          else c2 := n
        );

        let c = ref [] in

        let rec aux i process =
          if i < 0 then process
          else (
            aux (i - 1) (
              process >>=
              (fun () ->
                (K.get (fst fluxes_to_m.(i))) >>=
                (fun img -> c := img::!c; K.return ()))
            )
          )
        in

        (aux (nb_fluxes - 1) (K.return ())) >>=
        (fun () -> 
          if(!c1 != !c2) then (
            (K.put (List.nth !c !c1, List.nth !c !c2) qo_m_to_b) >>=
            (fun () -> (K.get qi_b_to_m)) >>=
            (fun blent_img -> (K.put blent_img qo_m_to_tv))
          ) else (
            (K.put (List.nth !c !c1) qo_m_to_tv)
          )
        ) >>=
        loop 
      )
    in
    loop ()

  let television () =
    let rec loop () =
      (K.get qi_m_to_tv) >>=
      (fun img_final ->
        init_frame (I.width img_final) (I.height img_final);
        print_frame (I.data img_final);
        loop ())
    in
    loop ()

  let blender pos size =
    let rec loop () =
      (K.get qi_m_to_b) >>=
      (fun (img1, img2) ->
        let img_blender = I.blend img1 img2 (fst pos) (snd pos) (fst size) (snd size) in
        (K.put img_blender qo_b_to_m)) >>=
      loop
    in loop ()

  let remoteControl () =
    let rec loop () =
      (if Graphics.key_pressed () then (
        let n = Char.code (Graphics.read_key ()) - 97 in
        (K.get qi_rc_to_m) >>=
        (fun i -> K.put n qo_rc_to_m)
      ) else (
        Thread.yield () ;
        K.return ()
      )) >>=
      loop
    in loop ()

  let main =
    K.doco [(flux_in 0 "data/DubaiFlowMotion.mp4");
            (flux_in 1 "data/Landscapes.mp4");
            (flux_in 2 "data/Cristiano.mp4");
            (manager ());
            (blender (100, 100) (300, 150));
            (television ());
            (remoteControl ())
            ]
end

let () = init_frame 200 200

module E = Pip(Kahn_tube_thread.Tube)
let () = E.K.run E.main
