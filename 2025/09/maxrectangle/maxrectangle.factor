USING: arrays io.encodings.utf8 io.files io.pathnames kernel math math.functions sequences splitting math.parser prettyprint vocabs.loader ;
IN: maxrectangle

: parse-line ( str -- pair )
    "," split [ string>number ] map ;

: read-coords ( path -- pairs )
    utf8 file-lines [ parse-line ] map ;

: all-pairs ( seq -- pairs )
    dup cartesian-product concat ;

: x-dist ( p1 p2 -- n )
    [ first ] dip first - abs 1 + ;

: y-dist ( p1 p2 -- n )
    [ second ] dip second - abs 1 + ;

: rectangle-area ( p1 p2 -- n )
    [ x-dist ] [ y-dist ] 2bi * ;

: with-area ( pair -- tuple )
    dup first2 rectangle-area suffix ;

: main ( -- )
    "maxrectangle" vocab-path parent-directory "input.txt" append-path
    read-coords all-pairs [ with-area ] map [ last neg ] sort-by first last "Part 1: " print . ;
main
