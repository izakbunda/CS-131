(* Write a function computed_periodic_point eq f p x that returns the computed periodic point
   for f with period p and with respect to x, assuming that eq is the equality predicate for f's domain. *)

(*
*)

let rec apply_f_times f p x =
  if p = 0 then x
  else apply_f_times f (p - 1) (f x)

let rec computed_periodic_point eq f p x =
  if eq (apply_f_times f p x) x then x
  else computed_periodic_point eq f p (f x)

let computed_periodic_point_test0 =
  computed_periodic_point (=) (fun x -> x / 2) 0 (-1) = -1
let computed_periodic_point_test1 =
  computed_periodic_point (=) (fun x -> x *. x -. 1.) 2 0.5 = -1.

let computed_periodic_point_test2 =
  computed_periodic_point (=) (fun x -> x - x * x) 0 2 = 2

let computed_periodic_point_test3 =
  computed_periodic_point (fun x y -> x = y) (fun x -> x * 3) 1 1 = 3
