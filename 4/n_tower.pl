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