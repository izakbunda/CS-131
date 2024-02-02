(* 3. Write a function make_matcher gram that returns a matcher for the grammar gram. When applied to an acceptor accept and a 
   fragment frag, the matcher must try the grammar rules in order and return the result of calling accept on the suffix 
   corresponding to the first acceptable matching prefix of frag; this is not necessarily the shortest or the longest acceptable 
   match. A match is considered to be acceptable if accept succeeds when given the suffix fragment that immediately follows the 
   matching prefix. When this happens, the matcher returns whatever the acceptor returned. If no acceptable match is found, the 
   matcher returns None. *)

