---

layout: default
title: "Claude Code Podman Rootless Container"
description: "Claude Code Podman Rootless Container — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-podman-rootless-container-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Running Claude Code inside Podman rootless containers gives developers a secure, reproducible way to use AI-assisted development without compromising system security. This guide walks through setting up a rootless Podman environment and configuring Claude Code to work smoothly within it. By the end you will have a portable, team-shareable container image that can spin up a full Claude Code session in under thirty seconds on any Linux host.

## Why Rootless Containers Matter

Rootless Podman runs containers without root privileges on the host system. This approach reduces the attack surface significantly, your development environment stays isolated, yet you maintain full control over the container lifecycle. For developers working with sensitive codebases or sharing systems, rootless containers provide an essential layer of security.

Unlike Docker, Podman operates daemonless by default. This means no persistent background service, fewer points of failure, and easier integration with systemd units. When you pair this with Claude Code, you get AI-powered development in an environment you can spin up and tear down instantly.

## Podman vs Docker for Rootless Development

The table below summarises the key differences relevant to a Claude Code workflow:

| Feature | Podman (rootless) | Docker (rootless) |
|---|---|---|
| Daemon required | No. each command is a direct fork/exec | No in rootless mode, but dockerd must run |
| Default user mapping | Host UID via user namespaces | Same |
| SELinux / AppArmor | Native `:z`/`:Z` volume label support | Requires manual label policy |
| Systemd integration | `podman generate systemd` built-in | Needs third-party tooling |
| Image format | OCI + Docker Hub compatible | Docker-native, OCI compatible |
| Compose support | `podman-compose` or `docker-compose` compat | `docker compose` (v2) |
| Installation on RHEL/Fedora | Included in base repos | Third-party RPM |

For a solo developer on Fedora or RHEL, Podman is the natural choice, it ships in the default repos and rootless operation requires zero post-install configuration. On Ubuntu and Debian the installation step is slightly more involved, but the operational model is identical once set up.

## Setting Up Podman for Rootless Operation

Most modern Linux distributions include Podman in their default repositories. On Fedora, CentOS, or RHEL:

```bash
sudo dnf install podman
```

On Ubuntu or Debian, you may need to add the Kubic repository:

```bash
. /etc/os-release
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -
sudo apt-get update
sudo apt-get install podman
```

Verify rootless operation works:

```bash
podman run --rm quay.io/podman/hello
```

If you see the Podman hello message, your user is configured correctly for rootless operation. The process runs entirely under your user ID, using user namespaces to map container root to an unprivileged host user.

## Verifying User Namespace Configuration

Rootless containers rely on `/etc/subuid` and `/etc/subgid` entries for your user. Check that they exist:

```bash
grep "$(whoami)" /etc/subuid /etc/subgid
```

You should see output like:

```
/etc/subuid:youruser:100000:65536
/etc/subgid:youruser:100000:65536
```

If these entries are missing, add them:

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $(whoami)
podman system migrate
```

The `podman system migrate` command updates existing storage to use the new mappings. After this, re-run the hello container to confirm everything works.

## Storage Driver Considerations

Rootless Podman defaults to the `overlay` storage driver when the kernel supports unprivileged overlay mounts (kernel 5.11+ with `fuse-overlayfs` as a fallback). Check which driver is active:

```bash
podman info --format '{{.Store.GraphDriverName}}'
```

If you see `vfs`, your kernel does not support unprivileged overlayfs and Podman is falling back to a slower copy-based driver. Install `fuse-overlayfs` to improve layer caching performance:

```bash
sudo dnf install fuse-overlayfs # Fedora / RHEL
sudo apt-get install fuse-overlayfs # Debian / Ubuntu
```

## Creating the Claude Code Container Image

Build a custom container image that includes Claude Code and its dependencies. Create a Containerfile:

```dockerfile
FROM fedora:40

RUN dnf install -y \
 nodejs \
 npm \
 git \
 curl \
 ca-certificates \
 && dnf clean all

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && dnf install -y nodejs \
 && dnf clean all

RUN npm install -g claude-code

RUN mkdir -p /homedeveloper && \
 useradd -m -u 1000 -s /bin/bash developer && \
 chown -R developer:developer /homedeveloper

USER developer
WORKDIR /homedeveloper
ENV HOME=/homedeveloper
```

Build and tag the image:

```bash
podman build -t claude-code-dev:latest .
```

## Multi-Stage Build for a Leaner Image

The single-stage Containerfile above is straightforward, but installing build tools in the final image inflates its size. A multi-stage build keeps the runtime image small:

```dockerfile
Stage 1: install Node and Claude Code
FROM fedora:40 AS builder

RUN dnf install -y nodejs npm git curl ca-certificates && dnf clean all
RUN npm install -g claude-code

Stage 2: minimal runtime
FROM fedora:40

Copy only the global npm prefix from the builder
COPY --from=builder /usr/lib/node_modules /usr/lib/node_modules
COPY --from=builder /usr/bin/node /usr/bin/node
COPY --from=builder /usr/bin/claude /usr/bin/claude

RUN dnf install -y git ca-certificates && dnf clean all

RUN useradd -m -u 1000 -s /bin/bash developer && \
 mkdir -p /homedeveloper && \
 chown -R developer:developer /homedeveloper

USER developer
WORKDIR /homedeveloper
ENV HOME=/homedeveloper

ENTRYPOINT ["claude"]
```

Build with:

```bash
podman build -t claude-code-dev:latest -f Containerfile.multistage .
```

The multi-stage approach typically reduces the final image size by 30–50% compared to a single-stage build because DNF metadata, build caches, and intermediate artifacts are left behind in the builder stage.

## Pinning the Node Version

For reproducible builds across team members, pin the exact Node version rather than relying on `dnf install nodejs`:

```dockerfile
ARG NODE_VERSION=20.12.2
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz \
 | tar -xz -C /usr/local --strip-components=1
```

Pass a different version at build time with `--build-arg NODE_VERSION=22.0.0` if you need to test across Node versions.

## Running Claude Code in the Container

Mount your project directory into the container to work with your actual codebase:

```bash
podman run -it --rm \
 -v $(pwd):/homedeveloper/project:z \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 claude
```

The `:z` flag in the volume mount ensures correct SELinux labeling on Fedora and RHEL systems. This command drops you into an interactive Claude Code session with access to your project files.

## Volume Mount Flags at a Glance

| Flag | Meaning | When to Use |
|---|---|---|
| `:z` | Shared relabeling for SELinux | Multiple containers need access to the same volume |
| `:Z` | Private relabeling for SELinux | Only one container should access the volume |
| `:ro` | Read-only mount | Source code you want to prevent the container from modifying |
| `:rw` | Read-write mount (default) | Any directory the container needs to write to |
| `:U` | Map host UID/GID to container user | Avoid permission mismatches in rootless mode |

The `:U` flag is particularly useful in rootless environments. Without it, files written by the container may appear to belong to a high-numbered UID (a sub-UID mapping) on the host. With `:U`, Podman remaps the container's UID 1000 to your host UID automatically.

```bash
podman run -it --rm \
 -v $(pwd):/homedeveloper/project:z,U \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 claude
```

## Persisting Claude Code Configuration

Your Claude Code settings and conversation history live in `~/.claude`. To preserve these across container runs:

```bash
podman run -it --rm \
 -v $(pwd):/homedeveloper/project:z \
 -v ~/.claude:/homedeveloper/.claude:z \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 claude
```

You might also want to create a shell alias for convenience:

```bash
alias claude-dev='podman run -it --rm \
 -v $(pwd):/homedeveloper/project:z \
 -v ~/.claude:/homedeveloper/.claude:z \
 -w /homedeveloper/project \
 claude-code-dev:latest claude'
```

Add this to your `~/.bashrc` for persistent access.

## What Lives in ~/.claude

Understanding what the `~/.claude` directory contains helps you decide what to mount and what to leave out:

| Path | Contents | Mount? |
|---|---|---|
| `~/.claude/settings.json` | Global preferences, model selection | Yes. your personal config |
| `~/.claude/skills/` | Installed skill Markdown files | Yes. skills follow you across projects |
| `~/.claude/conversations/` | Session history | Optional. large over time |
| `~/.claude/credentials` | API key storage | Yes. required to authenticate |

If you prefer not to mount the entire `~/.claude` directory (for example, on a shared build server where you do not want the host credentials inside the container), pass the API key as an environment variable instead:

```bash
podman run -it --rm \
 -v $(pwd):/homedeveloper/project:z \
 -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 claude
```

Claude Code reads `ANTHROPIC_API_KEY` from the environment, so this works as a zero-credential-file alternative.

## Integrating Claude Skills

Claude Code excels when combined with specialized skills. The container environment supports full skill functionality. For frontend development tasks, use the frontend-design skill to generate responsive layouts and components:

```
Use the frontend-design skill to create a landing page component with Tailwind CSS.
```

Need to generate documentation? The pdf skill creates professional PDF output directly from your project files. For test-driven development workflows, invoke the tdd skill to scaffold test files alongside implementation code:

```
Apply the tdd skill to write unit tests for the authentication module.
```

The supermemory skill enables persistent context across sessions, useful when working on long-term projects. Install skills within the container by placing skill Markdown files in `~/.claude/skills/` (which you've mounted from your host via `-v ~/.claude:/homedeveloper/.claude:z`). Any skill files already in your host `~/.claude/skills/` directory will be available automatically.

## Baking Skills Into the Image

For team deployments where everyone should have the same skill set, embed skills directly in the image:

```dockerfile
FROM claude-code-dev:latest

Add a layer with shared skills
RUN mkdir -p /homedeveloper/.claude/skills
COPY skills/ /homedeveloper/.claude/skills/
```

Build a team image from this Containerfile and push it to an internal registry. Every developer pulls the same image and gets the same skill set without any manual installation. When skills are updated, rebuild and push the image, developers pull the new version with `podman pull`.

## Practical Development Workflow

Consider a typical workflow: you're contributing to an open-source project and want to test changes in an isolated environment. Start your container:

```bash
podman run -d --name dev-session \
 -v $(pwd):/homedeveloper/project:z \
 -v ~/.claude:/homedeveloper/.claude:z \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 sleep infinity
```

Attach to the running container for interactive sessions:

```bash
podman exec -it dev-session claude
```

This approach keeps the container alive between Claude Code invocations, preserving your conversation context. When finished, clean up:

```bash
podman rm -f dev-session
```

## Managing Multiple Projects Simultaneously

When you work on several projects at the same time, name containers after the project to avoid confusion:

```bash
project_name=$(basename $(pwd))

podman run -d \
 --name "claude-${project_name}" \
 -v $(pwd):/homedeveloper/project:z \
 -v ~/.claude:/homedeveloper/.claude:z \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 sleep infinity

podman exec -it "claude-${project_name}" claude
```

List all running Claude sessions with:

```bash
podman ps --filter name=claude-
```

Stop all of them at once when you are done for the day:

```bash
podman ps --filter name=claude- --format '{{.Names}}' | xargs podman rm -f
```

## Security Considerations

Rootless Podman containers cannot access host resources beyond what you explicitly mount. However, follow these best practices:

- Never mount sensitive directories like `/etc` or `/root` unless absolutely necessary
- Use read-only mounts (`:ro`) where write access isn't needed
- Regularly update your container image to receive security patches

The combination of rootless containers and Claude Code gives you AI-assisted development without granting elevated privileges to either the container or the AI assistant.

## Network Isolation

By default, Podman rootless containers use a user-mode network stack (`slirp4netns` or `pasta`). This means the container can initiate outbound connections, required for Claude Code to reach the Anthropic API, but no inbound ports are exposed on the host unless you explicitly publish them. For most development use cases this is exactly the right default.

If you need to run a local web server alongside Claude Code (for example, to preview a documentation site), publish only the specific port you need:

```bash
podman run -it --rm \
 -v $(pwd):/homedeveloper/project:z \
 -v ~/.claude:/homedeveloper/.claude:z \
 -p 127.0.0.1:3000:3000 \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 claude
```

Binding to `127.0.0.1` rather than `0.0.0.0` ensures the port is only accessible from the local machine, not exposed on the network.

## Running with a Read-Only Root Filesystem

For maximum isolation, run the container with a read-only root filesystem and only writable tmpfs mounts where the process actually needs write access:

```bash
podman run -it --rm \
 --read-only \
 --tmpfs /tmp:rw,noexec,nosuid,size=512m \
 --tmpfs /homedeveloper/.npm:rw,size=256m \
 -v $(pwd):/homedeveloper/project:z \
 -v ~/.claude:/homedeveloper/.claude:z \
 -w /homedeveloper/project \
 claude-code-dev:latest \
 claude
```

With `--read-only`, any attempt to write to the container filesystem outside the tmpfs mounts and your volume-mounted directories will fail immediately. This makes the container's behaviour entirely predictable and prevents any tool Claude invokes from writing files outside your project directory.

## Automating Container Management

For teams, consider creating a wrapper script that handles common tasks:

```bash
#!/bin/bash
IMAGE="claude-code-dev:latest"
PROJECT_DIR="$(pwd)"

case "$1" in
 start)
 podman run -d --name claude-dev \
 -v "$PROJECT_DIR":/homedeveloper/project:z \
 -v "$HOME/.claude":/homedeveloper/.claude:z \
 -w /homedeveloper/project \
 "$IMAGE" sleep infinity
 ;;
 shell)
 podman exec -it claude-dev claude
 ;;
 stop)
 podman rm -f claude-dev
 ;;
 *)
 echo "Usage: $0 {start|shell|stop}"
 ;;
esac
```

Save this as `claude-dev` in your PATH for quick container management.

## Generating a Systemd Unit for Automatic Startup

Podman can generate a systemd user unit that starts your development container on login and stops it on logout:

```bash
Start the container once to generate the unit
podman run -d --name claude-dev \
 -v "$HOME/projects":/homedeveloper/project:z \
 -v "$HOME/.claude":/homedeveloper/.claude:z \
 claude-code-dev:latest sleep infinity

Generate the unit file
mkdir -p ~/.config/systemd/user
podman generate systemd --name --files claude-dev
mv container-claude-dev.service ~/.config/systemd/user/

Enable and start
systemctl --user daemon-reload
systemctl --user enable --now container-claude-dev.service
```

After this, the container starts automatically when you log in. Attach to it any time with `podman exec -it claude-dev claude`. No manual `podman run` is needed.

## Keeping the Image Updated

Claude Code releases frequently. Add an update step to your team's CI pipeline or create a cron job:

```bash
#!/bin/bash
update-claude-dev.sh
set -e

echo "Building updated image..."
podman build --pull -t claude-code-dev:latest /path/to/containerfile-dir

echo "Pruning old images..."
podman image prune -f

echo "Done. Restart your dev container to pick up the update."
```

The `--pull` flag tells Podman to always fetch the latest version of the base image (`fedora:40`) before building, ensuring OS-level security patches are included.

## Conclusion

Running Claude Code in Podman rootless containers provides a secure, portable development environment. The setup takes minutes, and you gain isolation, reproducibility, and the full power of AI-assisted coding. Whether you're exploring new libraries, contributing to unfamiliar projects, or working with sensitive code, rootless containers keep your host system untouched while giving Claude Code everything it needs to help you build.

The combination of daemonless operation, user namespace isolation, SELinux labeling, and optional read-only root filesystems makes Podman the most security-forward choice for containerised development on Linux. Pair that with Claude Code's ability to understand context, generate code, run tests, and iterate, all within the boundaries of the volumes you explicitly mount, and you have an environment that is both powerful and auditable.

Start with the alias approach for local development, graduate to the wrapper script when you want to share the workflow with your team, and use the systemd unit when you need the container available the moment you log in.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-podman-rootless-container-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code Podman Container Workflow Setup Tutorial](/claude-code-podman-container-workflow-setup-tutorial/)
- [Chrome Extension Docker Dashboard: Streamlined Container.](/chrome-extension-docker-dashboard/)
- [Chrome Extension Multi Account Container: A Developer Guide](/chrome-extension-multi-account-container/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


