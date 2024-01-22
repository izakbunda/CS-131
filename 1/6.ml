(* Write a function computed_fixed_point eq f x that returns the computed fixed point for f with respect to x, 
   assuming that eq is the equality predicate for f's domain. A common case is that eq will be (=), that is, 
   the builtin equality predicate of OCaml; but any predicate can be used. If there is no computed fixed point, 
   your implementation can do whatever it wants: for example, it can print a diagnostic, or go into a loop, or 
   send nasty email messages to the user's relatives.
*)

(*
*)

let computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x / 2) 1000000000 = 0
let computed_fixed_point_test1 = computed_fixed_point (=) (fun x -> x *. 2.) 1. = infinity
let computed_fixed_point_test2 = computed_fixed_point (=) sqrt 10. = 1.
let computed_fixed_point_test3 =
  ((computed_fixed_point (fun x y -> abs_float (x -. y) < 1.)
			 (fun x -> x /. 2.)
			 10.)
   = 1.25)