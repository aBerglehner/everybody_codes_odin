const fs = require("node:fs");

const COLLISIONS_LIMIT = 1_000_000_000_000;
const DIRECTIONS = ["^", ">", "v", "<"];
const DELTAS = [
  [-1, 0], // up
  [0, 1], // right
  [1, 0], // down
  [0, -1], // left
];

function directionIndex(symbol) {
  return DIRECTIONS.indexOf(symbol);
}

function updateGhost(grid, ghost) {
  const [dr, dc] = DELTAS[ghost.direction];
  const row = ghost.row + dr;
  const col = ghost.col + dc;

  if (grid[row][col] === "#") {
    ghost.collisions += 1;
    ghost.direction = (ghost.direction + 1) % 4;
    if (ghost.collisions >= COLLISIONS_LIMIT) ghost.alive = false;
  } else {
    ghost.row = row;
    ghost.col = col;
  }
}

function part3() {
  const grid = fs
    .readFileSync("./10/test", "utf8")
    .split(/\r?\n/)
    .filter((line) => line.length > 0)
    .map((line) => [...line]);

  console.log(grid.map((row) => row.join("")).join("\n"));

  const ghosts = [];
  for (let row = 0; row < grid.length; row += 1) {
    for (let col = 0; col < grid[row].length; col += 1) {
      const direction = directionIndex(grid[row][col]);
      if (direction !== -1) {
        ghosts.push({ direction, row, col, collisions: 0, alive: true });
      }
    }
  }

  console.log("ghosts:", ghosts);
  console.log("len ghosts:", ghosts.length);

  // A generation stamp avoids clearing the full occupancy grid each round.
  const generation = Array.from(
    { length: grid.length },
    () => new Float64Array(grid[0].length),
  );
  const occupancy = Array.from(
    { length: grid.length },
    () => new Uint32Array(grid[0].length),
  );

  for (let round = 1; round <= 100_000_000_000_000; round += 1) {
    if (round % 10_000_000 === 0) console.log("round:", round);

    let allDead = true;
    for (const ghost of ghosts) {
      if (ghost.alive) updateGhost(grid, ghost);
      if (ghost.alive) {
        if (generation[ghost.row][ghost.col] !== round) {
          generation[ghost.row][ghost.col] = round;
          occupancy[ghost.row][ghost.col] = 0;
        }
        occupancy[ghost.row][ghost.col] += 1;
      }
    }

    for (const ghost of ghosts) {
      if (!ghost.alive) continue;
      if (occupancy[ghost.row][ghost.col] > 1) {
        ghost.collisions += 1;
        ghost.direction = (ghost.direction + 2) % 4;
      }
      if (ghost.collisions >= COLLISIONS_LIMIT) {
        ghost.alive = false;
      } else {
        allDead = false;
      }
    }

    if (allDead) {
      console.log(`round: ${round} ghosts:`, ghosts);
      console.log("we broke");
      break;
    }
  }
}

part3();
