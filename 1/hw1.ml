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

let rec remove_first_occurrence x lst =
    match lst with
    | [] -> []
    | h::t -> if h = x then t else h :: remove_first_occurrence x t

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

(* 5. Russell's Paradox involves asking whether a set is a member of itself. 
   Write a function self_member s that returns true iff the set represented by s is a member of itself, 
   and explain in a comment why your function is correct; or, if it's not possible to write such a function in OCaml, 
   explain why not in a comment. *)

(* Answer:
   If I understand correctly, basically there is some set R that contains all the sets that themselves DO NOT contain themselves.
   (i.e. A = {B, C, D} is in R, but A = {A, B, C, D} would not be in R). Then, the next part of the paradox is the question of whether R
   is in R itself because if it is then it shouldn't be because that goes against the initial defintion of R above – and vice versa.

   Now, we have to answer the question of whether a function self_member could take in this set R and return true if R is a member of
   itself or not. I think the answer is that this is not possible in OCaml (or at all). If we try to create a function like this, I would
   imagine this function to essentially recurse infinitely trying to find a set in a set in a set... over and over. I don't think that this
   behavior would be exclusive to OCaml either since the idea of a list being referred to inside itself seems unheard of to me and it seems
   like implmenting this feature in a language would introduce a lot of security issues and make the language difficult for new users to pick up.
*)

(* 6. Write a function computed_fixed_point eq f x that returns the computed fixed point for f with respect to x, 
   assuming that eq is the equality predicate for f's domain. A common case is that eq will be (=), that is, 
   the builtin equality predicate of OCaml; but any predicate can be used. If there is no computed fixed point, 
   your implementation can do whatever it wants: for example, it can print a diagnostic, or go into a loop, or 
   send nasty email messages to the user's relatives.
*)

(* : ('a -> 'a -> bool) -> ('a -> 'a) -> 'a -> 'a *)
let rec computed_fixed_point eq f x =
  let result = f x in
  if eq x result then
    x
  else
    computed_fixed_point eq f (f x);;

(* 7. Write a function computed_periodic_point eq f p x that returns the computed periodic point
   for f with period p and with respect to x, assuming that eq is the equality predicate for f's domain. *)

let rec apply_f_times f p x =
  if p = 0 then x
  else apply_f_times f (p - 1) (f x);;

let rec computed_periodic_point eq f p x =
  if eq (apply_f_times f p x) x then x
  else computed_periodic_point eq f p (f x);;

(* 8. Write a function whileseq s p x that returns the longest list [x; s x; s (s x); ...] 
   such that p e is true for every element e in the list. That is, if p x is false, return []; 
   otherwise if p (s x) is false, return [x]; otherwise if p (s (s x)) is false, return [x; s x]; and so forth. 
   For example, whileseq ((+) 3) ((>) 10) 0 returns [0; 3; 6; 9]. 
   Your implementation can assume that p eventually returns false. *)

(* ('a -> 'a) -> ('a -> bool) -> 'a -> 'a list *)
let rec whileseq s p x =
   let result = p x in
   match result with
   | false -> []
   | true -> [x] @ whileseq s p (s x);;

(* 9. Write a function filter_blind_alleys g that returns a copy of the grammar g with all blind-alley rules removed. 
   This function should preserve the order of rules: that is, all rules that are returned should be in the same order as the rules in g.*)

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let filter_blind_alleys g = g;;