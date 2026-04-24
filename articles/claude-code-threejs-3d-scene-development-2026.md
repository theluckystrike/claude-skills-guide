---
title: "Claude Code for Three.js 3D Scene (2026)"
permalink: /claude-code-threejs-3d-scene-development-2026/
description: "Build 3D web experiences with Three.js and Claude Code. Create scenes, materials, post-processing, and physics-based interactions for the browser."
last_tested: "2026-04-22"
domain: "web 3D"
---

## Why Claude Code for Three.js

Three.js is the dominant library for 3D graphics on the web, powering product configurators, architectural visualization, data visualization, creative portfolios, and browser-based games. The API surface is vast: scene graph management, PBR materials, shadow mapping, post-processing pipelines, glTF loading, skeletal animation, and physics integration. Most developers struggle with the render pipeline (understanding when to update materials, manage draw calls, and handle texture memory), writing custom shaders in GLSL, and optimizing for mobile WebGL.

Claude Code generates Three.js applications with proper scene management, material optimization, shader authoring, and performance patterns. It handles the common architectural decisions that determine whether a Three.js scene runs at 60fps or 15fps.

## The Workflow

### Step 1: Set Up Three.js Project

```bash
# Initialize project with Vite
npm create vite@latest my-3d-scene -- --template vanilla
cd my-3d-scene
npm install three @types/three
npm install -D vite-plugin-glsl  # GLSL shader imports
npm install @dimforge/rapier3d   # Optional: physics
npm install lil-gui               # Optional: debug GUI
```

### Step 2: Build an Interactive 3D Scene

```javascript
// main.js — Production Three.js scene architecture
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import GUI from 'lil-gui';

class SceneManager {
  constructor() {
    this.scene = new THREE.Scene();
    this.clock = new THREE.Clock();
    this.mixers = [];  // Animation mixers
    this.disposables = [];  // Track for cleanup

    this.initRenderer();
    this.initCamera();
    this.initLights();
    this.initPostProcessing();
    this.initControls();
    this.initGUI();

    window.addEventListener('resize', this.onResize.bind(this));
    this.animate();
  }

  initRenderer() {
    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
      powerPreference: 'high-performance',
    });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.2;
    this.renderer.outputColorSpace = THREE.SRGBColorSpace;
    document.body.appendChild(this.renderer.domElement);
  }

  initCamera() {
    this.camera = new THREE.PerspectiveCamera(
      45, window.innerWidth / window.innerHeight, 0.1, 100
    );
    this.camera.position.set(5, 3, 8);
  }

  initLights() {
    // Ambient for fill
    const ambient = new THREE.AmbientLight(0x404060, 0.5);
    this.scene.add(ambient);

    // Key light with shadows
    const directional = new THREE.DirectionalLight(0xffeedd, 2);
    directional.position.set(5, 8, 3);
    directional.castShadow = true;
    directional.shadow.mapSize.set(2048, 2048);
    directional.shadow.camera.near = 0.1;
    directional.shadow.camera.far = 30;
    directional.shadow.camera.left = -10;
    directional.shadow.camera.right = 10;
    directional.shadow.camera.top = 10;
    directional.shadow.camera.bottom = -10;
    directional.shadow.normalBias = 0.02;
    this.scene.add(directional);

    // Environment map for reflections
    const pmremGenerator = new THREE.PMREMGenerator(this.renderer);
    this.scene.environment = pmremGenerator.fromScene(
      new THREE.Scene(), 0.04
    ).texture;
  }

  initPostProcessing() {
    this.composer = new EffectComposer(this.renderer);
    this.composer.addPass(new RenderPass(this.scene, this.camera));

    const bloomPass = new UnrealBloomPass(
      new THREE.Vector2(window.innerWidth, window.innerHeight),
      0.3,   // strength
      0.4,   // radius
      0.85   // threshold
    );
    this.composer.addPass(bloomPass);
    this.bloomPass = bloomPass;
  }

  initControls() {
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.05;
    this.controls.maxPolarAngle = Math.PI * 0.85;
    this.controls.minDistance = 2;
    this.controls.maxDistance = 20;
  }

  initGUI() {
    const gui = new GUI();
    const params = {
      bloomStrength: 0.3,
      bloomRadius: 0.4,
      bloomThreshold: 0.85,
      exposure: 1.2,
    };

    gui.add(params, 'bloomStrength', 0, 3).onChange(v => {
      this.bloomPass.strength = v;
    });
    gui.add(params, 'exposure', 0, 3).onChange(v => {
      this.renderer.toneMappingExposure = v;
    });
  }

  // Load glTF model with animations
  async loadModel(url) {
    const loader = new GLTFLoader();
    const gltf = await loader.loadAsync(url);

    gltf.scene.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });

    this.scene.add(gltf.scene);

    // Set up animations
    if (gltf.animations.length > 0) {
      const mixer = new THREE.AnimationMixer(gltf.scene);
      gltf.animations.forEach((clip) => {
        mixer.clipAction(clip).play();
      });
      this.mixers.push(mixer);
    }

    return gltf.scene;
  }

  // Custom shader material
  createCustomMaterial() {
    return new THREE.ShaderMaterial({
      uniforms: {
        uTime: { value: 0 },
        uColor: { value: new THREE.Color(0x00aaff) },
        uFrequency: { value: 3.0 },
      },
      vertexShader: `
        uniform float uTime;
        uniform float uFrequency;
        varying vec2 vUv;
        varying float vDisplacement;

        void main() {
          vUv = uv;
          vec3 pos = position;
          vDisplacement = sin(pos.x * uFrequency + uTime) * 0.2
                        + sin(pos.y * uFrequency * 0.8 + uTime * 1.2) * 0.15;
          pos += normal * vDisplacement;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
        }
      `,
      fragmentShader: `
        uniform vec3 uColor;
        varying vec2 vUv;
        varying float vDisplacement;

        void main() {
          float intensity = smoothstep(-0.2, 0.4, vDisplacement);
          vec3 color = mix(uColor * 0.3, uColor, intensity);
          gl_FragColor = vec4(color, 1.0);
        }
      `,
    });
  }

  onResize() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
    this.composer.setSize(width, height);
  }

  animate() {
    requestAnimationFrame(this.animate.bind(this));
    const delta = this.clock.getDelta();
    const elapsed = this.clock.getElapsedTime();

    // Update animations
    this.mixers.forEach(mixer => mixer.update(delta));

    // Update shader uniforms
    this.scene.traverse((child) => {
      if (child.material?.uniforms?.uTime) {
        child.material.uniforms.uTime.value = elapsed;
      }
    });

    this.controls.update();
    this.composer.render();
  }

  dispose() {
    this.renderer.dispose();
    this.disposables.forEach(d => d.dispose());
    this.scene.traverse((child) => {
      if (child.geometry) child.geometry.dispose();
      if (child.material) {
        if (Array.isArray(child.material)) {
          child.material.forEach(m => m.dispose());
        } else {
          child.material.dispose();
        }
      }
    });
  }
}

// Initialize
const app = new SceneManager();

// Add ground plane
const ground = new THREE.Mesh(
  new THREE.PlaneGeometry(20, 20),
  new THREE.MeshStandardMaterial({ color: 0x333333, roughness: 0.8 })
);
ground.rotation.x = -Math.PI / 2;
ground.receiveShadow = true;
app.scene.add(ground);

// Add custom shader sphere
const sphere = new THREE.Mesh(
  new THREE.SphereGeometry(1, 64, 64),
  app.createCustomMaterial()
);
sphere.position.y = 1.5;
sphere.castShadow = true;
app.scene.add(sphere);

// Load glTF model
app.loadModel('/models/robot.glb').then(model => {
  model.position.set(3, 0, 0);
  model.scale.setScalar(0.5);
});
```

### Step 3: Verify

```bash
# Run dev server
npm run dev

# Build for production
npm run build

# Check bundle size
npx vite-bundle-visualizer

# Performance: open Chrome DevTools > Performance tab
# Target: stable 60fps, <50MB GPU memory
```

## CLAUDE.md for Three.js Development

```markdown
# Three.js 3D Scene Standards

## Domain Rules
- Always dispose geometries, materials, and textures on cleanup
- Limit pixel ratio to 2 (Math.min(devicePixelRatio, 2))
- Use PCFSoftShadowMap for quality, BasicShadowMap for performance
- Instanced meshes for repeated geometry (>100 copies)
- Object pooling for dynamic objects (particles, projectiles)
- glTF is the preferred model format (not OBJ or FBX)
- Avoid traversing scene graph every frame (cache references)

## File Patterns
- main.js (scene setup and render loop)
- src/scene/*.js (scene manager classes)
- src/materials/*.js (custom materials and shaders)
- src/shaders/*.glsl (GLSL shader files)
- public/models/*.glb (3D model assets)
- public/textures/*.{jpg,png,hdr} (texture assets)

## Common Commands
- npm run dev (Vite dev server)
- npm run build (production build)
- npx vite-bundle-visualizer (check bundle size)
- npx gltf-transform optimize model.glb optimized.glb
```

## Common Pitfalls in Three.js Development

- **Memory leaks from undisposed materials:** Every material, geometry, and texture must be explicitly disposed. Claude Code implements a resource tracking system that disposes all GPU resources on scene cleanup.

- **Shadow acne from default bias:** Default shadow settings produce shadow acne (striped artifacts). Claude Code sets `shadow.normalBias = 0.02` on directional lights to eliminate artifacts without introducing peter-panning.

- **Mobile performance collapse:** Desktop scenes with post-processing, high poly counts, and real-time shadows fail on mobile. Claude Code adds quality tiers that reduce shadow map size, disable bloom, and lower geometry detail on mobile devices.

## Related

- [Claude Code for Processing and p5.js Creative Coding](/claude-code-processing-p5js-creative-coding-2026/)
- [Claude Code for Tone.js Web Audio Programming](/claude-code-tonejs-web-audio-programming-2026/)
- [Claude Code for Blender Python Scripting](/claude-code-blender-python-scripting-2026/)
- [Claude Code for 3D Printer Firmware (2026)](/claude-code-3d-printer-firmware-customization-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
