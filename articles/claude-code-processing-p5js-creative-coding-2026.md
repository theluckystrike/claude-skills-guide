---
title: "Claude Code for Processing and p5.js"
permalink: /claude-code-processing-p5js-creative-coding-2026/
description: "Create generative art and creative coding with p5.js and Claude Code. Build particle systems, noise-based visuals, and interactive installations."
last_tested: "2026-04-22"
domain: "creative coding"
render_with_liquid: false
---

## Why Claude Code for Processing and p5.js

Processing and its JavaScript sibling p5.js are the foundation of creative coding, computational art, and interactive installations. Artists and designers use them for generative art, data visualization, interactive exhibits, and live visual performances. The challenge is bridging artistic vision with technical implementation: translating concepts like "flowing organic forms" or "reactive particle fields" into noise functions, physics simulations, and efficient rendering loops. Most creative coders learn through experimentation, but complex systems (flocking algorithms, reaction-diffusion, L-systems) require mathematical precision.

Claude Code translates artistic concepts into p5.js code, generates parameter-driven generative systems, optimizes canvas rendering for 60fps, and builds interactive installations that respond to audio, webcam, or sensor input.

## The Workflow

### Step 1: Set Up p5.js Project

```bash
# Create project
mkdir -p ~/creative-code/sketches
cd ~/creative-code
npm init -y
npm install p5

# Or use CDN in HTML
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.11.0/p5.min.js"></script>
  <script src="sketch.js"></script>
</head>
<body></body>
</html>
EOF
```

### Step 2: Build a Generative Particle Flow System

```javascript
// sketch.js — Perlin noise flow field with interactive particles

const PARTICLE_COUNT = 2000;
const NOISE_SCALE = 0.003;
const FLOW_SPEED = 2;

let particles = [];
let flowField;
let cols, rows;
let cellSize = 10;

function setup() {
  createCanvas(windowWidth, windowHeight);
  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, 5);

  cols = ceil(width / cellSize);
  rows = ceil(height / cellSize);
  flowField = new Array(cols * rows);

  // Initialize particles with random positions
  for (let i = 0; i < PARTICLE_COUNT; i++) {
    particles.push(new FlowParticle());
  }
}

function draw() {
  // Semi-transparent background for trail effect
  background(0, 0, 5, 3);

  // Update flow field with time-varying Perlin noise
  let zOffset = frameCount * 0.001;
  for (let y = 0; y < rows; y++) {
    for (let x = 0; x < cols; x++) {
      let angle = noise(x * NOISE_SCALE, y * NOISE_SCALE, zOffset) * TWO_PI * 2;

      // Mouse influence: attract particles near cursor
      let dx = x * cellSize - mouseX;
      let dy = y * cellSize - mouseY;
      let distToMouse = sqrt(dx * dx + dy * dy);
      if (distToMouse < 200) {
        angle = lerp(angle, atan2(-dy, -dx), map(distToMouse, 0, 200, 0.8, 0));
      }

      flowField[x + y * cols] = p5.Vector.fromAngle(angle).setMag(FLOW_SPEED);
    }
  }

  // Update and draw particles
  for (let particle of particles) {
    particle.follow(flowField);
    particle.update();
    particle.edges();
    particle.display();
  }
}

class FlowParticle {
  constructor() {
    this.pos = createVector(random(width), random(height));
    this.vel = createVector(0, 0);
    this.acc = createVector(0, 0);
    this.maxSpeed = FLOW_SPEED;
    this.lifespan = random(100, 400);
    this.age = 0;

    // Color based on spawn position
    this.hue = map(this.pos.x + this.pos.y, 0, width + height, 180, 300);
  }

  follow(field) {
    let x = floor(this.pos.x / cellSize);
    let y = floor(this.pos.y / cellSize);
    let index = constrain(x + y * cols, 0, field.length - 1);
    let force = field[index];
    if (force) {
      this.acc.add(force);
    }
  }

  update() {
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.acc.mult(0);
    this.age++;

    // Respawn old particles
    if (this.age > this.lifespan) {
      this.pos.set(random(width), random(height));
      this.age = 0;
      this.hue = map(this.pos.x + this.pos.y, 0, width + height, 180, 300);
    }
  }

  edges() {
    if (this.pos.x > width) this.pos.x = 0;
    if (this.pos.x < 0) this.pos.x = width;
    if (this.pos.y > height) this.pos.y = 0;
    if (this.pos.y < 0) this.pos.y = height;
  }

  display() {
    let alpha = map(this.age, 0, this.lifespan, 80, 0);
    let size = map(this.vel.mag(), 0, this.maxSpeed, 1, 3);
    stroke(this.hue % 360, 70, 90, alpha);
    strokeWeight(size);
    point(this.pos.x, this.pos.y);
  }
}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  cols = ceil(width / cellSize);
  rows = ceil(height / cellSize);
  flowField = new Array(cols * rows);
  background(0, 0, 5);
}

// Save frame on key press
function keyPressed() {
  if (key === 's') {
    saveCanvas('flow-field-' + frameCount, 'png');
  }
}
```

### Step 3: Build Audio-Reactive Visualization

```javascript
// audio-reactive.js — Sound-responsive generative visuals
let mic, fft;
let spectrum = [];
let waveform = [];

function setup() {
  createCanvas(windowWidth, windowHeight, WEBGL);
  colorMode(HSB, 360, 100, 100, 100);

  mic = new p5.AudioIn();
  mic.start();
  fft = new p5.FFT(0.8, 256);
  fft.setInput(mic);
}

function draw() {
  background(0, 0, 5);
  spectrum = fft.analyze();
  waveform = fft.waveform();
  let volume = mic.getLevel();

  // Orbit camera based on time
  let camX = sin(frameCount * 0.005) * 400;
  let camZ = cos(frameCount * 0.005) * 400;
  camera(camX, -200, camZ, 0, 0, 0, 0, 1, 0);

  // Reactive sphere
  push();
  noFill();
  let bassEnergy = fft.getEnergy("bass");
  let midEnergy = fft.getEnergy("mid");
  let trebleEnergy = fft.getEnergy("treble");

  // Bass drives scale
  let sphereSize = map(bassEnergy, 0, 255, 100, 300);
  // Mid drives color
  let hue = map(midEnergy, 0, 255, 200, 360);
  // Treble drives detail
  let detail = floor(map(trebleEnergy, 0, 255, 4, 20));

  stroke(hue, 80, 90, 60);
  strokeWeight(map(volume, 0, 1, 0.5, 3));
  sphere(sphereSize, detail, detail);
  pop();

  // Waveform ring
  push();
  rotateX(PI / 2);
  noFill();
  stroke(hue + 60, 70, 80, 50);
  beginShape();
  for (let i = 0; i < waveform.length; i++) {
    let angle = map(i, 0, waveform.length, 0, TWO_PI);
    let r = 200 + waveform[i] * 100;
    let x = r * cos(angle);
    let y = r * sin(angle);
    vertex(x, y);
  }
  endShape(CLOSE);
  pop();
}
```

### Step 4: Verify

```bash
# Serve locally
npx http-server -p 8080

# Performance check: open browser dev tools, check frame rate
# Target: stable 60fps with PARTICLE_COUNT = 2000

# Export high-res frame
# (In sketch: press 's' to save PNG)

# Record video (using CCapture.js)
# npm install ccapture.js
```

## CLAUDE.md for p5.js Creative Coding

```markdown
# p5.js Creative Coding Standards

## Domain Rules
- setup() runs once, draw() loops at 60fps
- Use createVector() for all 2D/3D math (not raw x/y)
- colorMode(HSB) for color manipulation (easier than RGB)
- Noise functions: noise() for smooth randomness, random() for uniform
- Performance: avoid creating objects in draw(), use object pools
- Always implement windowResized() for responsive canvas
- Add key press to save frames (key 's' convention)

## File Patterns
- sketch.js (main sketch)
- sketches/*.js (multiple sketch files)
- lib/*.js (shared utility classes)
- index.html (canvas host page)

## Common Commands
- npx http-server -p 8080
- npx p5-manager new sketch-name
- npx ccapture (video recording)
- open http://localhost:8080
```

## Common Pitfalls in p5.js Creative Coding

- **Object creation in draw() kills performance:** Creating vectors, colors, or particles every frame triggers garbage collection pauses. Claude Code uses object pools and pre-allocated arrays, only creating objects in setup().

- **Noise function produces same values:** `noise()` returns the same sequence unless `noiseSeed()` is called. Claude Code uses time-based z-offset (`noise(x, y, frameCount * 0.01)`) for evolving patterns.

- **WebGL mode API differences:** Many 2D functions (rect, ellipse) behave differently in WEBGL mode. Claude Code uses the correct 3D primitives (box, sphere, cylinder) and proper push()/pop() matrix management in WEBGL sketches.

## Related

- [Claude Code for Three.js 3D Scene Development](/claude-code-threejs-3d-scene-development-2026/)
- [Claude Code for Tone.js Web Audio Programming](/claude-code-tonejs-web-audio-programming-2026/)
- [Claude Code for After Effects ExtendScript](/claude-code-after-effects-extendscript-2026/)
