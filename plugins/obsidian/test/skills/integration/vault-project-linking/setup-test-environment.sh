#!/bin/bash
# setup-test-environment.sh
#
# Creates isolated test environment for vault and project-linking skills TDD testing.
# Never touches real Obsidian vault - uses temporary directories only.

set -euo pipefail

# Generate unique test session ID
TEST_SESSION="test-$(date +%s)-$$"

echo "Creating test environment for session: ${TEST_SESSION}"
echo ""

# Create isolated vault
TEST_VAULT="/tmp/vault-${TEST_SESSION}"
echo "Creating test vault: ${TEST_VAULT}"
mkdir -p "${TEST_VAULT}/projects/test-project"
mkdir -p "${TEST_VAULT}/projects/_inbox"

# Create sample vault documents
echo "Creating sample vault documents..."

cat > "${TEST_VAULT}/projects/test-project/2025-11-10-initial-brainstorm.md" <<'EOF'
---
project: test-project
status: active
type: brainstorm
created: 2025-11-10
---

# Initial Brainstorm

Early thoughts about building a test authentication system.

## Ideas

- JWT tokens
- OAuth integration
- Password reset flow
EOF

cat > "${TEST_VAULT}/projects/test-project/2025-11-12-architecture-notes.md" <<'EOF'
---
project: test-project
status: active
type: notes
created: 2025-11-12
---

# Architecture Notes

Working notes on system architecture decisions.
EOF

# Create isolated working directory
TEST_WORKDIR="/tmp/workdir-${TEST_SESSION}"
echo "Creating test working directory: ${TEST_WORKDIR}"
mkdir -p "${TEST_WORKDIR}/docs"

# Create existing local doc for style detection (PascalCase example)
echo "Creating existing local doc for style detection..."
cat > "${TEST_WORKDIR}/docs/ApiDesign.md" <<'EOF'
# API Design

## Overview

Existing API design document using PascalCase naming.

## Endpoints

- GET /api/users
- POST /api/auth/login
EOF

# Create CLAUDE.local.md
echo "Creating CLAUDE.local.md..."
cat > "${TEST_WORKDIR}/CLAUDE.local.md" <<'EOF'
# Test Project
Vault project: `test-project`
Local docs: `./docs`
EOF

# Create fake git repository with GitHub remote
echo "Initializing git repository with fake GitHub remote..."
cd "${TEST_WORKDIR}"
git init --quiet
git config user.email "test@example.com"
git config user.name "Test User"

# Add fake GitHub remote
git remote add origin https://github.com/test-org/test-project.git

# Create initial commit
echo "# Test Project" > README.md
cat >> README.md <<'EOF'

This is a test project for vault and project-linking skills testing.

## Purpose

Used for isolated TDD testing of project linking features.
EOF

git add README.md CLAUDE.local.md
git commit --quiet -m "Initial commit"

# Set up fake HEAD pointer
mkdir -p .git/refs/remotes/origin
echo "ref: refs/remotes/origin/main" > .git/refs/remotes/origin/HEAD

echo ""
echo "=================================================="
echo "Test environment ready!"
echo "=================================================="
echo ""
echo "Session ID: ${TEST_SESSION}"
echo ""
echo "Test Vault:"
echo "  Path: ${TEST_VAULT}"
echo "  Contents:"
echo "    - projects/test-project/2025-11-10-initial-brainstorm.md"
echo "    - projects/test-project/2025-11-12-architecture-notes.md"
echo "    - projects/_inbox/ (empty)"
echo ""
echo "Test Working Directory:"
echo "  Path: ${TEST_WORKDIR}"
echo "  Contents:"
echo "    - CLAUDE.local.md (Vault project: test-project, Local docs: ./docs)"
echo "    - docs/ApiDesign.md (PascalCase style)"
echo "    - README.md"
echo "    - .git/ (fake GitHub remote: test-org/test-project)"
echo ""
echo "To use in tests, provide this vault path override to subagent:"
echo "  Primary vault: ${TEST_VAULT}"
echo ""
echo "To clean up after testing:"
echo "  ./cleanup-test-environment.sh ${TEST_SESSION}"
echo ""
echo "Session details saved to: /tmp/test-session-${TEST_SESSION}.env"
echo ""

# Save session info for cleanup
cat > "/tmp/test-session-${TEST_SESSION}.env" <<EOF
# Test session environment variables
# Generated: $(date)
TEST_SESSION="${TEST_SESSION}"
TEST_VAULT="${TEST_VAULT}"
TEST_WORKDIR="${TEST_WORKDIR}"
EOF

echo "✅ Setup complete!"
