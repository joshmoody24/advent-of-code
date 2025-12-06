const fs = require("fs");
const input = fs.readFileSync("input.txt", "utf-8");

const values = input
  .trim()
  .split("\n")
  .map((row) => row.split(/\s+/).filter(Boolean));
const tableRowsInt = values.slice(0, -1);

const ops = values.at(-1);

// for each cell, generate a rule like body:has(table tr:nth-child(r) td:nth-child(c)[data-value]) { --row-r-col-c: value; }
const valueRules = tableRowsInt
  .map((cols, r) =>
    cols
      .map(
        (col, c) =>
          `body:has(table tr:nth-child(${r + 1}) td:nth-child(${
            c + 1
          })[data-value]) { --row-${r + 1}-col-${c + 1}: ${col.trim()}; }`,
      )
      .join("\n"),
  )
  .join("\n");

// set the last child of table to be the total of each column (building up a css calc expression)
const totalCalculationRules = ops
  .map((op, c) => {
    const colCount = tableRowsInt.length;
    const terms = [];
    for (let r = 0; r < colCount; r++) {
      terms.push(`var(--row-${r + 1}-col-${c + 1})`);
    }
    const expression =
      op === "+" ? terms.join(" + ") : op === "*" ? terms.join(" * ") : "0";
    return `body:has(table tr:last-child td:nth-child(${
      c + 1
    })) { --col-${c + 1}-total: calc(${expression}); }`;
  })
  .join("\n");

const totalDisplayRules = ops
  .map((op, c) => {
    return `table tr:last-child td:nth-child(${
      c + 1
    })::after { counter-reset: t-${
      c + 1
    } var(--col-${c + 1}-total); content: counter(t-${c + 1}); }`;
  })
  .join("\n");

const valueRowsTds = tableRowsInt.map((cols) =>
  cols
    .map((col) => {
      const val = col.trim();
      return `<td data-value="${val}">${val}</td>`;
    })
    .join(""),
);
const totalRowTds = ops.map(() => `<td></td>`).join("");
const opRowTds = ops.map((op) => `<td>${op}</td>`).join("");
const tableRowsHtml = [...valueRowsTds, opRowTds, totalRowTds]
  .map((rowHtml) => `<tr>${rowHtml}</tr>`)
  .join("\n");

// grand total (sum up all column totals)
const grandTotalCalculation = ops
  .map((_, c) => `var(--col-${c + 1}-total)`)
  .join(" + ");
const grandCalculationRule = `body { --grand-total: calc(${grandTotalCalculation}); }`;

// doesn't work since hits max integer value, but still displayed in case browsers ever update their CSS engines
const grandTotalDisplayRule = `#grand-total::after { counter-reset: grand-total var(--grand-total); content: "Grand Total: " counter(grand-total); font-weight: bold; }`;

// tableRowsHtml is now a complete, correct <tr>...</tr> block
const css = `
<style>
table, th, td {
  border: 1px solid black;
  border-collapse: collapse;
  padding: 5px;
  text-align: right;
}
tbody tr:last-child td {
  font-weight: bold;
  border-top: 2px solid black;
}
${valueRules}
${totalCalculationRules}
${totalDisplayRules}
${grandCalculationRule}
${grandTotalDisplayRule}
</style>
`;

const htmlTable = `<table>\n${tableRowsHtml}\n</table>`;

const fullOutput = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Table Output</title>
</head>
<body>
${css}
${htmlTable}
<p><output id="grand-total"></output></p>
`;

fs.writeFileSync("solution.html", fullOutput);
