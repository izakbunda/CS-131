(* 1. The function (subset a b) returns true iff a is a subset of b. Note that every set is a subset of itself. *) 

let rec subset a b = 
   match a with (* This is how we get the head and tail of a instead of b *)
   | [] -> true
   | h::t -> if List.mem h b 
               then subset t b 
            else false;;

let subset_test0 = subset [] [1;2;3]
let subset_test1 = subset [3;1;3] [1;2;3]
let subset_test2 = not (subset [1;3;7] [4;1;3])
let subset_test3 = subset [] []
let subset_test4 = subset [] [5; 6; 7]
let subset_test5 = not (subset [1] [])
let subset_test6 = subset [1; 2; 3] [1; 2; 3]
let subset_test7 = subset [2; 3] [1; 2; 3; 4]
let subset_test8 = not (subset [1; 2; 4] [1; 2; 3])
let subset_test9 = subset [3; 3; 2] [2; 3; 3; 4]
let subset_test10 = subset [3; 3; 2] [2; 3; 4; 4]
let subset_test11 = subset [3; 2; 1] [1; 2; 3]
let subset_test12 = not (subset [1; 2; 3; 4] [1; 2; 3])
