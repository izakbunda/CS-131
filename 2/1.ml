(* 1. To warm up, notice that the format of grammars is different in this assignment, versus Homework 1. Write a function 
   convert_grammar gram1 that returns a Homework 2-style grammar, which is converted from the Homework 1-style grammar gram1. 
   Test your implementation of convert_grammar on the test grammars given in Homework 1. For example, the top-level 
   definition let awksub_grammar_2 = convert_grammar awksub_grammar should bind awksub_grammar_2 to a Homework 2-style grammar 
   that is equivalent to the Homework 1-style grammar awksub_grammar.
*)

(* 
    type ('nonterminal, 'terminal) symbol =
        | N of 'nonterminal
        | T of 'terminal

    type awksub_nonterminals =
        | Expr
        | Lvalue
        | Incrop
        | Binop
        | Num

    grammar from hw1:

    let rule = awksub_nonterminals * symbol list
    let gram1 = awksub_nonterminals * rule list

    grammar from hw2:

    let gram2 = awksub_nonterminals * (awksub_nonterminals -> symbol list list)
 *)


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
        (k, v) :: (add_to_alist key value tail)  


(* rules: rule list == (awksub_nonterminals * symbol list) list *)
(* construct_map_from_rules: (awksub_nonterminals * symbol list) list -> (awksub_nonterminals * symbol list list) list *)

let construct_map_from_rules rules =
  List.fold_left (fun acc (non_terminal, expansion) ->
    add_to_alist non_terminal expansion acc
  ) [] rules

(* convert_grammar: awksub_nonterminals * (awksub_nonterminals * symbol list) list ->  awksub_nonterminals * (awksub_nonterminals -> symbol list list) *)

let convert_grammar gram1 =
  let (start_symbol, rules) = gram1 in
  let expansions_alist = construct_map_from_rules rules in
  let expansion_function non_terminal =
    match List.assoc_opt non_terminal expansions_alist with
    | Some expansions -> expansions
    | None -> []  (* Handle non-terminal with no expansions *)
  in
  (start_symbol, expansion_function)


type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let awksub1_rules =
   [
    Expr, [N Term; N Binop; N Expr];
    Expr, [N Term];
    Term, [N Num];
    Term, [N Lvalue];
    Term, [N Incrop; N Lvalue];
    Term, [N Lvalue; N Incrop];
    Term, [T"("; N Expr; T")"];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];
    Num, [T"1"];
    Num, [T"2"];
    Num, [T"3"];
    Num, [T"4"];
    Num, [T"5"];
    Num, [T"6"];
    Num, [T"7"];
    Num, [T"8"];
    Num, [T"9"]
  ]

let awksub1_grammar = Expr, awksub1_rules

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

let converted_gram = convert_grammar awksub1_grammar

let test0 = 
  (snd converted_gram) Num = [[T "0"]; [T "1"]; [T "2"]; [T "3"]; [T "4"]; 
  [T "5"]; [T "6"]; [T "7"]; [T "8"]; [T "9"]]

let test1 = (snd converted_gram) Incrop = [[T"++"]; [T"--"]]

let test2 = (snd converted_gram) Lvalue = [[T"$"; N Expr]]

let test3 = (snd converted_gram) Expr = [[N Term; N Binop; N Expr]; [N Term]]

