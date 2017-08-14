module Ppm: Image.S = struct
  type img = {
    width: int;
    height: int;
    mutable data: (int * int * int) array array;
  }

  let extension = "ppm"

  let width image =
    image.width

  let height image =
    image.height

  let data image =
    image.data

  let create w h d =
    { width = w; height = h; data = d }

  let read filename =
    (* Vérifie la présence de "P6" *)
    let f = open_in filename in
    let line = input_line f in
    if line <> "P6" then invalid_arg "not P6" ;

    (* Récupère "width" et "length" *)
    let line = input_line f in
    let width, height =
      Scanf.sscanf line "%d %d" (fun w h -> (w, h))
    in

    (* Vérifie que l'image est en 8 bit *)
    let line = input_line f in
    if line <> "255" then invalid_arg "not 8 bit image" ;

    (* Initialise la matrice *)
    let m = Array.make_matrix height width (0, 0, 0) in

    for i = 0 to (height - 1) do
      for j = 0 to (width - 1) do
        let r = input_byte f in
        let g = input_byte f in
        let b = input_byte f in
        m.(i).(j) <- (r, g, b)
      done;
    done;
    close_in f;

    { width = width;
      height = height;
      data = m }

  let grayscale image =
    image.data <- Array.map (fun line ->
      Array.map (fun (r, g, b) ->
        let g = (r + g + b) / 3 in
        g, g, g
      ) line
    ) image.data;
    image

  let resize image newwidth newheight =
    (* Initialise les nouvelles tailles et rapports *)
    let oldwidth = image.width in
    let oldheight = image.height in
    let hratio = (float_of_int oldwidth) /. (float_of_int newwidth) in
    let vratio = (float_of_int oldheight) /. (float_of_int newheight) in

    (* Définit une fonction qui moyenne une plage de l'image *)
    let avg xmin xmax ymin ymax =
      let c = ref 0 in

      let sum = ref (0, 0, 0) in
      for i = ymin to ymax do
        for j = xmin to xmax do
          let s_r, s_g, s_b = !sum in
          try (
            let r, g, b = image.data.(i).(j) in
            sum := (s_r + r, s_g + g, s_b + b);
            c := !c + 1
          ) with Invalid_argument "index out of bounds" -> ()
        done;
      done;

      let s_r, s_g, s_b = !sum in
      (s_r / !c, s_g / !c, s_b / !c)
    in

    (* Initialise la matrice *)
    let m = Array.make_matrix newheight newwidth (0, 0, 0) in
    for i = 0 to (newheight - 1) do
      for j = 0 to (newwidth - 1) do
        m.(i).(j) <- avg
          (int_of_float (ceil ((float_of_int j) *. hratio)))
          (int_of_float (ceil ((float_of_int (j+1)) *. hratio)))
          (int_of_float (ceil ((float_of_int i) *. vratio)))
          (int_of_float (ceil ((float_of_int (i+1)) *. vratio)))
      done;
    done;

    { width = newwidth;
      height = newheight;
      data = m }

  let blend image1 image2 x2 y2 w2 h2 =
    let image2 = resize image2 w2 h2 in

    for i = 0 to h2 - 1 do
      for j = 0 to w2 - 1 do
        image1.data.(y2 + i).(x2 + j) <- image2.data.(i).(j)
      done;
    done;

    image1
end
