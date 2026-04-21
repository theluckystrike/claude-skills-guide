---
title: "Claude Code for Buf Protobuf Schema Management (2026)"
permalink: /claude-code-buf-protobuf-schema-management-2026/
description: "Manage Protobuf schemas with Buf and Claude Code. Lint proto files, detect breaking changes, and generate type-safe clients across languages."
last_tested: "2026-04-22"
domain: "API development"
render_with_liquid: false
---

## Why Claude Code for Buf Protobuf

Protocol Buffers are the standard for gRPC APIs, but managing proto files at scale is painful: backward compatibility breaks, inconsistent naming conventions, dependency management across repos, and code generation for multiple languages. Buf replaces the protoc toolchain with a modern CLI that lints proto files, detects breaking changes against git history, manages dependencies from the Buf Schema Registry (BSR), and generates code consistently.

Claude Code writes well-structured proto files that pass Buf's strict linting rules, configures breaking change detection in CI, and generates client/server stubs across Go, TypeScript, Python, and Java from a single source of truth.

## The Workflow

### Step 1: Initialize Buf Project

```bash
# Install Buf
brew install bufbuild/buf/buf

# Initialize project
mkdir -p proto && cd proto
buf config init

# Create directory structure
mkdir -p api/v1 api/v2 common
```

### Step 2: Write Lint-Compliant Proto Files

```protobuf
// proto/api/v1/user_service.proto
syntax = "proto3";

package api.v1;

import "google/protobuf/timestamp.proto";
import "google/protobuf/field_mask.proto";
import "buf/validate/validate.proto";

option go_package = "github.com/myorg/myapi/gen/go/api/v1;apiv1";
option java_multiple_files = true;
option java_package = "com.myorg.api.v1";

// UserService manages user accounts and profiles.
service UserService {
  // GetUser returns a single user by ID.
  rpc GetUser(GetUserRequest) returns (GetUserResponse);

  // ListUsers returns a paginated list of users.
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);

  // CreateUser creates a new user account.
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);

  // UpdateUser updates an existing user's fields.
  rpc UpdateUser(UpdateUserRequest) returns (UpdateUserResponse);

  // DeleteUser soft-deletes a user account.
  rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse);
}

message GetUserRequest {
  // Unique user identifier.
  string user_id = 1 [(buf.validate.field).string.uuid = true];
}

message GetUserResponse {
  User user = 1;
}

message ListUsersRequest {
  // Maximum number of users to return (default 50, max 200).
  int32 page_size = 1 [(buf.validate.field).int32 = {gte: 0, lte: 200}];

  // Pagination token from previous ListUsers response.
  string page_token = 2;

  // Filter expression (e.g., "status=ACTIVE").
  string filter = 3;

  // Sort order (e.g., "created_at desc").
  string order_by = 4;
}

message ListUsersResponse {
  repeated User users = 1;
  string next_page_token = 2;
  int32 total_count = 3;
}

message CreateUserRequest {
  // User to create. user_id must be empty.
  User user = 1 [(buf.validate.field).required = true];
}

message CreateUserResponse {
  User user = 1;
}

message UpdateUserRequest {
  // User with updated fields.
  User user = 1 [(buf.validate.field).required = true];

  // Fields to update. If empty, all fields are updated.
  google.protobuf.FieldMask update_mask = 2;
}

message UpdateUserResponse {
  User user = 1;
}

message DeleteUserRequest {
  string user_id = 1 [(buf.validate.field).string.uuid = true];
}

message DeleteUserResponse {}

// User represents a user account.
message User {
  // Unique identifier. Read-only, assigned by server.
  string user_id = 1;

  // Display name.
  string display_name = 2 [(buf.validate.field).string = {min_len: 1, max_len: 100}];

  // Email address. Must be unique.
  string email = 3 [(buf.validate.field).string.email = true];

  // Account status.
  UserStatus status = 4;

  // Creation timestamp. Read-only.
  google.protobuf.Timestamp created_at = 5;

  // Last update timestamp. Read-only.
  google.protobuf.Timestamp updated_at = 6;
}

enum UserStatus {
  USER_STATUS_UNSPECIFIED = 0;
  USER_STATUS_ACTIVE = 1;
  USER_STATUS_SUSPENDED = 2;
  USER_STATUS_DELETED = 3;
}
```

### Step 3: Configure Buf Linting and Breaking Change Detection

```yaml
# buf.yaml
version: v2
modules:
  - path: proto
    name: buf.build/myorg/myapi
deps:
  - buf.build/bufbuild/protovalidate
lint:
  use:
    - STANDARD
    - COMMENTS
  except:
    - PACKAGE_NO_IMPORT_CYCLE
breaking:
  use:
    - FILE
```

```yaml
# buf.gen.yaml
version: v2
managed:
  enabled: true
  override:
    - file_option: go_package_prefix
      value: github.com/myorg/myapi/gen/go
plugins:
  - remote: buf.build/protocolbuffers/go
    out: gen/go
    opt: paths=source_relative
  - remote: buf.build/connectrpc/go
    out: gen/go
    opt: paths=source_relative
  - remote: buf.build/connectrpc/es
    out: gen/ts
    opt: target=ts
  - remote: buf.build/bufbuild/es
    out: gen/ts
    opt: target=ts
```

### Step 4: Verify

```bash
# Lint proto files
buf lint

# Check for breaking changes against main branch
buf breaking --against '.git#branch=main'

# Generate code for all languages
buf generate

# Verify generated code compiles
cd gen/go && go build ./...
cd gen/ts && npx tsc --noEmit

# Push to BSR
buf push
```

## CLAUDE.md for Buf Protobuf Management

```markdown
# Buf Protobuf Schema Standards

## Domain Rules
- All messages follow Google API Design Guide naming conventions
- Request/Response message pairs for every RPC method
- Enum values prefixed with enum name (USER_STATUS_ACTIVE, not ACTIVE)
- First enum value must be UNSPECIFIED = 0
- All fields must have comments
- Use buf/validate for field validation
- Backward compatibility: no field number reuse, no type changes
- Package versioning: api.v1, api.v2 (not path-based)

## File Patterns
- proto/api/v1/*.proto (API definitions)
- proto/common/*.proto (shared messages)
- buf.yaml (module configuration)
- buf.gen.yaml (code generation configuration)
- buf.lock (dependency lock file)
- gen/ (generated code, gitignored or committed)

## Common Commands
- buf lint
- buf breaking --against '.git#branch=main'
- buf generate
- buf push
- buf mod update (update dependencies)
- buf build (verify proto files compile)
- buf curl --protocol grpc localhost:8080/api.v1.UserService/GetUser
```

## Common Pitfalls in Buf Protobuf Management

- **Breaking changes slip through:** Renaming fields, changing types, or reusing field numbers are breaking changes that Buf detects. Claude Code configures `buf breaking` in CI to block PRs that break backward compatibility.

- **Generated code committed but stale:** If generated code is committed to git but developers forget to regenerate after proto changes, the code drifts. Claude Code adds a CI check that regenerates and diffs against committed code.

- **Missing validation rules:** Proto files without buf/validate annotations accept any input, pushing validation to application code. Claude Code adds validation rules to every user-facing field at the proto level.

## Related

- [Claude Code for Pulumi Infrastructure as Code](/claude-code-pulumi-infrastructure-as-code-2026/)
- [Claude Code for Earthly CI Pipeline](/claude-code-earthly-ci-pipeline-2026/)
- [Claude Code for Pkl Configuration Language](/claude-code-pkl-configuration-language-2026/)
