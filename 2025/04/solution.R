library(readr)
library(stringr)
library(tidyverse)

grid <- read_lines("input.txt") |>
  str_split("", simplify=TRUE)

offsets <- expand.grid(dr = -1:1, dc = -1:1) |>
  filter(dr != 0 | dc != 0)

df <- as_tibble(grid) |>
  mutate(row=row_number()) |>
  pivot_longer(-row, names_to="col", values_to="val") |>
  mutate(col = as.integer(str_remove(col, "V"))) |>
  mutate(is_roll=val=="@") |>
  select(-val)

last_view_time <- Sys.time() - 999
debounced_view <- function(df) {
  if (as.numeric(Sys.time() - last_view_time, units = "secs") >= 2) {
    View(df, "grid_state")
    last_view_time <<- Sys.time()
  }
}

with_accessible_rolls_recursively_removed <- function(df, max_iters = -1) {
  neighbors <- offsets |>
    crossing(df) |>
    mutate(row2=row+dr, col2=col+dc) |>
    left_join(df, by=c("row2"="row", "col2"="col"), suffix=c("", "_neighbor")) |>
    rename(neighbor_is_roll=is_roll_neighbor) |>
    mutate(neighbor_is_roll=replace_na(neighbor_is_roll, FALSE))
  
  accessibility_df <- neighbors |>
    group_by(row, col) |>
    summarize(
      adjacent_rolls_count=sum(neighbor_is_roll),
      is_roll=first(is_roll),
      .groups = "drop"
    ) |>
    ungroup() |>
    mutate(adjacent_rolls_count=replace_na(adjacent_rolls_count, 0)) |>
    mutate(accessible=adjacent_rolls_count < 4) |>
    select(-adjacent_rolls_count)
  
  state_visual <- accessibility_df |>
    mutate(is_roll=if_else(is_roll, "@", ".")) |>
    select(-accessible) |>
    pivot_wider(values_from=is_roll, names_from=col)
  
  debounced_view(state_visual)
  
  has_accessible_rolls <- accessibility_df |>
    filter(accessible & is_roll) |>
    nrow() > 0
  
  if (!has_accessible_rolls | max_iters == 0) {
    return(accessibility_df)
  }
  
  grid_with_accessible_rolls_removed <- accessibility_df |>
    mutate(is_roll=if_else(accessible & is_roll, FALSE, is_roll))

  return(Recall(
    grid_with_accessible_rolls_removed,
    max_iters=max_iters-1
  ))
}

part1_state_df <- with_accessible_rolls_recursively_removed(df, 0)

part1_accessibility_count <- part1_state_df |>
  filter(accessible & is_roll) |>
  nrow()
part1_accessibility_count

final_state_df <- with_accessible_rolls_recursively_removed(df)

initial_roll_count <- part1_state_df |>
  filter(is_roll) |>
  nrow()

final_roll_count <- final_state_df |>
  filter(is_roll) |>
  nrow()

part2_result <- initial_roll_count - final_roll_count
part2_result
