(* 3. Write a function make_matcher gram that returns a matcher for the grammar gram. When applied to an acceptor accept and a 
   fragment frag, the matcher must try the grammar rules in order and return the result of calling accept on the suffix 
   corresponding to the first acceptable matching prefix of frag; this is not necessarily the shortest or the longest acceptable 
   match. A match is considered to be acceptable if accept succeeds when given the suffix fragment that immediately follows the 
   matching prefix. When this happens, the matcher returns whatever the acceptor returned. If no acceptable match is found, the 
   matcher returns None. *)


(*

   try_expansions: iterates over a list of alternatives (rules for a non-terminal) and tries each one until it finds a match or exhausts the list.
   match_sequence: attempts to match a single rule (a sequence of symbols) against the input fragment.

*)


type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

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


   try_expansions start_expanded (* remove accept and frag bc pfa *)

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
 
let make_matcher_test_genz =
   let accept_all string = Some string in
   ((make_matcher genz_grammar accept_all ["Hey"; "Mother"; "Periodt"])
      = Some [])


          