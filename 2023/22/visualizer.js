display.width = 1200;
display.height = 800;
const ctx = display.getContext("2d");
const BACKGROUND = "#101010";
const FOREGROUND = "#50FF50";

point = ({x, y}, s, color) => {
  ctx.fillStyle = color;
  ctx.fillRect(x - s/2, y - s/2, s, s);
}

clear = () => {
  ctx.fillStyle = BACKGROUND;
  ctx.fillRect(0,0,display.width,display.height);
}

toscreen = (p) => {
  return {
    x: (p.x + 1) / 2.0 * display.width,
    y: (1 - (p.y + 1) / 2.0) * display.height
  };
}

rotate_xz = ({x,y,z}, angle) => {
  const c = Math.cos(angle);
  const s = Math.sin(angle);
  return {
    x: x * c - z * s,
    y,
    z: x * s + z * c
  };
}

line = (p1, p2) => { 
  if (p1.x < 0 && p2.x < 0) {
    prunedLines += 1;
    return;
  }
  if (p1.y < 0 && p2.y < 0) {
    prunedLines += 1;
    return;
  }
  if (p1.x >= display.width && p2.x >= display.width) {
    prunedLines += 1;
    return;
  }
  if (p1.y >= display.height && p2.y >= display.height) {
    prunedLines += 1;
    return;
  }
  ctx.lineWidth = 1;
  ctx.strokeStyle = FOREGROUND;
  ctx.beginPath();
  ctx.moveTo(p1.x, p1.y);
  ctx.lineTo(p2.x, p2.y);
  ctx.stroke();
}

project = ({x,y,z}) => {
  return {
    x: x / z,
    y: y / z
  }
}

translate_z = ({x,y,z}, dz) => {
  return { x, y, z: z + dz};
}

translate_y = ({x,y,z}, dy) => {
  return { x, y: y + dy, z};
}

resize = ({x,y,z}, factor) => {
  return {x: x*factor, y: y*factor, z: z*factor};
}

const cube = [
  {x:  0.25, y:  0.25, z: 0.25},
  {x: -0.25, y:  0.25, z: 0.25},
  {x: -0.25, y: -0.25, z: 0.25},
  {x:  0.25, y: -0.25, z: 0.25},
  {x:  0.25, y:  0.25, z: -0.25},
  {x: -0.25, y:  0.25, z: -0.25},
  {x: -0.25, y: -0.25, z: -0.25},
  {x:  0.25, y: -0.25, z: -0.25},
];
const fs = [
  [0,1,2,3],
  [4,5,6,7],
  [0,4],
  [1,5],
  [2,6],
  [3,7],
];

const blocks = [];
/*
const blocks = [
  {p1: {x:1, z:0, y:-3}, p2: {x:1, z:2, y:-3}},
  {p1: {x:0, z:0, y:-2}, p2: {x:2, z:0, y:-2}},
  {p1: {x:0, z:2, y:-1}, p2: {x:2, z:2, y:-1}},
  {p1: {x:0, z:0, y:0}, p2: {x:0, z:2, y:0}},
  {p1: {x:2, z:0, y:1}, p2: {x:2, z:2, y:1}},
  {p1: {x:0, z:1, y:2}, p2: {x:2, z:1, y:2}},
  {p1: {x:1, z:1, y:4}, p2: {x:1, z:1, y:5}},
]
*/

block_to_cube = (b) => {
  xmin = Math.min(...[b.p2.x - 0.5, b.p1.x - 0.5]);
  xmax = Math.max(...[b.p2.x + 0.5, b.p1.x + 0.5]);
  ymin = Math.min(...[b.p2.y - 0.5, b.p1.y - 0.5]);
  ymax = Math.max(...[b.p2.y + 0.5, b.p1.y + 0.5]);
  zmin = Math.min(...[b.p2.z - 0.5, b.p1.z - 0.5]);
  zmax = Math.max(...[b.p2.z + 0.5, b.p1.z + 0.5]);

  return [
    {x: xmax, y: ymax, z: zmax},
    {x: xmin, y: ymax, z: zmax},
    {x: xmin, y: ymin, z: zmax},
    {x: xmax, y: ymin, z: zmax},
    {x: xmax, y: ymax, z: zmin},
    {x: xmin, y: ymax, z: zmin},
    {x: xmin, y: ymin, z: zmin},
    {x: xmax, y: ymin, z: zmin},
  ];
}

cube_at = (p, s) => {
  return [
    {x: p.x+s/2, y: p.y+s/2, z: p.z+s/2},
    {x: p.x-s/2, y: p.y+s/2, z: p.z+s/2},
    {x: p.x-s/2, y: p.y-s/2, z: p.z+s/2},
    {x: p.x+s/2, y: p.y-s/2, z: p.z+s/2},
    {x: p.x+s/2, y: p.y+s/2, z: p.z-s/2},
    {x: p.x-s/2, y: p.y+s/2, z: p.z-s/2},
    {x: p.x-s/2, y: p.y-s/2, z: p.z-s/2},
    {x: p.x+s/2, y: p.y-s/2, z: p.z-s/2},
  ];
}

draw_cube = (c) => {
  for (const f of fs) {
    if (f.length == 2) {
      const p1 = toscreen(project(translate_z(rotate_xz(resize(c[f[0]], scale), angle), dz)));
      const p2 = toscreen(project(translate_z(rotate_xz(resize(c[f[1]], scale), angle), dz)));
      line(p1,p2);
    } else {
      for (let i = 0; i < f.length; i++) {
        const p1 = toscreen(project(translate_z(rotate_xz(resize(c[f[i]], scale), angle), dz)));
        const p2 = toscreen(project(translate_z(rotate_xz(resize(c[f[(i+1) % f.length]], scale), angle), dz)));
        line(p1,p2);
      }
    }
  }

}

const FPS = 60;
let dz = 2;
let angle = 0;
let scale = 0.25;
let prunedLines = 0;
const dscale = 0.01;

dataFile.addEventListener('change', evt => {
  const file = evt.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = e => {
      const contents = e.target.result;
      newblocks = [];
      let minx = miny = minz = 1000000
      let maxx = maxy = maxz = -1000000
      contents.split("\n").forEach( line => {
        if (line.length == 0) {
          return;
        }
        let [p1, p2] = line.trim().split("~");
        p1 = p1.split(",").map(s => parseInt(s));
        p2 = p2.split(",").map(s => parseInt(s));
        minx = Math.min(minx, p1[0], p2[0]);
        miny = Math.min(miny, p1[2], p2[2]);
        minz = Math.min(minz, p1[1], p2[1]);
        maxx = Math.max(maxx, p1[0], p2[0]);
        maxy = Math.max(maxy, p1[2], p2[2]);
        maxz = Math.max(maxz, p1[1], p2[1]);
        newblocks.push(
          {
            p1: {x:p1[0],z:p1[1],y:p1[2]},
            p2: {x:p2[0],z:p2[1],y:p2[2]}
          }
        );
      });
      blocks.length = 0;
      ddy = Math.round((maxy - miny) / 2.0);
      ddx = Math.round((maxx - minx) / 2.0);
      ddz = Math.round((maxz - minz) / 2.0);
      for (b of newblocks) {
        b.p1.y -= ddy;
        b.p2.y -= ddy;
        b.p1.x -= ddx;
        b.p2.x -= ddx;
        b.p1.z -= ddz;
        b.p2.z -= ddz;
        blocks.push(b)
      }
    }
    reader.readAsText(file);
  }
});
display.addEventListener('wheel', evt => {
  event.preventDefault();
  if (event.deltaY < 0) {
    scale = scale + dscale;
  } else if (event.deltaY > 0) {
    scale = scale - dscale;
    if (scale < 0) { scale = 0.0; }
  }
}, { passive: false } );

frame = () => {
  const dt = 1/FPS;
  angle += 0.1*Math.PI*dt;
  prunedLines = 0;
  clear();
  /*
  for (let v of cube) {
    v = rotate_xz(v, angle);
    v = translate_z(v, dz);
    v = project(v);
    v = toscreen(v);
    point(v, 10, FOREGROUND);
  }
  */
  for (const block of blocks) {
    draw_cube(block_to_cube(block))
  }
  ctx.fillStyle = FOREGROUND;
  ctx.font = "14px serif"
  ctx.fillText(`SCALE: ${scale} PRUNED LINES: ${prunedLines}`,20,20);
  //draw_cube(cube_at({x:0.5,y:0,z:0}, 0.5))
  setTimeout(frame, 1000/FPS);
}
setTimeout(frame, 1000/FPS);

