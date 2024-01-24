(* 4. Write a function set_all_union a that returns a list representing ∪[x∈a]x, i.e., the union of all the members of the set a; a should represent a set of sets. *)

(*
*)

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

let set_union a b = a @ b;;

(* ('a list) list -> 'a list *)
let rec set_all_union a =
    match a with
    | [] -> []
    | h::t -> set_union h (set_all_union t);;


let set_all_union_test0 = equal_sets (set_all_union []) []
let set_all_union_test1 = equal_sets (set_all_union [[3;1;3]; [4]; [1;2;3]]) [1;2;3;4]
let set_all_union_test2 = equal_sets (set_all_union [[5;2]; []; [5;2]; [3;5;7]]) [2;3;5;7]
let set_all_union_test3 = equal_sets (set_all_union [[1; 2]; [2; 3]; [3; 4]]) [1; 2; 3; 4]
let set_all_union_test4 = equal_sets (set_all_union [[1]; [1]; [1]]) [1]
let set_all_union_test5 = equal_sets (set_all_union [[1; 2; 3]; []; [4; 5]]) [1; 2; 3; 4; 5]
let set_all_union_test6 = equal_sets (set_all_union [[10]; [20]; [30]; [40; 50]]) [10; 20; 30; 40; 50]
let set_all_union_test7 = equal_sets (set_all_union [[6; 7; 8]; [9; 10; 11]; [6; 12; 13]]) [6; 7; 8; 9; 10; 11; 12; 13]
let set_all_union_test8 = equal_sets (set_all_union [[1; 2; 3]; [3; 4; 5]; [5; 6; 7]; [7; 8; 9]]) [1; 2; 3; 4; 5; 6; 7; 8; 9]
let set_all_union_test9 = equal_sets (set_all_union [[]; []; []]) []
let set_all_union_test10 = equal_sets (set_all_union [[1; 2; 3]; []; [4; 5; 6]; []; [7; 8; 9]]) [1; 2; 3; 4; 5; 6; 7; 8; 9]