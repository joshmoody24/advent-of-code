:- module solution1.

:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module char, int, list, string.

:- func empty = char.
:- func laser = char.
:- func splitter = char.

empty = ('.').
laser = ('|').
splitter = ('^').

main(!IO) :-
    read_grid("input.txt", Grid, !IO),
    processed_grid(Grid, FinalGrid, TotalSplits),
    % io.write_string("Final grid:\n", !IO),
    % print_grid(FinalGrid, !IO),
    io.format("Part 1: total splits: %d\n", [i(TotalSplits)], !IO).

% Grid utils

:- pred read_grid(string::in, list(list(char))::out, io::di, io::uo) is det.
read_grid(Path, Grid, !IO) :-
    io.open_input(Path, Result, !IO),
    (
        Result = ok(Stream),
        read_lines(Stream, Lines, !IO),
        io.close_input(Stream, !IO),
        Grid = list.map(string.to_char_list, Lines)
    ;
        Result = error(Error),
        io.format("Failed to open '%s': %s\n", [s(Path), s(io.error_message(Error))], !IO),
        Grid = []
    ).

:- pred print_grid(list(list(char))::in, io::di, io::uo) is det.
print_grid([], !IO).
print_grid([Row | Rows], !IO) :-
    io.write_string(string.from_char_list(Row), !IO),
    io.nl(!IO),
    print_grid(Rows, !IO).

% Generic IO utils

:- pred read_lines(io.input_stream::in, list(string)::out,
    io::di, io::uo) is det.
read_lines(Stream, Lines, !IO) :-
    io.read_line_as_string(Stream, Result, !IO),
    (
        Result = ok(Line0),
        Line = string.replace_all(string.chomp(Line0), "S", "|"),
        read_lines(Stream, Rest, !IO),
        ( if Line = "" then Lines = Rest else Lines = [Line | Rest] )
    ;
        Result = eof,
        Lines = []
    ;
        Result = error(_),
        Lines = []
    ).

% Core logic

:- pred processed_grid(
     list(list(char))::in,
     list(list(char))::out, int::out
   ) is det.

processed_grid([], [], 0).
processed_grid(Grid @ [First | _], NewGrid, Splits) :-
    EmptyRow = list.duplicate(list.length(First), empty),
    processed_rows(EmptyRow, Grid, NewGrid, 0, Splits).

:- pred processed_rows(
     list(char)::in, list(list(char))::in,
     list(list(char))::out, int::in, int::out
   ) is det.

processed_rows(_, [], [], !Splits).
processed_rows(Above, [Row | Rows], [NewRow | NewRows], !Splits) :-
    process_row(Above, Row, NewRow, RowSplits),
    !:Splits = !.Splits + RowSplits,
    processed_rows(NewRow, Rows, NewRows, !Splits).

:- pred process_row(
     list(char)::in, list(char)::in,
     list(char)::out, int::out
   ) is det.

process_row(Above, Current, NewRow, Splits) :-
    processed_cells(empty, empty, Above, Current, NewRow, 0, Splits).

:- pred processed_cells(
     char::in, char::in, list(char)::in, list(char)::in,
     list(char)::out, int::in, int::out
   ) is det.

processed_cells(_, _, [], [], [], !Splits).
processed_cells(_, _, [], [_ | _], [], !Splits).
processed_cells(_, _, [_ | _], [], [], !Splits).
processed_cells(AL, CL, [AM | ARest], [C | CRest], [NewC | NewRest], !Splits) :-
    AR = ( if ARest = [X | _] then X else empty ),
    CR = ( if CRest = [Y | _] then Y else empty ),
    processed_cell(AL, AM, AR, CL, C, CR, NewC, CellSplits),
    !:Splits = !.Splits + CellSplits,
    processed_cells(AM, C, ARest, CRest, NewRest, !Splits).

:- pred processed_cell(
    char::in, char::in, char::in, char::in, char::in, char::in,
    char::out, int::out
) is det.

processed_cell(AboveL, AboveM, AboveR, CurrL, C, CurrR, NewC, Splits) :-
    (
        C = empty, AboveM = laser -> NewC = laser, Splits = 0;
        C = empty, AboveL = laser, CurrL = splitter -> NewC = laser, Splits = 0;
        C = empty, AboveR = laser, CurrR = splitter -> NewC = laser, Splits = 0;
        C = splitter, AboveM = laser -> NewC = splitter, Splits = 1;
        NewC = C, Splits = 0
    ).

:- end_module solution1.
