---
layout: default
title: "Claude Code Podman Rootless Container Guide"
description: "A practical guide to running Claude Code in Podman rootless containers for secure, isolated development environments."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-podman-rootless-container-guide/
---

{% raw %}
Running Claude Code inside Podman rootless containers gives developers a secure, reproducible way to use AI-assisted development without compromising system security. This guide walks through setting up a rootless Podman environment and configuring Claude Code to work seamlessly within it.

## Why Rootless Containers Matter

Rootless Podman runs containers without root privileges on the host system. This approach reduces the attack surface significantly—your development environment stays isolated, yet you maintain full control over the container lifecycle. For developers working with sensitive codebases or sharing systems, rootless containers provide an essential layer of security.

Unlike Docker, Podman operates daemonless by default. This means no persistent background service, fewer points of failure, and easier integration with systemd units. When you pair this with Claude Code, you get AI-powered development in an environment you can spin up and tear down instantly.

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

## Integrating Claude Skills

Claude Code excels when combined with specialized skills. The container environment supports full skill functionality. For frontend development tasks, use the frontend-design skill to generate responsive layouts and components:

```
Use the frontend-design skill to create a landing page component with Tailwind CSS.
```

Need to generate documentation? The pdf skill creates professional PDF output directly from your project files. For test-driven development workflows, invoke the tdd skill to scaffold test files alongside implementation code:

```
Apply the tdd skill to write unit tests for the authentication module.
```

The supermemory skill enables persistent context across sessions—useful when working on long-term projects. Install these skills within the container just as you would on a native system:

```bash
claude skill install frontend-design
claude skill install pdf
claude skill install tdd
claude skill install supermemory
```

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

## Security Considerations

Rootless Podman containers cannot access host resources beyond what you explicitly mount. However, follow these best practices:

- Never mount sensitive directories like `/etc` or `/root` unless absolutely necessary
- Use read-only mounts (`:ro`) where write access isn't needed
- Regularly update your container image to receive security patches

The combination of rootless containers and Claude Code gives you AI-assisted development without granting elevated privileges to either the container or the AI assistant.

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

## Conclusion

Running Claude Code in Podman rootless containers provides a secure, portable development environment. The setup takes minutes, and you gain isolation, reproducibility, and the full power of AI-assisted coding. Whether you're exploring new libraries, contributing to unfamiliar projects, or working with sensitive code, rootless containers keep your host system untouched while giving Claude Code everything it needs to help you build.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
