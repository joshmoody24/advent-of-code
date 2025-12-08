main :-
    read_grid('input.txt', Grid),
    process_grid(Grid, _, TotalSplits),
    format('Part 1: total splits: ~d~n', TotalSplits).

read_grid(Path, Grid) :-
    read_file_to_string(Path, Content, []),
    split_string(Content, "\n", "", Lines),
    include(\=(""), Lines, NonEmptyLines),
    maplist(line_to_chars, NonEmptyLines, Grid).

line_to_chars(Line, Chars) :-
    string_chars(Line, Chars0),
    maplist(replace_s, Chars0, Chars).

replace_s('S', '|').
replace_s(C, C).

process_grid([], [], 0).
process_grid([First|Rest], NewGrid, Splits) :-
    length(First, Width),
    length(EmptyRow, Width),
    maplist(=('.'), EmptyRow),
    process_rows(EmptyRow, [First|Rest], NewGrid, 0, Splits).

process_rows(_, [], [], Splits, Splits).
process_rows(Above, [Row|Rows], [NewRow|NewRows], Acc, Splits) :-
    process_row(Above, Row, NewRow, RowSplits),
    Acc1 is Acc + RowSplits,
    process_rows(NewRow, Rows, NewRows, Acc1, Splits).

process_row(Above, Current, NewRow, Splits) :-
    process_cells('.', '.', Above, Current, NewRow, 0, Splits).

process_cells(_, _, [], [], [], Splits, Splits).
process_cells(AL, CL, [AM|ARest], [C|CRest], [NewC|NewRest], Acc, Splits) :-
    (ARest = [AR|_] -> true ; AR = '.'),
    (CRest = [CR|_] -> true ; CR = '.'),
    process_cell(AL, AM, AR, CL, C, CR, NewC, CellSplits),
    Acc1 is Acc + CellSplits,
    process_cells(AM, C, ARest, CRest, NewRest, Acc1, Splits).

process_cell(AboveL, AboveM, AboveR, CurrL, C, CurrR, NewC, Splits) :-
    (
        C = '.', AboveM = '|'              -> NewC = '|', Splits = 0 ;
        C = '.', AboveL = '|', CurrL = '^' -> NewC = '|', Splits = 0 ;
        C = '.', AboveR = '|', CurrR = '^' -> NewC = '|', Splits = 0 ;
        C = '^', AboveM = '|'              -> NewC = '^', Splits = 1 ;
        NewC = C, Splits = 0
    ).
