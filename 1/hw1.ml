(* 1. The function (subset a b) returns true iff a is a subset of b. Note that every set is a subset of itself. *) 

let rec subset a b = 
   match a with (* This is how we get the head and tail of a instead of b *)
   | [] -> true
   | h::t -> if List.mem h b 
               then subset t b 
            else false;;

(* 2. The function (equal_sets a b) returns true iff a and b are equal set. *)

(* 'a list -> 'a list *)
let rec remove_duplicates lst =
    match lst with 
    | [] -> []
    | h::t -> if List.mem h t 
                then remove_duplicates t 
            else h :: remove_duplicates t;;

let rec equal_sets a b = 
    let a_nd = remove_duplicates a in
    let b_nd = remove_duplicates b in
   match a_nd with 
   | [] -> b_nd = []
   | h::t -> if List.mem h b_nd 
               then equal_sets t (remove_first_occurrence h b_nd)
            else false;;

(* 3. Write a function set_union a b that returns a list representing a UNION b.*)

(* 'a list -> 'a list *)
let rec remove_duplicates lst =
    match lst with 
    | [] -> []
    | h::t -> if List.mem h t 
                then remove_duplicates t 
            else h :: remove_duplicates t;;

let set_union a b = a @ b;;

(* 4. Write a function set_all_union a that returns a list representing ∪[x∈a]x, i.e., the union of all the members of the set a; a should represent a set of sets. *)

(* ('a list) list -> 'a list *)
let rec set_all_union a =
    match a with
    | [] -> []
    | h::t -> set_union h (set_all_union t);;

(* Russell's Paradox involves asking whether a set is a member of itself. 
   Write a function self_member s that returns true iff the set represented by s is a member of itself, 
   and explain in a comment why your function is correct; or, if it's not possible to write such a function in OCaml, 
   explain why not in a comment. *)

(* 6. Write a function computed_fixed_point eq f x that returns the computed fixed point for f with respect to x, 
   assuming that eq is the equality predicate for f's domain. A common case is that eq will be (=), that is, 
   the builtin equality predicate of OCaml; but any predicate can be used. If there is no computed fixed point, 
   your implementation can do whatever it wants: for example, it can print a diagnostic, or go into a loop, or 
   send nasty email messages to the user's relatives.
*)

(* : ('a -> 'a -> bool) -> ('a -> 'a) -> 'a -> 'a *)
let rec computed_fixed_point eq f x =
  let result = f x in
  if eq result x then
    result
  else
    computed_fixed_point eq f result

(* 7. Write a function computed_periodic_point eq f p x that returns the computed periodic point
   for f with period p and with respect to x, assuming that eq is the equality predicate for f's domain. *)

let rec apply_f_times f p x =
  if p = 0 then x
  else apply_f_times f (p - 1) (f x)

let rec computed_periodic_point eq f p x =
  if eq (apply_f_times f p x) x then x
  else computed_periodic_point eq f p (f x)