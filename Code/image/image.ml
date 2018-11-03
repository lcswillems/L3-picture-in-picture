module type S = sig
  type img
  val extension: string

  val width: img -> int
  val height: img -> int
  val data: img -> (int * int * int) array array

  val create: int -> int -> (int * int * int) array array -> img
  val read: string -> img
  val grayscale: img -> img
  val resize: img -> int -> int -> img
  val blend: img -> img -> int -> int -> int -> int -> img
end
