main :-
    read_grid('input.txt', Grid),
    count_universes(Grid, TotalUniverses),
    format('Part 2: total universes: ~d~n', [TotalUniverses]).

read_grid(Path, Grid) :-
    read_file_to_string(Path, Content, []),
    split_string(Content, "\n", "", Lines),
    include(\=(""), Lines, NewLines),
    maplist(string_chars, NewLines, Grid).

next_col(Col, NextRow, NextCol) :-
  nth0(Col, NextRow, CellBelow),
  (CellBelow = '^' -> (NextCol is Col - 1; NextCol is Col + 1);  NextCol = Col).

:- table path_count/3.

path_count([_], _, 1).

path_count([CurrentRow|RestRows], Col, TotalCount) :-
    findall(Count,
            (
              next_col(Col, CurrentRow, NextCol),
              path_count(RestRows, NextCol, Count)
            ),
            Counts),
    sum_list(Counts, TotalCount).

start_col(Row, Col) :- nth0(Col, Row, 'S').

count_universes(Grid, Total) :-
    Grid = [FirstRow|_],
    start_col(FirstRow, StartCol),
    path_count(Grid, StartCol, Total).
