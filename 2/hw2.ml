type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(* 1. To warm up, notice that the format of grammars is different in this assignment, versus Homework 1. Write a function 
   convert_grammar gram1 that returns a Homework 2-style grammar, which is converted from the Homework 1-style grammar gram1. 
   Test your implementation of convert_grammar on the test grammars given in Homework 1. For example, the top-level 
   definition let awksub_grammar_2 = convert_grammar awksub_grammar should bind awksub_grammar_2 to a Homework 2-style grammar 
   that is equivalent to the Homework 1-style grammar awksub_grammar. *)


(* add_to_alist: awksub_nonterminals -> symbol -> (awksub_nonterminals * (symbol list) list) ->  ( awksub_nonterminals * (symbol list) ) list *)
(* Basically a dictionary because OCaml doesn't have a built in dictionary data structure *)
(* DO NOT MESS UP ORDER!! *)

let rec add_to_alist key value alist =
  match alist with
  | [] -> [(key, [value])] 
  | (k, v)::tail ->
      if k = key then
        (k, v @ [value]) :: tail  
      else
        (k, v) :: (add_to_alist key value tail);;


(* rules: rule list == (awksub_nonterminals * symbol list) list *)
(* construct_map_from_rules: (awksub_nonterminals * symbol list) list -> (awksub_nonterminals * symbol list list) list *)

let construct_map_from_rules rules =
  List.fold_left (fun acc (non_terminal, expansion) ->
    add_to_alist non_terminal expansion acc
  ) [] rules;;

(* convert_grammar: awksub_nonterminals * (awksub_nonterminals * symbol list) list ->  awksub_nonterminals * (awksub_nonterminals -> symbol list list) *)

let convert_grammar gram1 =
  let (start_symbol, rules) = gram1 in
  let expansions_alist = construct_map_from_rules rules in
  let expansion_function non_terminal =
    match List.assoc_opt non_terminal expansions_alist with
    | Some expansions -> expansions
    | None -> []  (* Handle non-terminal with no expansions *)
  in
  (start_symbol, expansion_function);;


(* 2. As another warmup, write a function parse_tree_leaves tree that traverses the parse tree tree left to right and yields a 
   list of the leaves encountered, in order. *)

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

let rec parse_tree_leaves tree =
  match tree with
  | Leaf terminal -> [terminal]
  | Node (_, children) -> 
    List.fold_left (fun acc child -> 
        acc @ parse_tree_leaves child) [] children;;


(* 3. Write a function make_matcher gram that returns a matcher for the grammar gram. When applied to an acceptor accept and a 
   fragment frag, the matcher must try the grammar rules in order and return the result of calling accept on the suffix 
   corresponding to the first acceptable matching prefix of frag; this is not necessarily the shortest or the longest acceptable 
   match. A match is considered to be acceptable if accept succeeds when given the suffix fragment that immediately follows the 
   matching prefix. When this happens, the matcher returns whatever the acceptor returned. If no acceptable match is found, the 
   matcher returns None. *)

let make_matcher gram =
  let rule_matcher_func = snd gram in (* this will return the second item in the tuple (the function) *)
  let start_sym = fst gram in (* this will return the first item in the tuple (the start symbol) *)

  let rec try_expansions expansions accept frag = 
      match expansions with
      | [] -> None (* base case *)
      | h :: t ->
        match match_seq h accept frag with
        | None -> try_expansions t accept frag (* acceptor is not happy, try the other rules *)
        | Some x -> Some x (* acceptor is happy *)

  and match_seq rule accept frag = 
      match rule with
      | [] -> accept frag
      | sym :: syms -> 
        match sym with
        | N nonterminal ->
            let expansions = rule_matcher_func nonterminal in
            try_expansions expansions (fun frag -> match_seq syms accept frag) frag
        | T terminal -> 
            match frag with 
            (* keep going in the recursion *)
            | h :: t when terminal = h -> match_seq syms accept t
            | _ -> None (* "backtrack" here *)

  in

  let start_expanded = rule_matcher_func start_sym in (* this will return all the possible rules for our start symbol *)


  try_expansions start_expanded (* remove accept and frag bc pfa *);;
 
(* 4. Write a function make_parser gram that returns a parser for the grammar gram. When applied to a fragment frag, the parser 
   returns an optional parse tree. If frag cannot be parsed entirely (that is, from beginning to end), the parser returns None. 
   Otherwise, it returns Some tree where tree is the parse tree corresponding to the input fragment. Your parser should try grammar 
   rules in the same order as make_matcher.
*)

let parse_tree_acceptor frag tree = (*this*)
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
  fun frag -> try_expansions start_sym start_expanded parse_tree_acceptor frag [];;


(* 5. Write one good, nontrivial test case for your make_matcher function. It should be in the style of the test cases given below, 
   but should cover different problem areas. Your test case should be named make_matcher_test. Your test case should test a grammar
   of your own.
*)

(* 6. Similarly, write a good test case make_parser_test for your make_parser function using your same test grammar. This test should
   check that parse_tree_leaves is in some sense the inverse of make_parser gram, in that when make_parser gram frag returns Some tree, 
   then parse_tree_leaves tree equals frag.
*)

(* 7. Assess your work by writing an after-action report that explains why you decided to write make_parser in terms of make_matcher, 
   or vice versa, or neither; and if it's "neither" then briefly explain the approach that you took to avoid duplication in the two 
   functions. Also, explain any weaknesses in your solution in the context of its intended application. If possible, illustrate weaknesses 
   by test cases that fail with your implementation. This report should be a simple ASCII plain text file that consumes a page or so (at 
   most 100 lines and 80 columns per line, and at least 50 lines, please). See Resources for oral presentations and written reports for 
   advice on how to write assessments; admittedly much of the advice there is overkill for the simple kind of report we're looking for here.
*)