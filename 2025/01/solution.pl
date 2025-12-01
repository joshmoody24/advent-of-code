:- use_module(library(dcg/basics)).

% Input parsing

line(rot_l(N)) -->
    "L",
    integer(N),
    eos.

line(rot_r(N)) -->
    "R",
    integer(N),
    eos.

parse_line_string(LineStr, Line) :-
    string_codes(LineStr, Codes),
    phrase(line(Line), Codes).

read_lines(File, Lines) :-
    read_file_to_string(File, S, []),
    split_string(S, "\n", "\n", RawLines),
    exclude(=(""), RawLines, NonEmptyLines),
    maplist(parse_line_string, NonEmptyLines, Lines).

% Rotation logic

rotation_n(100).
starting_rotation(50).

rotation_value(rot_r(N), N).
rotation_value(rot_l(N), -N).

distance_to_zero(PrevState, Delta, Distance) :-
    rotation_n(Max),
    (
      Delta < 0 -> Distance = (PrevState - 1) mod Max + 1;
      Distance = (Max - PrevState)
    ).

rotation(PrevState, R, NewState, NumZeroCrosses) :-
    rotation_n(Max),
    rotation_value(R, Delta),
    NewState is (PrevState + Delta) mod Max,
    distance_to_zero(PrevState, Delta, DistanceToZero),
    NumZeroCrosses is (abs(Delta) + Max - DistanceToZero) // Max.

rotation_states(InitialState, [], [InitialState], []).
rotation_states(InitialState, [H|T], [InitialState|RestStates], [ZeroCrosses|RestZeroCrosses]) :-
    rotation(InitialState, H, NewState, ZeroCrosses),
    rotation_states(NewState, T, RestStates, RestZeroCrosses).
    
% Part 1

zero_count_pt1([], 0).
zero_count_pt1([0|T], Count) :-
    zero_count_pt1(T, RestCount),
    Count is RestCount + 1.
zero_count_pt1([H|T], Count) :-
    H \= 0,
    zero_count_pt1(T, Count).

output_password_pt1(Lines, Output) :-
    starting_rotation(Start),
    rotation_states(Start, Lines, States, _),
    zero_count_pt1(States, Output).

% Part 2

zero_count_pt2(ZeroCrosses, Output) :-
    sum_list(ZeroCrosses, Output).

output_password_pt2(Lines, Output) :-
    starting_rotation(Start),
    rotation_states(Start, Lines, _, ZeroCrosses),
    zero_count_pt2(ZeroCrosses, Output).

% Main

main :-
    read_lines('input.txt', Lines),
    output_password_pt1(Lines, Output),
    format('Number of 0 states (part 1 password): ~w~n', Output),
    output_password_pt2(Lines, Output2),
    format('Sum of 0 crossings (part 2 password): ~w~n', Output2).

