(* 3. Write a function set_union a b that returns a list representing a UNION b.*)

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

let set_union_test1 = equal_sets (set_union [3;1;3] [1;2;3]) [1;2;3]
let set_union_test2 = equal_sets [3;1;3;1;2;3] [1;2;3]
let set_union_test3 = equal_sets (set_union [] []) []
let set_union_test4 = equal_sets (set_union [] [1; 2; 3]) [1; 2; 3]
let set_union_test5 = equal_sets (set_union [1; 2; 3] []) [1; 2; 3]
let set_union_test6 = equal_sets (set_union [1; 2; 3] [1; 2; 3]) [1; 2; 3]
let set_union_test7 = equal_sets (set_union [1; 2; 3] [4; 5; 6]) [1; 2; 3; 4; 5; 6]
let set_union_test8 = equal_sets (set_union [1; 2] [2; 3; 4]) [1; 2; 3; 4]
let set_union_test9 = equal_sets (set_union [1; 2; 2; 3] [2; 4; 4]) [1; 2; 3; 4]
let set_union_test10 = equal_sets (set_union [1; 2; 3; 3; 4; 5] [4; 5; 6; 7]) [1; 2; 3; 4; 5; 6; 7]
let set_union_test11 = equal_sets (set_union [1; 1; 1] [1; 1]) [1]
let set_union_test12 = equal_sets (set_union [1; 2; 2; 3] [2; 2; 3; 4; 4]) [1; 2; 3; 4]
