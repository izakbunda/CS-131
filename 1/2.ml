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

let equal_sets_test0 = equal_sets [1;3] [3;1;3]
let equal_sets_test1 = not (equal_sets [1;3;4] [3;1;3])
let equal_sets_test2 = equal_sets [] []
let equal_sets_test3 = not (equal_sets [] [1; 2; 3]) (* err *)
let equal_sets_test4 = equal_sets [1; 2; 3] [1; 2; 3]
let equal_sets_test5 = equal_sets [2; 1; 3] [1; 3; 2]
let equal_sets_test6 = equal_sets [1; 2; 2; 3] [3; 2; 1; 1] (* err *)
let equal_sets_test7 = not (equal_sets [1; 2; 4] [1; 2; 3]) 
let equal_sets_test8 = not (equal_sets [1; 2; 3] [1; 2; 3; 4]) (* err *)
let equal_sets_test9 = equal_sets [1; 2; 3] [1; 2; 2; 3; 3; 1] 
let equal_sets_test10 = not (equal_sets [4; 5; 6] [7; 8; 9]) 
let equal_sets_test11 = equal_sets [10; 20; 30; 40; 50] [50; 40; 30; 20; 10]