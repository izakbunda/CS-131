(* 2. As another warmup, write a function parse_tree_leaves tree that traverses the parse tree tree left to right and yields a 
   list of the leaves encountered, in order.
*)

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

(* parse_tree_leaves : ('a, 'b) parse_tree -> 'b list *)

let rec parse_tree_leaves tree =
  match tree with
  | Leaf terminal -> [terminal]
  | Node (_, children) -> 
    List.fold_left (fun acc child -> 
        acc @ parse_tree_leaves child) [] children
