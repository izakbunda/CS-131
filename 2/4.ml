(* 4. Write a function make_parser gram that returns a parser for the grammar gram. When applied to a fragment frag, the parser 
   returns an optional parse tree. If frag cannot be parsed entirely (that is, from beginning to end), the parser returns None. 
   Otherwise, it returns Some tree where tree is the parse tree corresponding to the input fragment. Your parser should try grammar 
   rules in the same order as make_matcher.
*)

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal


let rec parse_tree_leaves tree =
   match tree with
   | Leaf terminal -> [terminal]
   | Node (_, children) -> 
     List.fold_left (fun acc child -> 
         acc @ parse_tree_leaves child) [] children
 
let parse_tree_acceptor frag tree =
   match frag with
   | [] -> Some tree
   | _ -> None

let make_parser gram =
   let rule_matcher_func = snd gram in (* This will return the rule matching function *)
   let start_sym = fst gram in (* This will return the start symbol *)
   
   (* This is like literally the same as the make_matcher except we have a new param and we're passing in the nonterminal *)
   let rec try_expansions nonterminal expansions accept frag children =
      match expansions with
      | [] -> None (* base case *)
      | h::t ->
         match match_seq nonterminal h accept frag children with
         | None -> try_expansions nonterminal t accept frag children 
         | Some x -> Some x
   
   and match_seq nonterminal rule accept frag children =
      match rule with
      | [] -> accept frag (Node(nonterminal, children)) (* Use current nonterminal symbol here *)
      | sym::syms ->
         match sym with
         | N next_nonterminal ->
               let expansions = rule_matcher_func next_nonterminal in
               let continue next_frag next_tree = match_seq nonterminal syms accept next_frag (children @ [next_tree]) in
               try_expansions next_nonterminal expansions continue frag []
         | T terminal ->
               match frag with
               | h::t when terminal = h -> match_seq nonterminal syms accept t (children @ [Leaf terminal])
               | _ -> None (* "backtrack" here *)
   
   in
   
   let start_expanded = rule_matcher_func start_sym in
   fun frag -> try_expansions start_sym start_expanded parse_tree_acceptor frag []


let accept_all string = Some string
let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x

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
   