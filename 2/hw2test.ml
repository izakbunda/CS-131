let accept_all string = Some string
let accept_empty_suffix = function
    | _::_ -> None
    | x -> Some x

(* An example grammar for a small subset of Awk.
    This grammar is not the same as Homework 1; it is
    instead the grammar shown above.  *)

type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let awkish_grammar =
  (Expr,
    function
      | Expr ->
          [[N Term; N Binop; N Expr];
          [N Term]]
      | Term ->
    [[N Num];
    [N Lvalue];
    [N Incrop; N Lvalue];
    [N Lvalue; N Incrop];
    [T"("; N Expr; T")"]]
      | Lvalue ->
    [[T"$"; N Expr]]
      | Incrop ->
    [[T"++"];
    [T"--"]]
      | Binop ->
    [[T"+"];
    [T"-"]]
      | Num ->
    [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
    [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])

let test0 =
  ((make_matcher awkish_grammar accept_all ["ouch"]) = None)

let test1 =
  ((make_matcher awkish_grammar accept_all ["9"])
    = Some [])

let test2 =
  ((make_matcher awkish_grammar accept_all ["9"; "+"; "$"; "1"; "+"])
    = Some ["+"])

let test3 =
  ((make_matcher awkish_grammar accept_empty_suffix ["9"; "+"; "$"; "1"; "+"])
    = None)

(* This one might take a bit longer.... *)
let test4 =
  ((make_matcher awkish_grammar accept_all
      ["("; "$"; "8"; ")"; "-"; "$"; "++"; "$"; "--"; "$"; "9"; "+";
      "("; "$"; "++"; "$"; "2"; "+"; "("; "8"; ")"; "-"; "9"; ")";
      "-"; "("; "$"; "$"; "$"; "$"; "$"; "++"; "$"; "$"; "5"; "++";
      "++"; "--"; ")"; "-"; "++"; "$"; "$"; "("; "$"; "8"; "++"; ")";
      "++"; "+"; "0"])
  = Some [])



type genz_nonterminals =
  | Conversation | Greeting | Farewell | Slang

let genz_grammar =
  (Conversation,
   function
     | Conversation ->
         [[N Greeting; N Slang; N Farewell]]
     | Greeting ->
         [[T "Hey"]; [T "Slayqueen"]; [T "Yass"]]
     | Farewell ->
         [[T "Bye"]; [T "Periodt"]; [T "Skibbidy"]]
     | Slang ->
         [[T "lit"]; [T "savage"]; [T "Mother"]])

let make_matcher_test =
  let accept_all string = Some string in
  ((make_matcher genz_grammar accept_all ["Hey"; "Mother"; "Periodt"])
     = Some [])




let test5 =
  (parse_tree_leaves (Node ("+", [Leaf 3; Node ("*", [Leaf 4; Leaf 5])]))
    = [3; 4; 5])

let small_awk_frag = ["$"; "1"; "++"; "-"; "2"]

let test6 =
  ((make_parser awkish_grammar small_awk_frag)
    = Some (Node (Expr,
      [Node (Term,
      [Node (Lvalue,
              [Leaf "$";
        Node (Expr,
              [Node (Term,
                [Node (Num,
                [Leaf "1"])])])]);
        Node (Incrop, [Leaf "++"])]);
      Node (Binop,
      [Leaf "-"]);
      Node (Expr,
      [Node (Term,
              [Node (Num,
              [Leaf "2"])])])])))
let test7 =
  match make_parser awkish_grammar small_awk_frag with
    | Some tree -> parse_tree_leaves tree = small_awk_frag
    | _ -> false


    type miffy_nonterminals =
    | Sentence | Action | Object | Connector
  
 let miffy_grammar =
    (Sentence,
     function
       | Sentence ->
           [[N Action; N Object]; [N Sentence; N Connector; N Sentence]]
       | Action ->
           [[T "finds"]; [T "sees"]; [T "plays_with"]]
       | Object ->
           [[T "stars"]; [T "moon"]; [T "friend"]]
       | Connector ->
           [[T "and_then"]; [T "but"]])
 
 let make_parser_test =
    let fragment = ["finds"; "stars"; "and_then"; "sees"; "moon"] in
    match make_parser miffy_grammar fragment with
    | Some tree -> 
          parse_tree_leaves tree = fragment
    | _ -> false
    