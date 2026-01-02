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

rotate_xz = (p, angle) => {
  let tv = {x: (maxx-minx)/2.0*scale, y: 0, z: (maxz-minz)/2.0*scale};
  p = translate(p, negate(tv));
  const c = Math.cos(angle);
  const s = Math.sin(angle);
  p = {
    x: p.x * c - p.z * s,
    y: p.y,
    z: p.x * s + p.z * c
  };
  //return p;
  return translate(p, tv);
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

negate = ({x,y,z}) => {
   return {x: -x, y: -y, z: -z};
}

camera_translate = ({x,y,z}) => {
  return { x: x - camera.x, y: y - camera.y, z: z - camera.z};
}

translate = (p, dv) => {
  return {x: p.x + dv.x, y: p.y + dv.y, z: p.z + dv.z};
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

const fs = [
  [0,1,2,3],
  [4,5,6,7],
  [0,4],
  [1,5],
  [2,6],
  [3,7],
];

const blocks = [];

block_to_cube = (b) => {
  const bxmin = Math.min(...[b.p2.x - 0.5, b.p1.x - 0.5]);
  const bxmax = Math.max(...[b.p2.x + 0.5, b.p1.x + 0.5]);
  const bymin = Math.min(...[b.p2.y - 0.5, b.p1.y - 0.5]);
  const bymax = Math.max(...[b.p2.y + 0.5, b.p1.y + 0.5]);
  const bzmin = Math.min(...[b.p2.z - 0.5, b.p1.z - 0.5]);
  const bzmax = Math.max(...[b.p2.z + 0.5, b.p1.z + 0.5]);

  return [
    {x: bxmax, y: bymax, z: bzmax},
    {x: bxmin, y: bymax, z: bzmax},
    {x: bxmin, y: bymin, z: bzmax},
    {x: bxmax, y: bymin, z: bzmax},
    {x: bxmax, y: bymax, z: bzmin},
    {x: bxmin, y: bymax, z: bzmin},
    {x: bxmin, y: bymin, z: bzmin},
    {x: bxmax, y: bymin, z: bzmin},
  ];
}

draw_cube = (c) => {
  for (const f of fs) {
    if (f.length == 2) {
      const p1 = toscreen(project(camera_translate(rotate_xz(resize(c[f[0]], scale), angle))));
      const p2 = toscreen(project(camera_translate(rotate_xz(resize(c[f[1]], scale), angle))));
      line(p1,p2);
    } else {
      for (let i = 0; i < f.length; i++) {
        const p1 = toscreen(project(camera_translate(rotate_xz(resize(c[f[i]], scale), angle))));
        const p2 = toscreen(project(camera_translate(rotate_xz(resize(c[f[(i+1) % f.length]], scale), angle))));
        line(p1,p2);
      }
    }
  }

}

const FPS = 60;
const camera = {x: 0, y: 0, z: -2};
const camera_moving = {x: 0, y: 0, z: 0}
const camera_v = 0.05;

let angle = 0;
let scale = 0.25;
let prunedLines = 0;
let minx = miny = minz = 1000000;
let maxx = maxy = maxz = -1000000;

const dscale = 0.01;

document.onkeydown = (e) => {
  if (e.key == "ArrowUp") {
    camera_moving.y = 1;
  }
  if (e.key == "ArrowDown") {
    camera_moving.y = -1;
  }
  if (e.key == "ArrowLeft") {
    camera_moving.x = -1;
  }
  if (e.key == "ArrowRight") {
    camera_moving.x = 1;
  }
}
document.onkeyup = (e) => {
  if (e.key == "ArrowUp") {
    camera_moving.y = 0;
  }
  if (e.key == "ArrowDown") {
    camera_moving.y = 0;
  }
  if (e.key == "ArrowLeft") {
    camera_moving.x = 0;
  }
  if (e.key == "ArrowRight") {
    camera_moving.x = 0;
  }
}

dataFile.addEventListener('change', evt => {
  const file = evt.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = e => {
      const contents = e.target.result;
      blocks.length = 0;
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
        blocks.push(
          {
            p1: {x:p1[0],z:p1[1],y:p1[2]},
            p2: {x:p2[0],z:p2[1],y:p2[2]}
          }
        );
      });
      console.log(`x: ${minx}->${maxx} y: ${miny}->${maxy} z: ${minz}->${maxz}`)
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
  camera.y -= (camera_moving.y * camera_v);
  camera.x -= (camera_moving.x * camera_v);
  for (const block of blocks) {
    draw_cube(block_to_cube(block))
  }
  ctx.fillStyle = FOREGROUND;
  ctx.font = "14px serif"
  ctx.fillText(`SCALE: ${scale} PRUNED LINES: ${prunedLines}`,20,20);
  setTimeout(frame, 1000/FPS);
}
setTimeout(frame, 1000/FPS);

