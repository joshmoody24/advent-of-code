const fs = require("fs");
const input = fs.readFileSync("input.txt", "utf-8");

const values = input
  .trim()
  .split("\n")
  .map((row) => row.split(/\s+/).filter(Boolean));

const rows = values.slice(0, -1);
const ops = values.at(-1);
const reducers = {
  "+": (a, b) => a + b,
  "*": (a, b) => a * b,
};
const init = {
  "+": 0,
  "*": 1,
};

const reduceColumn = (colIndex, operation) => {
  return rows.reduce((acc, row) => {
    const value = parseInt(row[colIndex]);
    return reducers[operation](acc, value);
  }, init[operation]);
};

const results = ops.map((op, index) => reduceColumn(index, op));
console.log(
  "Part 1: ",
  results.reduce((a, b) => a + b, 0),
);
