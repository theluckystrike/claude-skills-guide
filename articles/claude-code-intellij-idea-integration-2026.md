---
layout: post
title: "How to Use Claude Code in IntelliJ IDEA 2026"
description: "Set up Claude Code in IntelliJ IDEA and JetBrains IDEs. Terminal integration, keybindings, and workflow tips for Java and Kotlin developers."
permalink: /claude-code-intellij-idea-integration-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Configure Claude Code to work seamlessly inside IntelliJ IDEA's built-in terminal for Java and Kotlin development. You will have AI-assisted coding directly in your JetBrains IDE without leaving the editor.

Expected time: 10 minutes setup, immediate productivity gains
Prerequisites: IntelliJ IDEA 2024.3+, Claude Code CLI installed, Node.js 18+

## Setup

### 1. Install Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

Confirms Claude Code is available system-wide for IntelliJ's terminal to access.

### 2. Configure IntelliJ Terminal Shell

Open IntelliJ IDEA settings and point the terminal to your preferred shell with Claude Code in its PATH.

```
Settings → Tools → Terminal → Shell path:
/bin/zsh  (macOS/Linux)
C:\Program Files\Git\bin\bash.exe  (Windows)

Environment variables:
ANTHROPIC_API_KEY=sk-ant-xxxxx
```

Set the API key in IntelliJ's terminal environment so Claude Code authenticates without extra configuration.

### 3. Create a CLAUDE.md for Your Java Project

```markdown
# Project Context

Java 21 project using Spring Boot 3.3 and Gradle 8.5.
Package structure: com.example.myapp
Test framework: JUnit 5 with Mockito
Code style: Google Java Format

## Conventions
- Use record types for DTOs
- Constructor injection only (no @Autowired on fields)
- All public methods must have Javadoc
- Integration tests use @SpringBootTest with TestContainers
```

Place this file at your project root so Claude Code understands your codebase conventions.

### 4. Set Up External Tool for Quick Access

```
Settings → Tools → External Tools → Add:
  Name: Claude Code
  Program: claude
  Arguments: (leave empty for interactive)
  Working directory: $ProjectFileDir$
```

This lets you launch Claude Code from the Tools menu or assign a keyboard shortcut.

### 5. Assign a Keybinding

```
Settings → Keymap → search "Claude Code" (External Tools):
  Assign: Ctrl+Shift+C (or Cmd+Shift+C on macOS)
```

### 6. Verify

```bash
cd /path/to/your/java-project
claude --print "List the source files in src/main/java"
# Expected output:
# Lists your Java source files from the project directory
```

## Usage Example

Here is a complete workflow for generating a Spring Boot REST controller with Claude Code inside IntelliJ's terminal:

```bash
# Open IntelliJ terminal (Alt+F12) and start Claude Code
claude

# Ask Claude to generate a new endpoint
> Create a REST controller for managing User entities with CRUD operations.
> Use Spring Boot 3.3 conventions, ResponseEntity returns, and add
> validation annotations on the request DTO.
```

Claude Code generates the controller:

```java
package com.example.myapp.controller;

import com.example.myapp.dto.CreateUserRequest;
import com.example.myapp.dto.UserResponse;
import com.example.myapp.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<UserResponse> createUser(
            @Valid @RequestBody CreateUserRequest request) {
        UserResponse created = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable UUID id) {
        return ResponseEntity.ok(userService.findById(id));
    }

    @GetMapping
    public ResponseEntity<List<UserResponse>> listUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(userService.findAll(page, size));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable UUID id,
            @Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.ok(userService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

Then generate the corresponding test:

```bash
> Now generate a JUnit 5 test for this controller using MockMvc and Mockito
```

```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void createUser_returnsCreated() throws Exception {
        CreateUserRequest request = new CreateUserRequest("John", "john@test.com");
        UserResponse response = new UserResponse(UUID.randomUUID(), "John", "john@test.com");
        when(userService.create(any())).thenReturn(response);

        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("John"));
    }
}
```

## Common Issues

- **Claude Code not found in IntelliJ terminal:** Ensure your shell profile (`.zshrc` or `.bashrc`) adds the npm global bin directory to PATH. Restart IntelliJ after changes.
- **API key not recognized:** Set `ANTHROPIC_API_KEY` in IntelliJ's terminal environment variables under Settings, not just in your shell profile, as IntelliJ may not source profile files.
- **Slow response in large monorepos:** Add a `.claudeignore` file excluding `build/`, `target/`, `.gradle/`, and `node_modules/` directories to reduce context scanning time.

## Why This Matters

Java developers using IntelliJ spend 60-70% of their time in the IDE. Having Claude Code accessible via a keybinding eliminates context switching and keeps code generation within your existing workflow.

## Related Guides

- [Claude Code for JetBrains Plugin Workflow](/claude-code-for-jetbrains-plugin-workflow-tutorial/)
- [How to Write Effective CLAUDE.md for Your Project](/how-to-write-effective-claude-md-for-your-project/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
