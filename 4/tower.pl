%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PLAIN_NTOWER %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

plain_ntower(N,T,C) :-
    nxn_grid(N,T), % RULE 1
    % print("x"),
    valid_state_of_board(N, T, C), % RULE 2 AND 3
    % print("y"),
    C = counts(Up, Down, Left, Right). % Unify counts with C

%%%%%%%%%%%%%%%%%%%%%
% RULE #1: NXN GRID %
%%%%%%%%%%%%%%%%%%%%%

% Check that T has N sublists
number_of_sublists(N,T) :- length(T, N).

% Check that each sublist has N items
items_in_sublist(1, [[]]).
items_in_sublist(N, T) :-
    N \= 1, 
    maplist(length_helper(N), T).

% Predicate for maplist in items_in_sublist
% to apply to each sublist in T
length_helper(N, List) :- length(List, N).

% Combines number_of_sublists and items_in_sublists
nxn_grid(N,T) :-
    number_of_sublists(N,T),
    items_in_sublist(N,T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RULE #2: VALID STATE OF THE BOARD %  (But RULE #3 is also used here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% valid range is so important without this we will get instantiation errors
% because when creating T (i.e. calling the predicate with an uninstantiated T)
% we need something to start from
valid_state_of_board(N, T, counts(Up, Down, Left, Right)) :-
	valid_range(1, N, Range1N),

	valid_state(N, Range1N, T, Left, Right),
	transpose(T, T_Transposed),
	valid_state(N, Range1N, T_Transposed, Up, Down).

% SUBPROBLEM:
% Ensure the entire game board is in a valid state according to the following criteria:
% 1. Each row and column must contain unique numbers from 1 to N... (check_row_col)
% 3. The visible towers from each side (left, right, up, down) must match the given L, U and R, D
valid_state(_, _, [], [], []).
valid_state(N, Range1N, [H|T], [H_Left_Up|Tail_Left_Up], [H_Right_Down|Tail_Right_down]) :-
	check_row_col(Range1N, H), % apply to all sublists of T

     % checked all rows from left OR up
	proper_tower_view(H, 0, 0, H_Left_Up),
	reverse(H, H_Reversed),
    
     % then checks all rows from right OR down
	proper_tower_view(H_Reversed, 0, 0, H_Right_Down),
	valid_state(N, Range1N, T, Tail_Left_Up, Tail_Right_down).

% SUBPROBLEM: Each row/col has to be s doku-like
% 1. Unique numbers from 1 to N
% 2. All numbers from 1 to N must be present
check_row_col(_, []). 
check_row_col(Range1N, [H|T]) :- 
	member(H, Range1N), 
	remover(H, Range1N, New_Range1N), % Then get rid of it
	check_row_col(New_Range1N, T).

%% RULE #2 HELPER-HELPERS %%

% Make a list from 1 to N so we have an existing T % NO INSTANTIATION ERROR
valid_range(Min, Max, [Min|T]) :-
	Min =< Max,
	Next_Val is Min + 1,
	valid_range(Next_Val, Max, T).
valid_range(Min, Max, [Max|[]]) :- Min is Max.

% removes element frm list
remover( _, [], []).
remover( E, [E|T], T).
remover( E, [H|T], [H|Res]) :- 
    H \= E, 
    remover( E, T, Res).

transpose([], []).
transpose([F|Fs], Ts) :- transpose(F, [F|Fs], Ts).
transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
    split_col(Ms, Ts, Ms1),
    transpose(Rs, Ms1, Tss).

% Credit to TA Jason Cheng for split_col :)
split_col([],[],[]).
split_col(M,C,R) :-
    M = [M1|Ms],
    M1 = [C1|R1],
    split_col(Ms,Cs,Rs),
    C = [C1|Cs],
    R = [R1|Rs].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RULE #3: PROPER TOWER VIEW %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If the current tower is taller than any previously encountered tower,
% it is considered visible. Increase the visible count and continue with this tower as the new max height.
proper_tower_view([H|T], Max_Tower_Height, Visible, Final) :-
	(H > Max_Tower_Height), 
    New_Visible is Visible + 1,
	proper_tower_view(T, H, New_Visible, Final).
proper_tower_view([], _, Visible, Visible).

% If the current tower is not taller than the max height encountered so far,
% it is not considered visible. Do not increase the visible count and continue with the same max height.
proper_tower_view([H|T], Max_Tower_Height, Visible, Final) :-
	H =< Max_Tower_Height,
	proper_tower_view(T, Max_Tower_Height, Visible, Final).

%%%%%%%%%%%%%%%%%%
%%%%% NTOWER %%%%%
%%%%%%%%%%%%%%%%%%

ntower(N, T, counts(Up, Bottom, Left, Right)) :-
    nxn_grid(N,T), % RULE 1

    % RULE 2 and Rule 3
    unique_domain(N, T),
    maplist(fd_labeling, T),

    fd_valid_state(T, Left, Right),
	transpose(T, T_Transposed),
	fd_valid_state(T_Transposed, Up, Bottom).

%%%%%%%%%%%%%%%%%%%%%
% RULE #1: NXN GRID %
%%%%%%%%%%%%%%%%%%%%%

%  Use same code from plain_ntower

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RULE #2: VALID STATE OF THE BOARD %  (But RULE #3 is also used here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

unique_domain(N, T) :-
	unique_domain_row_col(N, T),

    transpose(T, T_Transposed),
	unique_domain_row_col(N, T_Transposed).

unique_domain_row_col(_, []).
unique_domain_row_col(N, [H|T]) :-
	fd_domain(H, 1, N), % .......
	fd_all_different(H), % ...
	unique_domain_row_col(N, T).

% Same logic as above but we don't need check_row_col or valid_range anymore
fd_valid_state([], [], []).
fd_valid_state([H|T], [H_Left_Up|Tail_Left_Up], [H_Right_Down|Tail_Right_down]) :-

     % checked all rows from left OR up
	proper_tower_view(H, 0, 0, H_Left_Up),
	reverse(H, H_Reversed),

    % then checks all rows from right OR down
	proper_tower_view(H_Reversed, 0, 0, H_Right_Down),
	fd_valid_state(T, Tail_Left_Up, Tail_Right_down).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RULE #3: PROPER TOWER VIEW %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Use same code from plain_ntower

%%%%%%%%%%%%%%%%%%%%%
%%%%% AMBIGUOUS %%%%%
%%%%%%%%%%%%%%%%%%%%%

ambiguous(N, C, T1, T2) :-
	ntower(N, T1, C),
	ntower(N, T2, C),
	T1 \= T2.