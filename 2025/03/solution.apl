(lines enc eol) ← ⎕NGET 'input.txt' 1
rows ← {(⎕D⍳⍵) - 1}¨ lines

digits ← 12

find_max_index ← {⍵⍳⌈/⍵}

⍝ The amogus thing is a comment
⍝ ⍺ = current digit (starting from leftmost = 1)
⍝ ⍵ = digits after the previously chosen digit
nth_index ← {
   ⍺=1: find_max_index (-(digits-⍺))↓⍵
   prev_index ← (⍺-1)∇⍵
   candidate_digits ← prev_index↓(-(digits-⍺))↓⍵
   prev_index + find_max_index candidate_digits
}

digit_indexes ← {⍵ nth_index¨ rows}¨⍳digits
digit_values ← ({⍵ ⌷¨ rows}¨digit_indexes)
exponents ← 10 * ¯1 + ⌽⍳digits

⎕PP ← 34
⎕ ← +/ +/¨ exponents × digit_values
