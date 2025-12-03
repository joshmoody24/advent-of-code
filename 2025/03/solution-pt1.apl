(lines enc eol) ← ⎕NGET 'input.txt' 1
rows ← {(⎕D⍳⍵) - 1}¨ lines
first_digit_candidates ← {¯1↓⍵}¨ rows
find_max_index ← {⍵⍳⌈/⍵}¨
first_digit_indexes ← find_max_index first_digit_candidates
second_digit_candidates ← first_digit_indexes ↓¨ rows
second_digit_indexes ← first_digit_indexes +¨ find_max_index second_digit_candidates
row_values ← (10 × first_digit_indexes ⌷¨ rows) + (second_digit_indexes ⌷¨ rows)
⎕ ← +/ row_values
