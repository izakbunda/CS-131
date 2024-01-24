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

let whileseq_test0 = whileseq ((+) 3) ((>) 10) 0;; (* [0; 3; 6; 9] *) 
let whileseq_test1 = whileseq ((+) 2) ((>) 20) 5;; (* [5; 7; 9; 11; 13; 15; 17; 19] *)
let whileseq_test2 = whileseq (( * ) 2) ((>) 100) 1;; (* [1; 2; 4; 8; 16; 32; 64] *)
let whileseq_test3 = whileseq ((+) 3) ((>) 10) (-5);; (* [-5; -2; 1; 4; 7] *)
let whileseq_test4 = whileseq ((-) 2) ((<) 0) 10;; (* [10; 8; 6; 4; 2] *)
let whileseq_test5 = whileseq ((+) 5) ((>) 30) 0;; (* [0; 5; 10; 15; 20; 25] *)
let whileseq_test6 = whileseq (( *. ) 2.) ((>) 10.) 1.;; (* [1.; 2.; 4.; 8.] *)
