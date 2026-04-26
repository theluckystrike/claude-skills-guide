---

layout: default
title: "Claude Code for Gymnasium RL Workflow (2026)"
description: "Build reinforcement learning environments with Claude Code and Gymnasium. Agent training, environment setup, and evaluation workflow patterns."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-gymnasium-workflow-tutorial/
categories: [workflows]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
last_tested: "2026-04-21"
geo_optimized: true
---

Gymnasium has become the standard Python interface for reinforcement learning (RL) environments, offering a unified API for training agents across diverse tasks. Whether you're building your first RL agent or scaling up complex multi-environment training, Claude Code can significantly streamline your development workflow. This tutorial covers practical patterns for integrating Claude Code into your Gymnasium projects, from initial setup through deployment, debugging, and long-term maintenance.

## Setting Up Gymnasium with Claude Code

Getting started with Gymnasium is straightforward, but Claude Code can help you set up the entire environment with best practices from day one. Start by asking Claude to scaffold your RL project structure:

```
Create a new Python project for reinforcement learning with Gymnasium. Include a virtual environment setup, project structure for agents and environments, and basic training loop boilerplate.
```

Claude will generate a well-organized project structure with separate directories for environments, agents, and training scripts. A typical layout looks like this:

```
rl_project/
 agents/
 __init__.py
 base_agent.py
 ppo_agent.py
 environments/
 __init__.py
 custom_env.py
 training/
 __init__.py
 train.py
 evaluate.py
 callbacks/
 custom_callbacks.py
 configs/
 default.yaml
 requirements.txt
 README.md
```

For dependency management, specify your requirements:

```
Add requirements.txt with gymnasium, stable-baselines3, numpy, and torch. Use specific compatible versions.
```

This ensures all your dependencies work together without conflicts. a common problem in RL projects where library version mismatches can cause frustrating runtime errors. Claude will typically pin versions and add a note explaining why each version was chosen, which helps when you need to reproduce results or onboard new team members.

## Python Environment Setup

Before installing packages, ask Claude to set up a proper virtual environment workflow:

```bash
Create isolated environment
python -m venv venv
source venv/bin/activate # On Windows: venv\Scripts\activate

Install from requirements.txt
pip install -r requirements.txt

Verify GPU availability for PyTorch
python -c "import torch; print(torch.cuda.is_available())"
```

Claude Code can also help you write a `setup.py` or `pyproject.toml` if you want to package your environments and agents as installable modules. useful for larger projects shared across a team.

## Creating Your First Training Loop

The core of any RL project is the training loop. Claude Code can help you write efficient, well-structured training code that follows best practices. Here's a practical pattern for a basic training workflow:

```python
import gymnasium as gym
from stable_baselines3 import PPO
from stable_baselines3.common.callbacks import EvalCallback

Create environment
env = gym.make("CartPole-v1")

Train agent
model = PPO("MlpPolicy", env, verbose=1)
model.learn(total_timesteps=100000, progress_bar=True)

Save and evaluate
model.save("ppo_cartpole")
```

This minimal example is fine for prototyping, but Claude Code can help you extend it into a production-quality training script. Ask for specifics:

```
Add multi-environment training with 4 parallel environments using SubprocVecEnv. Include evaluation every 10000 steps and model checkpointing.
```

Claude will produce a more complete version:

```python
import gymnasium as gym
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env import SubprocVecEnv, VecNormalize
from stable_baselines3.common.callbacks import EvalCallback, CheckpointCallback
from stable_baselines3.common.utils import set_random_seed

def make_env(env_id, rank, seed=0):
 def _init():
 env = gym.make(env_id)
 env.reset(seed=seed + rank)
 return env
 set_random_seed(seed)
 return _init

if __name__ == "__main__":
 env_id = "CartPole-v1"
 n_envs = 4

 # Create vectorized environments
 train_env = SubprocVecEnv([make_env(env_id, i) for i in range(n_envs)])
 eval_env = gym.make(env_id)

 # Callbacks
 eval_callback = EvalCallback(
 eval_env,
 best_model_save_path="./logs/best_model",
 log_path="./logs/eval",
 eval_freq=10000,
 deterministic=True,
 render=False
 )
 checkpoint_callback = CheckpointCallback(
 save_freq=50000,
 save_path="./logs/checkpoints",
 name_prefix="ppo_cartpole"
 )

 # Train
 model = PPO("MlpPolicy", train_env, verbose=1, tensorboard_log="./logs/tensorboard")
 model.learn(
 total_timesteps=500000,
 callback=[eval_callback, checkpoint_callback],
 progress_bar=True
 )

 model.save("ppo_cartpole_final")
 train_env.close()
```

The key difference here is the use of `SubprocVecEnv`, which runs each environment in a separate process for true parallelism. critical when environments have heavy computation like physics simulations or custom rendering.

## Building Custom Gymnasium Environments

Creating custom environments is where Claude Code truly shines. The Gymnasium API requires implementing specific methods, and Claude can guide you through the process while catching common mistakes.

When building a custom environment, start with the structure:

```
Create a custom Gymnasium environment for a 2D grid navigation task. The agent should navigate from start to goal while avoiding obstacles. Include render mode support.
```

Claude will generate a well-structured environment class. Here is an example of what it produces:

```python
import gymnasium as gym
from gymnasium import spaces
import numpy as np
import pygame

class GridNavEnv(gym.Env):
 metadata = {"render_modes": ["human", "rgb_array"], "render_fps": 10}

 def __init__(self, grid_size=10, render_mode=None):
 super().__init__()
 self.grid_size = grid_size
 self.render_mode = render_mode

 # Action space: 0=up, 1=right, 2=down, 3=left
 self.action_space = spaces.Discrete(4)

 # Observation: agent position (x, y) + goal position (x, y)
 self.observation_space = spaces.Box(
 low=0,
 high=grid_size - 1,
 shape=(4,),
 dtype=np.float32
 )

 self.window = None
 self.clock = None

 def reset(self, seed=None, options=None):
 super().reset(seed=seed)
 self.agent_pos = np.array([0, 0], dtype=np.float32)
 self.goal_pos = np.array([self.grid_size - 1, self.grid_size - 1], dtype=np.float32)
 self.steps = 0

 obs = np.concatenate([self.agent_pos, self.goal_pos])
 return obs, {}

 def step(self, action):
 self.steps += 1
 moves = {0: (-1, 0), 1: (0, 1), 2: (1, 0), 3: (0, -1)}
 dx, dy = moves[action]

 new_pos = self.agent_pos + np.array([dx, dy])
 new_pos = np.clip(new_pos, 0, self.grid_size - 1)
 self.agent_pos = new_pos

 reached_goal = np.array_equal(self.agent_pos, self.goal_pos)
 reward = 100.0 if reached_goal else -1.0
 terminated = reached_goal
 truncated = self.steps >= 200

 obs = np.concatenate([self.agent_pos, self.goal_pos])
 return obs, reward, terminated, truncated, {}

 def render(self):
 if self.render_mode == "human":
 self._render_human()
 elif self.render_mode == "rgb_array":
 return self._render_rgb()

 def close(self):
 if self.window is not None:
 pygame.display.quit()
 pygame.quit()
```

Key aspects to verify in the generated code:

- Action space matches your action types (Discrete, Box, MultiDiscrete)
- Observation space correctly represents your state representation
- Reward shaping aligns with your learning objectives
- Termination conditions are properly defined
- Render modes work as expected

For more complex environments, ask Claude to add specific features:

```
Add hierarchical actions to the grid environment where the agent can move north/south/east/west. Include a step penalty and goal reward of 100. Add obstacle collision detection.
```

## Registering Custom Environments

Once your environment is built, you need to register it so you can use `gym.make()`:

```python
from gymnasium.envs.registration import register

register(
 id="GridNav-v0",
 entry_point="environments.grid_nav:GridNavEnv",
 max_episode_steps=200,
)
```

Ask Claude to generate this registration code along with the environment, and include it in your package's `__init__.py` for automatic registration on import.

## Integrating with Stable-Baselines3

Stable-Baselines3 (SB3) provides reliable implementations of popular RL algorithms. Claude Code can help you switch between algorithms and optimize their hyperparameters.

## Algorithm Comparison Table

| Algorithm | Action Space | Best For | Sample Efficiency |
|-----------|-------------|----------|-------------------|
| PPO | Discrete or Continuous | General purpose, stable | Medium |
| SAC | Continuous only | Continuous control, robotics | High |
| DQN | Discrete only | Simple discrete tasks | Low |
| TD3 | Continuous only | Deterministic policies | High |
| A2C | Discrete or Continuous | Fast training on CPU | Low |

Switching from PPO to SAC for continuous control tasks:

```
Convert this PPO training script to use SAC instead. The environment uses a Box action space with continuous values between -1 and 1.
```

Claude will handle the algorithm-specific parameters automatically. SAC uses different defaults for buffer size, batch size, and learning starts that PPO does not need.

For hyperparameter tuning, Claude can suggest starting configurations based on your environment:

```
What are good starting hyperparameters for PPO when training on a custom MountainCar environment? The state space has 2 continuous dimensions and action space is discrete with 3 actions.
```

Claude will provide tuned hyperparameters with explanations for each choice, helping you understand the relationship between settings and performance. A typical response includes a YAML config:

```yaml
ppo:
 learning_rate: 3.0e-4
 n_steps: 2048
 batch_size: 64
 n_epochs: 10
 gamma: 0.99
 gae_lambda: 0.95
 clip_range: 0.2
 ent_coef: 0.01
 vf_coef: 0.5
 max_grad_norm: 0.5
 policy_kwargs:
 net_arch: [64, 64]
```

## Advanced Training Patterns

## Vectorized Environments

For faster training, use multiple environments in parallel. Claude can help set this up:

```
Set up 8 parallel environments using stable_baselines3.common.vec_env.DummyVecEnv and SubprocVecEnv. Include proper multiprocessing handling.
```

The choice between `DummyVecEnv` (single process, lower overhead) and `SubprocVecEnv` (multiprocess, better for compute-heavy envs) depends on your environment:

```python
from stable_baselines3.common.vec_env import DummyVecEnv, SubprocVecEnv

Fast for lightweight envs (cart-pole, etc.)
dummy_env = DummyVecEnv([make_env(env_id, i) for i in range(4)])

Better for envs with heavy computation or rendering
subproc_env = SubprocVecEnv([make_env(env_id, i) for i in range(8)])
```

Ask Claude to add `VecNormalize` for observation and reward normalization. a technique that can significantly improve learning stability on environments with large or varied observation scales.

## Custom Callbacks

Track training progress with custom callbacks:

```
Create a custom callback that logs episode rewards to Weights & Biases, saves the model when mean reward exceeds 450, and prints training statistics every 10000 steps.
```

Claude generates a full callback class:

```python
import wandb
from stable_baselines3.common.callbacks import BaseCallback

class WandBCallback(BaseCallback):
 def __init__(self, save_threshold=450, log_freq=10000, verbose=0):
 super().__init__(verbose)
 self.save_threshold = save_threshold
 self.log_freq = log_freq
 self.best_mean_reward = -float("inf")

 def _on_step(self) -> bool:
 if self.n_calls % self.log_freq == 0:
 if len(self.model.ep_info_buffer) > 0:
 mean_reward = np.mean([ep["r"] for ep in self.model.ep_info_buffer])
 wandb.log({"mean_reward": mean_reward, "timestep": self.num_timesteps})

 if mean_reward > self.save_threshold and mean_reward > self.best_mean_reward:
 self.best_mean_reward = mean_reward
 self.model.save(f"best_model_{mean_reward:.0f}")
 if self.verbose > 0:
 print(f"New best mean reward: {mean_reward:.2f}, model saved.")
 return True
```

## Hyperparameter Optimization

For systematic hyperparameter tuning, Claude can set up Optuna integration:

```
Add Optuna hyperparameter optimization for PPO. Optimize learning_rate, n_steps, n_epochs, and ent_coef. Run 20 trials with 100000 timesteps each.
```

Claude generates an objective function and study setup:

```python
import optuna
from stable_baselines3 import PPO

def objective(trial):
 learning_rate = trial.suggest_float("learning_rate", 1e-5, 1e-3, log=True)
 n_steps = trial.suggest_categorical("n_steps", [512, 1024, 2048])
 n_epochs = trial.suggest_int("n_epochs", 3, 20)
 ent_coef = trial.suggest_float("ent_coef", 0.0, 0.1)

 env = gym.make("CartPole-v1")
 model = PPO(
 "MlpPolicy", env,
 learning_rate=learning_rate,
 n_steps=n_steps,
 n_epochs=n_epochs,
 ent_coef=ent_coef,
 verbose=0
 )
 model.learn(total_timesteps=100000)

 mean_reward, _ = evaluate_policy(model, env, n_eval_episodes=10)
 return mean_reward

study = optuna.create_study(direction="maximize")
study.optimize(objective, n_trials=20)
print("Best params:", study.best_params)
```

## Debugging RL Agents

When your agent isn't learning, Claude Code helps diagnose common issues:

```
My PPO agent isn't learning - it keeps getting around 50 reward on CartPole-v1 when it should reach 500. The loss is decreasing but performance is flat. What is wrong?
```

Typical issues Claude will identify:

- Reward scaling. rewards may need normalization
- Learning rate. too high can cause instability, too low causes slow learning
- Network architecture. may need more or fewer neurons for your observation complexity
- Exploration. entropy coefficient is too low, causing premature convergence
- Environment bugs. rewards or transitions is incorrect in custom environments

## Debugging Custom Environments

For custom environments, ask Claude to write a validation script:

```
Write a script to validate that my custom environment follows the Gymnasium API correctly. Check spaces, step returns, reset behavior, and reward consistency.
```

Claude generates a test harness:

```python
from gymnasium.utils.env_checker import check_env

env = GridNavEnv()
check_env(env, warn=True)

Manual sanity checks
obs, info = env.reset()
print(f"Observation shape: {obs.shape}, dtype: {obs.dtype}")
assert env.observation_space.contains(obs), "Initial obs not in observation space"

for _ in range(100):
 action = env.action_space.sample()
 obs, reward, terminated, truncated, info = env.step(action)
 assert env.observation_space.contains(obs), f"Obs not in space after step: {obs}"
 if terminated or truncated:
 obs, info = env.reset()

print("Environment validation passed.")
```

## Training Diagnostics

Claude Code can also help you instrument training to catch problems early:

```
Add diagnostic logging to my training loop that tracks value loss, policy loss, entropy, and explained variance. Alert me if any metric goes out of normal range.
```

Monitoring `explained_variance` is particularly useful. if it drops below 0.8 during training, your value function is struggling, which usually causes policy degradation.

## Deployment and Inference

Once trained, deploy your model for inference:

```
Create a Flask API that loads the trained PPO model and runs inference. Accept POST requests with observations and return actions. Include health check endpoint.
```

Claude generates a production-ready API with proper error handling, model loading, and response formatting:

```python
from flask import Flask, request, jsonify
from stable_baselines3 import PPO
import numpy as np

app = Flask(__name__)
model = PPO.load("ppo_cartpole_final")

@app.route("/health", methods=["GET"])
def health():
 return jsonify({"status": "ok"})

@app.route("/predict", methods=["POST"])
def predict():
 data = request.get_json()
 obs = np.array(data["observation"], dtype=np.float32)
 action, _states = model.predict(obs, deterministic=True)
 return jsonify({"action": int(action)})

if __name__ == "__main__":
 app.run(host="0.0.0.0", port=5000)
```

For higher-throughput scenarios, ask Claude to convert to a batched inference endpoint, or to package the model as a Docker container for easier deployment:

```
Create a Dockerfile for this Flask inference server. Use a slim Python base image and copy only the model file and application code.
```

## Exporting to ONNX

For deployment in non-Python environments, ask Claude to add ONNX export:

```
Add a script to export the trained SB3 policy network to ONNX format for deployment.
```

ONNX export allows you to run the policy in environments without Python or PyTorch, useful for edge deployments or integration with game engines.

## Best Practices for RL Development with Claude

Start Simple: Begin with basic environments like CartPole before moving to complex custom environments. This helps you verify your training pipeline works end-to-end before introducing the complexity of custom reward functions and state spaces.

Version Control Environments: Gymnasium environments can behave differently across versions. Pin versions in requirements.txt and document your environment specifications. Use a `versions.txt` or `environment.yml` to capture exact package versions after a successful training run.

Use Resumable Training: Always save checkpoints and implement resume functionality:

```
Add training resume capability - load the last checkpoint if it exists, otherwise start fresh. Save checkpoints every 50000 steps.
```

Claude generates a solid resume pattern:

```python
import os
from pathlib import Path

checkpoint_dir = Path("./logs/checkpoints")
checkpoints = sorted(checkpoint_dir.glob("*.zip"))

if checkpoints:
 latest = checkpoints[-1]
 print(f"Resuming from {latest}")
 model = PPO.load(latest, env=train_env)
else:
 print("Starting fresh training run")
 model = PPO("MlpPolicy", train_env, verbose=1)

model.learn(total_timesteps=500000, reset_num_timesteps=False)
```

Test Environment Dynamics: Verify your environment follows the Gymnasium API correctly:

```
Add pytest tests that verify the custom environment satisfies gymnasium API requirements - valid action/observation spaces, proper step/reset returns, etc.
```

Document Experiment Results: Ask Claude to generate experiment tracking templates that log hyperparameters, environment specs, and final performance metrics alongside your model checkpoints. This is invaluable when comparing different training runs weeks later.

Use Reproducible Seeds: Set seeds consistently in your training scripts to reproduce results. Claude can add seed management to ensure deterministic behavior across runs when needed for benchmarking.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-gymnasium-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Claude Code Skills to Install First 2026](/best-claude-code-skills-to-install-first-2026/)
- [Claude Code for Debugging Sessions](/best-way-to-use-claude-code-for-debugging-sessions/)
- [Workflows Hub](/workflows/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

