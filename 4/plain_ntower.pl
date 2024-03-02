%%%%%%%%%%%%%%%%%%
%% PLAIN_NTOWER %%
%%%%%%%%%%%%%%%%%%

plain_n_tower(N,T,C) :-
    nxn_grid(N,T), % RULE 1
    print("x"),
    valid_state_of_board(N,T), % RULE 2
    print("y"),
    proper_tower_view(T, Up, Down, Left, Right), % RULE 3
    print("z"),
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
% RULE #2: VALID STATE OF THE BOARD %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ensure each element in T is an integer between 1 and N.
list_range(N, T) :-
    maplist(between(1, N), T).

% Check that it is a valid state of the board.
valid_state_of_board(N, T) :-
    length(T, N), % Ensure T has N rows.
    maplist(length_helper(N), T), % Ensure each row has N elements.
    maplist(list_range(N), T), % Apply list_range to each row.
    transpose(T, T_Transposed),
    maplist(check_unique_row(N), T), % Ensure each row has unique values.
    maplist(check_unique_row(N), T_Transposed). % Ensure each column has unique values.

% Ensure each row has unique values from 1 to N.
check_unique_row(N, Row) :-
    length(Row, N), % Ensure the row has N elements.
    numlist(1, N, Expected), % Generate the list of expected values from 1 to N.
    permutation(Expected, Row). % Check if Row is a permutation of Expected.

% Base case: When Start is greater than End, the list is empty.
numlist(Start, End, []) :- Start > End.

% Recursive case: Include Start in the list and recurse for the next number.
numlist(Start, End, [Start|Tail]) :-
    Start =< End,
    Next is Start + 1,
    numlist(Next, End, Tail).

% Transpose function
transpose([], []).
transpose([F|Fs], Ts) :- transpose(F, [F|Fs], Ts).
transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
    split_col(Ms, Ts, Ms1),
    transpose(Rs, Ms1, Tss).

% Credit to Jason Cheng for split_col :)
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

proper_tower_view(T, Up, Down, Left, Right) :-

    % LEFT
    check_count_applied(T,Left),

    % RIGHT (reverse)
    maplist(reverse,T,Reversed_Rows),
    check_count_applied(Reversed_Rows,Right),

    % UP (transpose)
    transpose(T,T_Transposed),
    check_count_applied(T_Transposed,Up),

    % DOWN (reverse)
    maplist(reverse,T_Transposed,T_Reversed_Transposed),
    check_count_applied(T_Reversed_Transposed,Down).

check_count([H|T],Max_Tower_Height,Visible,Final) :-
    % if then else === __ -> __ | or === ;
    ((H > Max_Tower_Height) -> New_Visible is Visible + 1; New_Visible = Visible),
    New_Max_Tower_Height is max(H,Max_Tower_Height),
    check_count(T,New_Max_Tower_Height,New_Visible,Final).
check_count([],_,Visible,Visible).

check_count_init(Row_Col,Expected_Count) :-
    check_count(Row_Col,0,0,Visible_Towers),
    Visible_Towers = Expected_Count. % Wont stop till this

check_count_applied(Row_Col,View_Counts) :-
    maplist(check_count_init,Row_Col,View_Counts).







