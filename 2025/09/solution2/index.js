const canvasSize = 1000;
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d", { willReadFrequently: true });

// avoid local variables and code blocks for no reason

const rawInput = (path) =>
  fetch(path)
    .then((res) => res.text())
    .then((s) => s.split("\n").filter(Boolean));

const parseLines = (lines) => lines.map((line) => line.split(",").map(Number));

const scaleInput = (points) =>
  ((maxCoord) =>
    ((scale) =>
      ((scaledPoints) => ({ points, scaledPoints, scale }))(
        points.map(([x, y]) => [x * scale, y * scale]),
      ))(canvasSize / maxCoord))(Math.max(...points.flat()) + 1);

const fitCanvas = ({ points, scaledPoints, scale }) =>
  ((maxX, maxY) => (
    (canvas.width = maxX),
    (canvas.height = maxY),
    (canvas.style.width = canvas.width + "px"),
    (canvas.style.height = canvas.height + "px"),
    { points, scaledPoints, scale }
  ))(...[0, 1].map((dim) => Math.max(...scaledPoints.map((p) => p[dim])) + 1));

const drawPolygon = ({ points, scaledPoints, scale }) => (
  (ctx.fillStyle = "blue"),
  ctx.beginPath(),
  scaledPoints.forEach(([x, y], i) =>
    i ? ctx.lineTo(x, y) : ctx.moveTo(x, y),
  ),
  ctx.closePath(),
  ctx.fill(),
  { points, scaledPoints, scale }
);

const cartesianProduct = ({ points, scaledPoints, scale }) => ({
  pairs: points.flatMap((p1, i) =>
    points.map((p2, j) => ({
      original: [p1, p2],
      scaled: [scaledPoints[i], scaledPoints[j]],
    })),
  ),
  scale,
});

// top left, bottom right
const pairToRectangle = ([[x1, y1], [x2, y2]]) => [
  [Math.min(x1, x2), Math.min(y1, y2)],
  [Math.max(x1, x2), Math.max(y1, y2)],
];

const convertToRectangles = ({ pairs, scale }) => ({
  rectangles: pairs.map(({ original, scaled }) => ({
    original: pairToRectangle(original),
    scaled: pairToRectangle(scaled),
  })),
  scale,
});

// bias for floating point rounding
const shrink = ([[x1, y1], [x2, y2]]) => [
  [x1 + 1, y1 + 1],
  [x2 - 1, y2 - 1],
];

const quantize = ([[x1, y1], [x2, y2]]) => [
  [Math.floor(x1), Math.floor(y1)],
  [Math.ceil(x2), Math.ceil(y2)],
];

const hasTransparentPixel = (data) =>
  data.some((_, i) => i % 4 === 3 && data[i] === 0);

const rectanglePerimeterIsOutsidePolygon = (scaledRect) =>
  (([[x1, y1], [x2, y2]]) =>
    ((width, height) =>
      width <= 0 ||
      height <= 0 ||
      [
        [x1, y1, width, 1], // top
        [x1, y2 - 1, width, 1], // bottom
        [x1, y1, 1, height], // left
        [x2 - 1, y1, 1, height], // right
      ].some((args) =>
        hasTransparentPixel([...ctx.getImageData(...args).data]),
      ))(Math.max(x2 - x1, 1), Math.max(y2 - y1, 1)))(
    quantize(shrink(scaledRect)),
  );

const keepOnlyRectanglesInsidePolygon = ({ rectangles, scale }) => ({
  rectangles: rectangles.filter(
    (r) => !rectanglePerimeterIsOutsidePolygon(r.scaled),
  ),
  scale,
});

const rectangleArea = (rect) =>
  (([[x1, y1], [x2, y2]]) => (x2 - x1 + 1) * (y2 - y1 + 1))(rect.original);

const sortByAreaDesc = ({ rectangles, scale }) => ({
  rectangles: rectangles.sort((a, b) => rectangleArea(b) - rectangleArea(a)),
  scale,
});

const drawRectangle = (rect) =>
  (([[x1, y1], [x2, y2]]) => {
    ctx.strokeStyle = "red";
    ctx.lineWidth = 2;
    ctx.strokeRect(x1, y1, x2 - x1, y2 - y1);
    return rect;
  })(rect.scaled);

const first = ({ rectangles }) => rectangles[0];

rawInput("input.txt")
  .then(parseLines)
  .then(scaleInput)
  .then(fitCanvas)
  .then(drawPolygon)
  .then(cartesianProduct)
  .then(convertToRectangles)
  .then(keepOnlyRectanglesInsidePolygon)
  .then(sortByAreaDesc)
  .then(first)
  .then(drawRectangle)
  .then(rectangleArea)
  .then(console.log);
