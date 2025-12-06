const fs = require("fs");
const input = fs.readFileSync("input.txt", "utf-8");

const rawRows = input.split("\n").filter((row) => row.length);

function getColumnsWithOnlySpaces(rows) {
  const cols = Math.max(...rows.map((row) => row.length));
  const columns = [];
  for (let col = 0; col < cols; col++) {
    let onlySpaces = true;
    for (let row = 0; row < rows.length; row++) {
      if (rows[row][col] && rows[row][col].trim() !== "") {
        onlySpaces = false;
        break;
      }
    }
    if (onlySpaces) {
      columns.push(col);
    }
  }
  return columns;
}

function splitOnColumns(str, columns) {
  let result = [];
  let prev = 0;

  for (let col of columns) {
    result.push(str.slice(prev, col));
    prev = col + 1;
  }

  result.push(str.slice(prev));
  return result;
}

const columnsWithOnlySpaces = getColumnsWithOnlySpaces(rawRows);
console.log("Columns with only spaces at:", columnsWithOnlySpaces);

const rows = rawRows.map((row) => splitOnColumns(row, columnsWithOnlySpaces));

const transpose = (grid) =>
  grid[0].map((_, colIndex) => grid.map((row) => row[colIndex]));

const rawCols = transpose(rows);
const cols = rawCols.map((col) => {
  const withoutOp = col.slice(0, -1);
  return withoutOp;
});
const ops = rawCols.map((col) => col.at(-1).trim());

const reducer = {
  "+": (a, b) => a + b,
  "*": (a, b) => a * b,
};
const init = {
  "+": 0,
  "*": 1,
};

const numberFromCol = (col, charIndex) => {
  const strNum = col
    .map((s) => s[charIndex] ?? "")
    .join("")
    .trim();
  return strNum ? parseInt(strNum) : null;
};

const colReduce = (col, op) =>
  col.reduce((acc, _, index) => {
    const number = numberFromCol(col, index);
    return number ? reducer[op](acc, number) : acc;
  }, init[op]);

const sumOfCols = cols.map((col, index) => colReduce(col, ops[index]));

console.log(
  "Part 2: ",
  sumOfCols.reduce((a, b) => a + b, 0),
);
