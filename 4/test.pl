sibling(X,Y):- parent(Z,X), parent(Z,Y).

% recall that lowercase is treated as value
% and uppercase is treated as logical variable

parent(joe, alice). 
parent(joe, bob).

% intuition:
% if sorted(Y) and perm(X,Y)
% so let's define sorted and perm even though they are both built in

% implementation of sorted:

sorted([]).
sorted([X]).
sorted([X,Y|L]) :- X =< Y, sorted([Y|L]).

% implementation of perm:

% without(E, L, R) true if L with the first instance of E is R
% without(E, [], []).
without(E, [E], []).
without(E, [H|T], T) :- (E = H).
% if we have E and it doesn't match something in the head, then we want to call it 
without(E, [H|T],[H|R]) :- \+ (E = H), without(E, T, R). 

% permutation
perm([],[]).
perm([H], [H]).
perm([H|T], L) :- without(H, L, R), perm(T, R).


sort([],[]). % base case
sort(X,Y) :- sorted(Y), perm(X, Y). % recursive rule


