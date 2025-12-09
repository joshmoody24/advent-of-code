const canvasSize = 1000;

const rawInput = (path) =>
  fetch(path)
    .then((res) => res.text())
    .then((s) => s.split("\n").filter(Boolean));

const parseLines = (lines) => lines.map((line) => line.split(",").map(Number));

const scaleInput = (points) => {
  const maxCoord = Math.max(...points.flat()) + 1;
  const scale = canvasSize / maxCoord;
  const scaledPoints = points.map(([x, y]) => [x * scale, y * scale]);
  return { points, scaledPoints, scale };
};

const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d", { willReadFrequently: true });
ctx.fillStyle = "red";

const fitCanvas = ({ points, scaledPoints, scale }) => {
  const maxX = Math.max(...scaledPoints.map((p) => p[0])) + 1;
  const maxY = Math.max(...scaledPoints.map((p) => p[1])) + 1;
  canvas.width = maxX;
  canvas.height = maxY;
  canvas.style.width = canvas.width + "px";
  canvas.style.height = canvas.height + "px";
  return { points, scaledPoints, scale };
};

const drawPolygon = ({ points, scaledPoints, scale }) => (
  ctx.beginPath(),
  scaledPoints.forEach(([x, y], i) =>
    i ? ctx.lineTo(x, y) : ctx.moveTo(x, y),
  ),
  ctx.closePath(),
  ctx.fill(),
  { points, scaledPoints, scale }
);

const cartesianProduct = ({ points, scaledPoints, scale }) => {
  const pairs = [];
  for (let i = 0; i < points.length; i++) {
    for (let j = 0; j < points.length; j++) {
      if (i !== j) {
        pairs.push({
          original: [points[i], points[j]],
          scaled: [scaledPoints[i], scaledPoints[j]],
        });
      }
    }
  }
  return { pairs, scale };
};

const pairToRectangle = (pair) => {
  const [[x1, y1], [x2, y2]] = pair;
  return [
    [Math.min(x1, x2), Math.min(y1, y2)],
    [Math.max(x1, x2), Math.max(y1, y2)],
  ];
};

const convertToRectangles = ({ pairs, scale }) => {
  const rectangles = pairs.map(({ original, scaled }) => ({
    original: pairToRectangle(original),
    scaled: pairToRectangle(scaled),
  }));
  return { rectangles, scale };
};

const rectangleTouchesTransparent = (scaledRect) => {
  const [[x1, y1], [x2, y2]] = scaledRect;
  const pad = 1;
  const rx1 = Math.floor(x1) + pad;
  const ry1 = Math.floor(y1) + pad;
  const rx2 = Math.floor(x2) - pad;
  const ry2 = Math.floor(y2) - pad;
  const width = rx2 - rx1;
  const height = ry2 - ry1;
  if (width <= 0 || height <= 0) return true;
  const imageData = ctx.getImageData(rx1, ry1, width, height);
  for (let i = 3; i < imageData.data.length; i += 4) {
    if (imageData.data[i] === 0) return true;
  }
  return false;
};

const filterValidRectangles = ({ rectangles, scale }) => {
  const valid = rectangles.filter((r) => !rectangleTouchesTransparent(r.scaled));
  return { rectangles: valid, scale };
};

const rectangleArea = (rect) => {
  const [[x1, y1], [x2, y2]] = rect;
  return (x2 - x1 + 1) * (y2 - y1 + 1);
};

const sortByAreaDesc = ({ rectangles, scale }) => {
  const sorted = rectangles.sort(
    (a, b) => rectangleArea(b.original) - rectangleArea(a.original),
  );
  return { rectangles: sorted, scale };
};

const drawRectangle = (scaledRect) => {
  const [[x1, y1], [x2, y2]] = scaledRect;
  ctx.strokeStyle = "blue";
  ctx.lineWidth = 2;
  ctx.strokeRect(x1, y1, x2 - x1, y2 - y1);
};

const getResult = ({ rectangles, scale }) => {
  const best = rectangles[0];
  drawRectangle(best.scaled);
  return rectangleArea(best.original);
};

rawInput("input.txt")
  .then(parseLines)
  .then(scaleInput)
  .then(fitCanvas)
  .then(drawPolygon)
  .then(cartesianProduct)
  .then(convertToRectangles)
  .then(filterValidRectangles)
  .then(sortByAreaDesc)
  .then(getResult)
  .then(console.log);
