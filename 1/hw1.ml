(* (* Define a function to add two numbers *)
let add a b = a + b;;

(* Define a function to multiply two numbers *)
let multiply a b = a * b;;

(* Define a function that takes a function and two integers as arguments, 
   and applies the function to the integers *)
let operate func x y = func x y;;

(* Use the 'operate' function with 'add' and 'multiply' *)
let result1 = operate add 10 20;;
let result2 = operate multiply 10 20;;

(* 1. The function (subset a b) returns true iff a is a subset of b. Note that every set is a subset of itself. 
   The function should apply to all lists. The function should also be curried.
*) *)

let rec subset a b = 
   match a with (* This is how we get the head and tail of a instead of b *)
   | [] -> true
   | h::t -> if List.mem h b then subset t b else false