(* 9. Write a function filter_blind_alleys g that returns a copy of the grammar g with all blind-alley rules removed. 
   This function should preserve the order of rules: that is, all rules that are returned should be in the same order as the rules in g.*)

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*---------------------------------------------------------------------------------------------------*)

(* : ('a -> 'a -> bool) -> ('a -> 'a) -> 'a -> 'a *)
let rec computed_fixed_point eq f x =
  let result = f x in
  if eq x result then
    x
  else
    computed_fixed_point eq f (f x)

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

(*---------------------------------------------------------------------------------------------------*)


(* Checks if all symbols in a sequence can lead to terminal strings *)
let rec rhs_symbols_terminal rhs known_terminals = match rhs with
  | [] -> true
  | h::t -> 
      (match h with 
      | T _ -> true
      | N _ -> List.mem h known_terminals) && rhs_symbols_terminal t known_terminals

(* Updates the list of known terminal symbols based on current rules *)
let rec update_terminal_symbols rules current_terminals = match rules with
  | [] -> current_terminals
  | (symbol, rhs)::remaining_rules -> let new_terminals = 
                                      if rhs_symbols_terminal rhs current_terminals then N symbol :: current_terminals
                                      else current_terminals 
   in
   update_terminal_symbols remaining_rules new_terminals

(* FUnction for checking if terminal symbol sets are equal using eqaul_sets *)
let terminal_sets_equal (x, terminals1) (y, terminals2) = equal_sets terminals1 terminals2

(* Repeatedly identifies terminal symbols until no new ones are found *)
let identify_terminal_symbols rules = 
  computed_fixed_point terminal_sets_equal (fun (r, ts) -> (r, update_terminal_symbols r ts)) (rules, [])

(* Filters out rules that do not lead to terminal strings *)
let rec filter_non_terminal_rules (rules, known_terminals) = match rules with 
  | [] -> []
  | (symbol, rhs)::remaining_rules -> 
      if rhs_symbols_terminal rhs known_terminals then
        (symbol, rhs) :: filter_non_terminal_rules (remaining_rules, known_terminals)
      else
        filter_non_terminal_rules (remaining_rules, known_terminals)

(* Main function to remove blind alley rules from a grammar *)
let filter_blind_alleys g =
   match g with
   | (start, []) -> g
   | (start, rules) -> (start, filter_non_terminal_rules (identify_terminal_symbols rules));;


(* An example grammar for a small subset of Awk.  *)

type awksub_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num

let awksub_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
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
    Num, [T"9"]]

let awksub_grammar = Expr, awksub_rules

let awksub_test0 =
  filter_blind_alleys awksub_grammar = awksub_grammar

let awksub_test1 =
  filter_blind_alleys (Expr, List.tl awksub_rules) = (Expr, List.tl awksub_rules)

let awksub_test2 =
  filter_blind_alleys (Expr,
      [Expr, [N Num];
       Expr, [N Lvalue];
       Expr, [N Expr; N Lvalue];
       Expr, [N Lvalue; N Expr];
       Expr, [N Expr; N Binop; N Expr];
       Lvalue, [N Lvalue; N Expr];
       Lvalue, [N Expr; N Lvalue];
       Lvalue, [N Incrop; N Lvalue];
       Lvalue, [N Lvalue; N Incrop];
       Incrop, [T"++"]; Incrop, [T"--"];
       Binop, [T"+"]; Binop, [T"-"];
       Num, [T"0"]; Num, [T"1"]; Num, [T"2"]; Num, [T"3"]; Num, [T"4"];
       Num, [T"5"]; Num, [T"6"]; Num, [T"7"]; Num, [T"8"]; Num, [T"9"]])
  = (Expr,
     [Expr, [N Num];
      Expr, [N Expr; N Binop; N Expr];
      Incrop, [T"++"]; Incrop, [T"--"];
      Binop, [T "+"]; Binop, [T "-"];
      Num, [T "0"]; Num, [T "1"]; Num, [T "2"]; Num, [T "3"]; Num, [T "4"];
      Num, [T "5"]; Num, [T "6"]; Num, [T "7"]; Num, [T "8"]; Num, [T "9"]])

let awksub_test3 =
  filter_blind_alleys (Expr, List.tl (List.tl (List.tl awksub_rules))) =
    filter_blind_alleys (Expr, List.tl (List.tl awksub_rules))

type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet

let giant_grammar =
  Conversation,
  [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation]]

let giant_test0 =
  filter_blind_alleys giant_grammar = giant_grammar

let giant_test1 =
  filter_blind_alleys (Sentence, List.tl (snd giant_grammar)) =
    (Sentence,
     [Quiet, []; Grunt, [T "khrgh"]; Shout, [T "aooogah!"];
      Sentence, [N Quiet]; Sentence, [N Grunt]; Sentence, [N Shout]])

let giant_test2 =
  filter_blind_alleys (Sentence, List.tl (List.tl (snd giant_grammar))) =
    (Sentence,
     [Grunt, [T "khrgh"]; Shout, [T "aooogah!"];
      Sentence, [N Grunt]; Sentence, [N Shout]])