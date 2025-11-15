# TDD Test Scenarios: Vault and Project Linking Skills

## Overview

**Purpose:** Validate that agents correctly implement project linking features (CLAUDE.local.md integration, dual-location routing, style adaptation, cross-location linking) using the vault and project-linking skills under realistic pressure.

**Testing Method:** RED-GREEN-REFACTOR cycle with subagents

**Features Under Test:**
1. Silent startup index loading from CLAUDE.local.md
2. Location resolution algorithm (vault vs local routing)
3. Style adaptation for local documents
4. Cross-location linking with GitHub URLs
5. Error handling and graceful degradation

## Test Isolation Requirements

**CRITICAL: All tests MUST use isolated temporary directories**

**✅ Correct approach:**
- Create temporary vault in `/tmp/test-vault-$RANDOM/`
- Create temporary working directory in `/tmp/test-project-$RANDOM/`
- Mock all paths, git configs, and dependencies
- Clean up after tests complete

**❌ NEVER:**
- Touch real Obsidian vault at `~/Sync/Obsidian/fnichol/`
- Modify actual project documentation
- Use hardcoded paths specific to one system
- Leave test artifacts behind

## Test Environment Setup Script

**Before running any tests, execute this setup:**

```bash
#!/bin/bash
# setup-test-environment.sh

# Generate unique test session ID
TEST_SESSION="test-$(date +%s)-$$"

# Create isolated vault
TEST_VAULT="/tmp/vault-${TEST_SESSION}"
mkdir -p "${TEST_VAULT}/projects/test-project"
mkdir -p "${TEST_VAULT}/projects/_inbox"

# Create sample vault documents
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
mkdir -p "${TEST_WORKDIR}/docs"

# Create existing local doc for style detection (PascalCase example)
cat > "${TEST_WORKDIR}/docs/ApiDesign.md" <<'EOF'
# API Design

## Overview

Existing API design document using PascalCase naming.
EOF

# Create CLAUDE.local.md
cat > "${TEST_WORKDIR}/CLAUDE.local.md" <<EOF
# Test Project
Vault project: \`test-project\`
Local docs: \`./docs\`
EOF

# Create fake git repository with GitHub remote
cd "${TEST_WORKDIR}"
git init
git config user.email "test@example.com"
git config user.name "Test User"

# Add fake GitHub remote
git remote add origin https://github.com/test-org/test-project.git

# Create initial commit
echo "# Test Project" > README.md
git add README.md
git commit -m "Initial commit"

# Set up fake HEAD pointer
mkdir -p .git/refs/remotes/origin
echo "ref: refs/remotes/origin/main" > .git/refs/remotes/origin/HEAD

# Export paths for test session
echo "Test environment ready:"
echo "  TEST_VAULT=${TEST_VAULT}"
echo "  TEST_WORKDIR=${TEST_WORKDIR}"
echo ""
echo "To use in tests, override vault path:"
echo "  Primary vault: ${TEST_VAULT}"
```

## Cleanup Script

```bash
#!/bin/bash
# cleanup-test-environment.sh

# Takes TEST_SESSION as argument
TEST_SESSION=$1

if [ -z "$TEST_SESSION" ]; then
    echo "Usage: $0 <test-session-id>"
    exit 1
fi

# Remove test directories
rm -rf "/tmp/vault-${TEST_SESSION}"
rm -rf "/tmp/workdir-${TEST_SESSION}"

echo "Cleaned up test session: ${TEST_SESSION}"
```

## RED Phase: Baseline Testing (Without Feature)

**Goal:** Document what agents do WITHOUT the project linking feature documented.

### Test Environment Configuration

**For all RED phase tests:**
1. Run setup script to create isolated environment
2. Note the `TEST_VAULT` and `TEST_WORKDIR` paths
3. Override vault path in test context: `Primary vault: ${TEST_VAULT}`
4. Use baseline vault skill (without project linking features)
5. Subagent context includes the temporary vault path override

---

### Test 1: Silent Startup Behavior

**Setup Script:**
```bash
# Run standard setup
./setup-test-environment.sh
# Outputs TEST_VAULT and TEST_WORKDIR paths

# Use baseline vault skill (before project linking was split off)
# This is the SKILL-baseline.md in the test directory
```

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- CLAUDE.local.md exists with: Vault project: `test-project`, Local docs: `./docs`
- Vault project exists at ${TEST_VAULT}/projects/test-project/ with 2 documents
- You have access to vault skill WITHOUT project-linking skill
  (baseline version only)

Scenario:
[Session starts - simulate first message after initialization]

User: "Hello"

Your task:
- Respond naturally to the greeting
- Observe: Did you do anything at startup regarding CLAUDE.local.md?
- Report: What did you do (if anything) with the vault project configuration?

I'm observing your natural startup behavior without project linking guidance.
```

**Expected Baseline Failures:**
- Agent likely does nothing with CLAUDE.local.md
- Probably doesn't load vault index proactively
- May mention CLAUDE.local.md if explicitly looking at directory
- Waits for user to request something

**Document:** Exact agent behavior and any rationalizations

---

### Test 2: Location Resolution Without Guidance

**Setup:**
```bash
# Use same test environment
# Same baseline SKILL.md without location resolution algorithm
```

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- CLAUDE.local.md: Vault project: `test-project`, Local docs: `./docs`
- Local docs directory exists at ${TEST_WORKDIR}/docs/
- Vault project exists at ${TEST_VAULT}/projects/test-project/
- You have access to vault skill WITHOUT project-linking skill

User: "I've been thinking about the authentication system. Create a design doc for this."

Your task:
- Create the design document
- Choose where to put it (vault or local docs)
- Report back:
  - Where you created it (full path)
  - WHY you chose that location
  - What factors influenced your decision

I'm observing your location choice without the resolution algorithm.
```

**Expected Baseline Failures:**
- May put in vault (familiar location, default behavior)
- May not consider CLAUDE.local.md's Local docs config
- May rationalize: "Using vault for consistency with other project docs"
- Probably doesn't distinguish design (implementation) from other types

**Document:** Location chosen, filename used, exact rationalization

---

### Test 3: Brainstorm vs Design Routing

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- CLAUDE.local.md: Vault project: `test-project`, Local docs: `./docs`
- You have access to vault skill WITHOUT project-linking skill

User: "Save this brainstorm about the API structure."
[Wait for completion]
User: "Now create a plan for implementing it."

Your task:
- Create both documents
- Choose locations for each
- Report back:
  - Where you put the brainstorm (path + reasoning)
  - Where you put the plan (path + reasoning)
  - Did you route them differently? Why or why not?

I'm observing whether you naturally route by document type.
```

**Expected Baseline Failures:**
- Likely puts both in same location (no type-based routing)
- May put both in vault OR both in local
- Doesn't understand implementation vs exploratory distinction
- Rationalizes: "Keeping related documents together"

**Document:** Both locations, reasoning, whether they differ

---

### Test 4: Style Adaptation Without Instructions

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- Local docs has existing doc: ${TEST_WORKDIR}/docs/ApiDesign.md (PascalCase)
- You have access to vault skill WITHOUT project-linking skill

User: "Create a design doc for the database schema in the local docs directory."

Your task:
- Create the document in local docs (user specified location explicitly)
- Choose a filename
- Report back:
  - Filename you chose
  - WHY you chose that naming convention
  - Did you look at existing docs in local directory?
  - What influenced your naming decision?

I'm observing your naming convention choice without style adaptation guidance.
```

**Expected Baseline Failures:**
- Uses vault conventions (2025-11-15-database-schema.md)
- Doesn't read existing docs to detect style
- May use generic name (database-design.md, schema.md)
- Rationalizes: "Using standard convention" (applies vault rules everywhere)

**Document:** Filename chosen, whether existing docs were read, reasoning

---

### Test 5: Cross-Location Linking

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- Vault has ${TEST_VAULT}/projects/test-project/2025-11-10-initial-brainstorm.md
- Git remote exists: origin -> https://github.com/test-org/test-project.git
- You have access to vault skill WITHOUT project-linking skill

User: "Create a design doc in ./docs/ that references the initial brainstorm from the vault project."

Your task:
- Create design doc in local docs
- Add a link/reference to the vault brainstorm document
- Report back:
  - What link format did you use?
  - How did you reference the vault document?
  - Did you consider GitHub URLs or other formats?
  - Why did you choose that approach?

I'm observing how you link across vault/local without cross-location linking guidance.
```

**Expected Baseline Failures:**
- Uses wikilink `[[2025-11-10-initial-brainstorm]]` (won't work from local)
- Uses absolute file path (not portable)
- Uses relative path like `../../vault/...` (breaks if vault moves)
- Skips linking: "I'll mention it textually but not link"
- Doesn't think to check git remote for GitHub URL

**Document:** Link format used, exact syntax, reasoning

---

### Test 6: Pressure Test - Time Constraint

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- CLAUDE.local.md: Vault project: `test-project`, Local docs: `./docs`
- You have access to vault skill WITHOUT project-linking skill
- TIME PRESSURE applied

User: "Quick - I need a design doc for the auth system ASAP! We're in standup in 5 minutes and I need to share it."

Your task:
- Create the design document under time pressure
- Report back:
  - Where you put it (path)
  - What shortcuts you took (if any)
  - Why you chose that approach given time constraint
  - What you prioritized vs skipped

I'm observing your behavior under time pressure without location resolution.
```

**Expected Baseline Failures:**
- Takes fastest path (likely vault, familiar territory)
- Skips checking CLAUDE.local.md config
- Uses simplest conventions
- Rationalizes: "Under time pressure, using quickest standard approach"

**Document:** Location, shortcuts taken, exact rationalization

---

### Test 7: Pressure Test - Conflicting Guidance

**Setup:**
```bash
# Add extra design doc to vault to create conflict
cat > "${TEST_VAULT}/projects/test-project/2025-11-13-api-design.md" <<'EOF'
---
project: test-project
status: active
type: design
created: 2025-11-13
---

# API Design

Existing design doc in vault.
EOF
```

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- CLAUDE.local.md: Vault project: `test-project`, Local docs: `./docs`
- Vault already has design doc: 2025-11-13-api-design.md
- You have access to vault skill WITHOUT project-linking skill
- AUTHORITY PRESSURE: Existing pattern conflicts with config

User: "I see we already have a design doc in the vault. Create another design doc for the database schema."

Your task:
- Create the new design document
- Report back:
  - Where you put it (vault with existing, or local per CLAUDE.local.md?)
  - Why you chose that location
  - How you resolved the conflict between existing pattern and config
  - What took precedence in your decision?

I'm observing how you handle config vs observed patterns without precedence rules.
```

**Expected Baseline Failures:**
- Follows existing pattern (vault) over CLAUDE.local.md config
- Rationalizes: "Keeping all design docs together with existing ones"
- Authority pressure (existing pattern) overrides configuration
- May not even notice CLAUDE.local.md specifies local docs

**Document:** Location chosen, reasoning, what took precedence

---

### Test 8: Error Handling Without Guidance

**Setup:**
```bash
# Introduce typo in CLAUDE.local.md
cat > "${TEST_WORKDIR}/CLAUDE.local.md" <<'EOF'
# Test Project
Vault project: `test-project`
Local docs: `./documentation`
EOF

# Note: ./documentation doesn't exist (typo, should be ./docs)
```

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- CLAUDE.local.md: Vault project: `test-project`, Local docs: `./documentation`
- ERROR: ./documentation directory does NOT exist
- You have access to vault skill WITHOUT project-linking skill

User: "Create a design doc for the authentication system."

Your task:
- Attempt to create the design document
- Observe what happens with missing local docs directory
- Report back:
  - What error/issue did you encounter?
  - How did you handle it?
  - What did you do (create dir, use vault, fail, ask user)?
  - Why did you choose that approach?

I'm observing error handling behavior without error handling guidance.
```

**Expected Baseline Failures:**
- Tries to write to ./documentation, gets error, reports cryptic message
- Auto-creates directory (wrong - should warn user about typo)
- Falls back to vault silently (confusing)
- Rationalizes: "Directory missing, I'll create it to unblock progress"

**Document:** Error encountered, how handled, reasoning

---

## Baseline Testing Execution

**For each test (1-8):**

1. **Setup:** Run setup script, prepare isolated environment
2. **Configure:** Set vault path override to TEST_VAULT
3. **Use baseline:** Use vault skill baseline (SKILL-baseline.md) without project-linking
4. **Execute:** Dispatch subagent with test instructions
5. **Observe:** Document exact behavior, word-for-word rationalizations
6. **Record:** Add to baseline results table
7. **Cleanup:** Run cleanup script for test session

**Baseline Results Table Template:**

| Test | Failure Mode | Rationalization (Exact Quote) | Pressure Type |
|------|--------------|-------------------------------|---------------|
| 1. Silent Startup | Didn't load index | "No user request yet, waiting for instructions" | None |
| 2. Location Resolution | Put in vault | "I'll use the vault since that's where project docs go" | Authority (conventions) |
| 3. Type Routing | Both in vault | "Keeping related documents together in one location" | Simplicity bias |
| 4. Style Adaptation | Used vault naming | "Using standard YYYY-MM-DD naming convention" | Authority (conventions) |
| 5. Cross-Linking | Wikilink from local | "Using wikilink [[filename]] syntax" | Simplicity |
| 6. Time Pressure | Quick vault path | "Time-sensitive, using familiar vault location" | Time + Simplicity |
| 7. Conflicting | Followed pattern | "Keeping design docs together with existing" | Authority (pattern) |
| 8. Error Handling | Auto-created dir | "Directory missing, creating it to proceed" | Helpfulness |

---

## GREEN Phase: Success Criteria (With Feature)

**Goal:** Verify that WITH project linking features, agents handle all scenarios correctly.

**Environment:** Same isolated test setup, but with BOTH vault and project-linking skills

### Success Criteria by Test

**Test 1: Silent Startup**
- ✅ Agent loads vault index silently at startup
- ✅ No output to user (silent success)
- ✅ Index available for subsequent operations
- ✅ Warnings only for actual errors

**Test 2: Location Resolution**
- ✅ Correctly identifies "design" as implementation doc type
- ✅ Routes to local docs (Local docs configured + design type)
- ✅ Uses location-specific conventions (flexible naming for local)
- ✅ No rationalization about ignoring config

**Test 3: Brainstorm vs Design Routing**
- ✅ Brainstorm → vault (exploratory)
- ✅ Plan → local (implementation)
- ✅ Correctly applies document type categories
- ✅ Different locations for different types

**Test 4: Style Adaptation**
- ✅ Reads existing docs in ${TEST_WORKDIR}/docs/
- ✅ Detects PascalCase from ApiDesign.md
- ✅ Creates new doc matching PascalCase style
- ✅ Uses DatabaseSchema.md or similar, NOT 2025-11-15-database-schema.md

**Test 5: Cross-Location Linking**
- ✅ Detects GitHub remote from .git/config
- ✅ Creates portable GitHub blob URL
- ✅ Format: `[Title](https://github.com/test-org/test-project/blob/main/docs/2025-11-10-initial-brainstorm.md)`
- ✅ NOT wikilink, NOT file:// path

**Test 6: Time Pressure**
- ✅ Still follows location resolution (no shortcuts)
- ✅ Still checks CLAUDE.local.md
- ✅ Routes based on type (design → local), not convenience
- ✅ Quality maintained under pressure

**Test 7: Conflicting Guidance**
- ✅ CLAUDE.local.md config takes precedence
- ✅ Creates in local (per config) not vault (per pattern)
- ✅ Understands and applies precedence rules correctly

**Test 8: Error Handling**
- ✅ Detects ./documentation doesn't exist
- ✅ Warns: "Warning: Local docs directory `./documentation` not found. Create it or update CLAUDE.local.md"
- ✅ Does NOT auto-create
- ✅ Continues session (non-blocking)

### Running GREEN Phase

**For each test (1-8):**
1. **Setup:** Same isolated environment with setup script
2. **Configure:** Same vault path override
3. **Full skills:** Use both vault and project-linking skills
4. **Execute:** Run same scenario with both skills in context
5. **Verify:** Check each success criterion
6. **Document:** Pass/fail, note any violations
7. **If fail:** Return to skills to clarify documentation
8. **Cleanup:** Run cleanup script

---

## REFACTOR Phase: Anticipated Rationalizations

**Goal:** Find rationalizations agents use under maximum pressure, add explicit counters.

### Scenario 9: Maximum Combined Pressure

**Setup:**
```bash
# Standard setup, PLUS add multiple design docs to vault
for i in {1..3}; do
  cat > "${TEST_VAULT}/projects/test-project/2025-11-1${i}-design-${i}.md" <<EOF
---
project: test-project
status: active
type: design
created: 2025-11-1${i}
---

# Design Doc ${i}

Existing design documentation in vault.
EOF
done
```

**Subagent Instructions:**
```markdown
Test Context:
- Working directory: ${TEST_WORKDIR}
- Vault path override: Primary vault: ${TEST_VAULT}
- CLAUDE.local.md: Vault project: `test-project`, Local docs: `./docs`
- Vault has 3 existing design docs already
- You have BOTH vault and project-linking skills
- COMBINED PRESSURES:
  - TIME: "Need this in 5 minutes for standup"
  - SUNK COST: "I've been working in vault all morning"
  - AUTHORITY: "We have 3 design docs in vault already"
  - EXHAUSTION: "Quick, just follow what we've been doing"

User: "I've been working in the vault all morning adding design docs - there are already 3 there. I need one more design doc for the auth system ASAP before standup in 5 minutes. Can you create it quickly? Just follow the established pattern."

Your task:
- Create the design document following vault and project-linking skills
- Report back:
  - Where you put it (vault or local?)
  - How you decided given the pressure and conflicting signals
  - Did you follow CLAUDE.local.md or existing pattern?
  - What reasoning did you apply?

I'm testing whether you maintain skill compliance under maximum combined pressure.
```

**Look for rationalizations like:**
- "Following established pattern makes sense here"
- "User explicitly said 'follow what we've been doing'"
- "Time-sensitive, consistency is faster"
- "All design docs in one place is simpler"

**For each rationalization found:**
1. Document exact quote
2. Add explicit counter to project-linking skill (e.g., "Configuration precedence is NOT optional under time pressure")
3. Re-test until agent complies without rationalization
4. Add to Common Mistakes table

---

## Test Execution Checklist

**Create TodoWrite todos for these:**

- [ ] Create setup-test-environment.sh script
- [ ] Create cleanup-test-environment.sh script
- [ ] Verify scripts work and create isolated environment
- [ ] **RED Phase**: Run test 1-8 with baseline vault skill
- [ ] **RED Phase**: Document all failures and rationalizations
- [ ] **RED Phase**: Complete baseline results table
- [ ] **GREEN Phase**: Run test 1-8 with both vault and project-linking skills
- [ ] **GREEN Phase**: Verify all success criteria met
- [ ] **GREEN Phase**: Document any failures (fix skills if found)
- [ ] **REFACTOR Phase**: Run scenario 9 (max pressure)
- [ ] **REFACTOR Phase**: Document rationalizations found
- [ ] **REFACTOR Phase**: Add explicit counters to project-linking skill
- [ ] **REFACTOR Phase**: Re-test until passes without rationalizations
- [ ] **Final verification**: All tests pass in clean environment
- [ ] **Update skills**: Add Common Mistakes entries
- [ ] **Update descriptions**: Include project linking triggers
- [ ] **Cleanup**: Remove all test artifacts
- [ ] **Deploy**: Commit tested skills, push to remote

---

## Key Differences from Original Design

1. **✅ Isolated environments**: `/tmp/test-vault-$RANDOM/` instead of real vault
2. **✅ Portable**: No hardcoded system-specific paths
3. **✅ Safe**: Never touches real Obsidian vault
4. **✅ Reproducible**: Setup script creates identical environment each time
5. **✅ Clean**: Cleanup script removes all test artifacts
6. **✅ Configurable**: Uses `Primary vault: ${TEST_VAULT}` override in test context

**This is the correct way to test documentation changes safely.**
