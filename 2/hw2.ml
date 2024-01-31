(* 1. To warm up, notice that the format of grammars is different in this assignment, versus Homework 1. Write a function 
   convert_grammar gram1 that returns a Homework 2-style grammar, which is converted from the Homework 1-style grammar gram1. 
   Test your implementation of convert_grammar on the test grammars given in Homework 1. For example, the top-level 
   definition let awksub_grammar_2 = convert_grammar awksub_grammar should bind awksub_grammar_2 to a Homework 2-style grammar 
   that is equivalent to the Homework 1-style grammar awksub_grammar. *)


(* 2. As another warmup, write a function parse_tree_leaves tree that traverses the parse tree tree left to right and yields a 
   list of the leaves encountered, in order. *)

(* 3. Write a function make_matcher gram that returns a matcher for the grammar gram. When applied to an acceptor accept and a 
   fragment frag, the matcher must try the grammar rules in order and return the result of calling accept on the suffix 
   corresponding to the first acceptable matching prefix of frag; this is not necessarily the shortest or the longest acceptable 
   match. A match is considered to be acceptable if accept succeeds when given the suffix fragment that immediately follows the 
   matching prefix. When this happens, the matcher returns whatever the acceptor returned. If no acceptable match is found, the 
   matcher returns None. *)

(* 4. Write a function make_parser gram that returns a parser for the grammar gram. When applied to a fragment frag, the parser 
   returns an optional parse tree. If frag cannot be parsed entirely (that is, from beginning to end), the parser returns None. 
   Otherwise, it returns Some tree where tree is the parse tree corresponding to the input fragment. Your parser should try grammar 
   rules in the same order as make_matcher.
*)

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