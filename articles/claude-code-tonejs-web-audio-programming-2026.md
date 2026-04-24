---
title: "Claude Code for Tone.js Web Audio"
permalink: /claude-code-tonejs-web-audio-programming-2026/
description: "Build web audio applications with Tone.js and Claude Code. Create synthesizers, sequencers, effects chains, and interactive music tools in the browser."
last_tested: "2026-04-22"
domain: "web audio"
render_with_liquid: false
---

## Why Claude Code for Tone.js

Tone.js is the most comprehensive Web Audio framework, providing synthesizers, effects, transport scheduling, and audio analysis that abstract the raw Web Audio API. Musicians, educators, and creative technologists use it to build browser-based synthesizers, drum machines, interactive music tools, and audio visualizations. The challenge is understanding Tone.js's transport system (which operates independently of requestAnimationFrame), signal routing between audio nodes, scheduling precision for musical timing, and the AudioContext lifecycle that requires user gesture activation.

Claude Code generates Tone.js applications with proper audio signal routing, transport-synchronized scheduling, responsive UI that stays in sync with audio timing, and patterns that handle the browser's audio autoplay restrictions correctly.

## The Workflow

### Step 1: Set Up Tone.js Project

```bash
# Initialize project
npm create vite@latest synth-app -- --template vanilla
cd synth-app
npm install tone

# Tone.js requires user interaction to start AudioContext
```

### Step 2: Build a Polyphonic Synthesizer with Effects

```javascript
// synth.js — Browser-based polyphonic synthesizer
import * as Tone from 'tone';

class PolySynth {
  constructor() {
    this.isStarted = false;

    // Synth voice configuration
    this.synth = new Tone.PolySynth(Tone.Synth, {
      maxPolyphony: 8,
      voice: Tone.Synth,
      options: {
        oscillator: { type: 'triangle8' },
        envelope: {
          attack: 0.05,
          decay: 0.3,
          sustain: 0.4,
          release: 1.2,
        },
      },
    });

    // Effects chain: synth -> filter -> chorus -> delay -> reverb -> master
    this.filter = new Tone.Filter({
      type: 'lowpass',
      frequency: 2000,
      rolloff: -24,
      Q: 2,
    });

    this.chorus = new Tone.Chorus({
      frequency: 1.5,
      delayTime: 3.5,
      depth: 0.7,
      wet: 0.3,
    }).start();

    this.delay = new Tone.FeedbackDelay({
      delayTime: '8n',
      feedback: 0.3,
      wet: 0.2,
    });

    this.reverb = new Tone.Reverb({
      decay: 2.5,
      preDelay: 0.01,
      wet: 0.3,
    });

    this.analyser = new Tone.Analyser('waveform', 256);
    this.meter = new Tone.Meter();

    // Connect signal chain
    this.synth.chain(
      this.filter,
      this.chorus,
      this.delay,
      this.reverb,
      this.analyser,
      this.meter,
      Tone.getDestination()
    );

    // LFO modulating filter cutoff
    this.filterLFO = new Tone.LFO({
      frequency: 0.5,
      min: 400,
      max: 4000,
      type: 'sine',
    });
    this.filterLFO.connect(this.filter.frequency);
  }

  async start() {
    if (this.isStarted) return;
    await Tone.start();
    this.filterLFO.start();
    this.isStarted = true;
    console.log('Audio context started');
  }

  noteOn(note, velocity = 0.8) {
    this.synth.triggerAttack(note, Tone.now(), velocity);
  }

  noteOff(note) {
    this.synth.triggerRelease(note, Tone.now());
  }

  setFilterCutoff(frequency) {
    this.filter.frequency.rampTo(frequency, 0.1);
  }

  setReverbWet(value) {
    this.reverb.wet.rampTo(value, 0.1);
  }

  setDelayFeedback(value) {
    this.delay.feedback.rampTo(value, 0.1);
  }

  getWaveform() {
    return this.analyser.getValue();
  }

  getLevel() {
    return this.meter.getValue();
  }

  dispose() {
    this.synth.dispose();
    this.filter.dispose();
    this.chorus.dispose();
    this.delay.dispose();
    this.reverb.dispose();
    this.analyser.dispose();
    this.meter.dispose();
    this.filterLFO.dispose();
  }
}

export default PolySynth;
```

### Step 3: Build a Step Sequencer with Transport Sync

```javascript
// sequencer.js — 16-step drum sequencer synced to transport
import * as Tone from 'tone';

class StepSequencer {
  constructor(bpm = 120) {
    this.bpm = bpm;
    this.steps = 16;
    this.isPlaying = false;
    this.currentStep = 0;
    this.onStepChange = null;  // UI callback

    Tone.getTransport().bpm.value = bpm;

    // Drum kit using sampler
    this.drums = {
      kick: new Tone.MembraneSynth({
        pitchDecay: 0.05,
        octaves: 6,
        oscillator: { type: 'sine' },
        envelope: { attack: 0.001, decay: 0.4, sustain: 0, release: 0.4 },
      }),
      snare: new Tone.NoiseSynth({
        noise: { type: 'white' },
        envelope: { attack: 0.001, decay: 0.2, sustain: 0, release: 0.2 },
      }),
      hihat: new Tone.MetalSynth({
        frequency: 400,
        envelope: { attack: 0.001, decay: 0.1, release: 0.01 },
        harmonicity: 5.1,
        modulationIndex: 32,
        resonance: 4000,
        octaves: 1.5,
      }),
      clap: new Tone.NoiseSynth({
        noise: { type: 'pink' },
        envelope: { attack: 0.003, decay: 0.15, sustain: 0, release: 0.1 },
      }),
    };

    // Individual channel volumes
    this.channels = {};
    for (const [name, synth] of Object.entries(this.drums)) {
      const channel = new Tone.Channel(-6, 0).toDestination();
      synth.connect(channel);
      this.channels[name] = channel;
    }

    // Pattern grid: [instrument][step] = true/false
    this.pattern = {
      kick:  [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0],
      snare: [0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0],
      hihat: [1,0,1,0, 1,0,1,0, 1,0,1,0, 1,0,1,0],
      clap:  [0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0],
    };

    // Schedule repeating sequence
    this.loop = new Tone.Sequence(
      (time, step) => {
        this.currentStep = step;

        // Trigger active instruments on this step
        for (const [name, steps] of Object.entries(this.pattern)) {
          if (steps[step]) {
            if (name === 'kick') {
              this.drums.kick.triggerAttackRelease('C1', '8n', time);
            } else if (name === 'snare') {
              this.drums.snare.triggerAttackRelease('8n', time);
            } else if (name === 'hihat') {
              this.drums.hihat.triggerAttackRelease('32n', time, 0.3);
            } else if (name === 'clap') {
              this.drums.clap.triggerAttackRelease('16n', time);
            }
          }
        }

        // Notify UI on next frame (not in audio thread)
        Tone.getDraw().schedule(() => {
          if (this.onStepChange) this.onStepChange(step);
        }, time);
      },
      [...Array(this.steps).keys()],  // [0, 1, 2, ..., 15]
      '16n'
    );
  }

  async start() {
    await Tone.start();
    this.loop.start(0);
    Tone.getTransport().start();
    this.isPlaying = true;
  }

  stop() {
    Tone.getTransport().stop();
    this.isPlaying = false;
    this.currentStep = 0;
  }

  toggleStep(instrument, step) {
    this.pattern[instrument][step] = this.pattern[instrument][step] ? 0 : 1;
  }

  setBPM(bpm) {
    this.bpm = bpm;
    Tone.getTransport().bpm.rampTo(bpm, 0.1);
  }

  setSwing(amount) {
    Tone.getTransport().swing = amount;
    Tone.getTransport().swingSubdivision = '16n';
  }

  dispose() {
    this.loop.dispose();
    Object.values(this.drums).forEach(d => d.dispose());
    Object.values(this.channels).forEach(c => c.dispose());
  }
}

export default StepSequencer;
```

### Step 4: Verify

```bash
# Run dev server
npm run dev

# Open browser and click to activate AudioContext
# Chrome requires user gesture before audio plays

# Test MIDI input (if available)
# navigator.requestMIDIAccess() in browser console

# Build for production
npm run build
```

## CLAUDE.md for Tone.js Web Audio

```markdown
# Tone.js Web Audio Standards

## Domain Rules
- MUST call Tone.start() after user gesture (click/tap) before any audio
- Use Transport for all musical timing (not setTimeout/setInterval)
- Signal chain: source -> effects -> analyser -> destination
- Use Tone.Draw.schedule() for UI updates synced to audio (not in audio callback)
- Dispose all audio nodes on cleanup to prevent memory leaks
- Use rampTo() for parameter changes (prevents clicks/pops)
- Channel volumes in dB (not linear 0-1)

## File Patterns
- src/synth.js (synthesizer classes)
- src/sequencer.js (pattern/step sequencer)
- src/effects.js (effects chain configuration)
- src/ui.js (UI controls and visualizers)

## Common Commands
- npm run dev
- npm run build
- npx vite preview
- open http://localhost:5173
```

## Common Pitfalls in Tone.js Programming

- **AudioContext not started:** Browsers block audio until user interaction. Claude Code adds a start button overlay that calls `Tone.start()` before any audio playback, and grays out audio controls until the context is active.

- **Scheduling in the audio thread:** Modifying DOM elements or running expensive code in Tone.js callbacks (like Sequence or Loop) disrupts audio timing. Claude Code uses `Tone.getDraw().schedule()` to defer UI updates to the animation frame.

- **Parameter clicks and pops:** Setting audio parameters instantaneously (`.value =`) causes audible artifacts. Claude Code uses `.rampTo()` with short durations (0.01-0.1s) for smooth parameter transitions.

## Related

- [Claude Code for Processing and p5.js Creative Coding](/claude-code-processing-p5js-creative-coding-2026/)
- [Claude Code for Three.js 3D Scene Development](/claude-code-threejs-3d-scene-development-2026/)
- [Claude Code for After Effects ExtendScript](/claude-code-after-effects-extendscript-2026/)
