---
name: drift
description: Detect drift between domain documentation and the actual codebase
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - TodoWrite
argument-hint: "[bounded context name or 'all']"
---

# Domain Drift Detection

Analyze the codebase and compare it against the domain documentation in `docs/domain/` to detect drift — places where code has diverged from the documented domain model.

## Prerequisites

1. **Check for domain documentation** in `docs/domain/`
   - `bounded-contexts.md` — required
   - `glossary.md` — required
   - `events.md` — recommended
2. **Check for source code** — at least one source directory must exist
3. If either is missing, report what's missing and suggest next steps

## Detection Process

### Step 1: Parse Domain Documentation

Read and extract structured data from the domain docs:

**From `bounded-contexts.md`:**
- Context names and their key concepts (aggregates, entities, value objects)
- Context relationships (who talks to whom, and how)
- Team assignments

**From `glossary.md`:**
- All defined terms and their definitions
- Which context each term belongs to
- Disambiguation notes

**From `events.md`:**
- Event names and their data schemas
- Commands/triggers
- Consumers and policies
- Business rules and invariants

### Step 2: Scan the Codebase

Use Glob and Grep to build a picture of the actual code:

**Structure scan:**
- Find all source directories, modules, and packages
- Identify what looks like bounded contexts in the code structure
- Map directories to potential context names

**Domain concept scan:**
- Search for class/struct/type definitions that match documented aggregate names
- Search for event class names matching documented events
- Search for terms from the glossary in class names, function names, and variable names

**Relationship scan:**
- Find imports/dependencies between modules that correspond to context boundaries
- Identify where one context's code directly references another context's internals

### Step 3: Compare and Report

Run these drift checks:

#### 3a. Undocumented Contexts

Look for code modules or packages that don't map to any documented bounded context.

**How to detect:**
- Find top-level source directories/modules
- Compare against context names in `bounded-contexts.md`
- Flag any code module that has no corresponding documented context

**Report as:** `UNDOCUMENTED_CONTEXT` — "Module `src/notifications/` exists in code but is not documented as a bounded context"

#### 3b. Missing Implementations

Look for documented concepts that have no corresponding code.

**How to detect:**
- For each documented aggregate, search for a matching class/type definition
- For each documented event, search for a matching event class
- For each documented context, check if a corresponding code module exists

**Report as:** `MISSING_IMPLEMENTATION` — "Aggregate `Reservation` is documented in Inventory context but no corresponding code was found"

#### 3c. Glossary Violations

Look for terminology misuse — code using terms inconsistently with the glossary.

**How to detect:**
- For terms with disambiguation notes (e.g., "Customer in Sales means X, not Y"), search for usage in the wrong context
- Look for synonyms or alternative names that should use the canonical glossary term
- Check class names and method names against ubiquitous language

**Report as:** `GLOSSARY_VIOLATION` — "Code uses `Client` in `src/orders/` but the glossary defines this concept as `Customer` in the Order Management context"

#### 3d. Boundary Violations

Look for code that reaches across context boundaries without proper integration patterns.

**How to detect:**
- Find imports where one context's code imports directly from another context's domain layer
- Check if documented ACL relationships have actual translation layers in code
- Look for shared database tables or models used by multiple contexts

**Report as:** `BOUNDARY_VIOLATION` — "`src/orders/service.ts` directly imports `src/inventory/domain/StockItem` — these are separate bounded contexts that should communicate via events or an ACL"

#### 3e. Undocumented Events

Look for event classes in code that aren't in the events catalog.

**How to detect:**
- Search for classes/types with names ending in `Event`, `Created`, `Updated`, `Deleted`, or matching common event naming patterns
- Compare against events documented in `events.md`

**Report as:** `UNDOCUMENTED_EVENT` — "Event `OrderRefunded` exists in code but is not documented in the events catalog"

#### 3f. Stale Documentation

Look for documented concepts that appear to have been removed or significantly changed in code.

**How to detect:**
- Check if documented aggregate properties still exist in code
- Check if documented event schemas match actual event class fields
- Look for commented-out or deprecated code matching documented concepts

**Report as:** `STALE_DOCUMENTATION` — "Event `OrderShipped` is documented with field `carrier` but the code uses `shippingProvider`"

## Output Format

Present findings as a drift report:

```
# Domain Drift Report

Generated: [date]
Scope: [all contexts | specific context]

## Summary

| Category              | Issues Found |
|-----------------------|-------------|
| Undocumented Contexts | X           |
| Missing Implementations| X          |
| Glossary Violations   | X           |
| Boundary Violations   | X           |
| Undocumented Events   | X           |
| Stale Documentation   | X           |
| **Total**             | **X**       |

## Critical Issues

[Boundary violations and glossary violations — these indicate active divergence]

### BOUNDARY_VIOLATION: [description]
- **File**: `path/to/file.ts:42`
- **Expected**: [what the documentation says]
- **Actual**: [what the code does]
- **Suggested fix**: [how to resolve]

## Warnings

[Missing implementations and undocumented contexts — these indicate gaps]

## Info

[Stale documentation and undocumented events — these need review]
```

## Severity Levels

Categorize each finding:

| Severity | Types | Meaning |
|----------|-------|---------|
| **Critical** | Boundary violations, Glossary violations | Active divergence — code contradicts the domain model |
| **Warning** | Missing implementations, Undocumented contexts | Gaps — code or docs are incomplete |
| **Info** | Undocumented events, Stale documentation | Review needed — may be intentional |

## Post-Report Actions

After presenting the report:

1. **Ask what to address** — let the user prioritize which issues to fix
2. **Offer to update docs** — for undocumented events/contexts, offer to add them to domain docs
3. **Offer to fix code** — for glossary violations or boundary violations, suggest concrete code changes
4. **Suggest re-running** — after fixes, suggest running `/ddd:drift` again to verify

## Important Guidelines

- **Don't be overly strict** — some drift is normal during active development. Focus on meaningful divergence, not pedantic naming matches
- **Context matters** — a test file importing across boundaries is not a boundary violation
- **Confidence levels** — if you're unsure whether something is a real issue, say so. Mark low-confidence findings as "Possible" rather than definitive
- **No false precision** — if the codebase has no clear module structure, say that rather than guessing at boundaries
- **Respect the team** — drift detection is a tool for awareness, not blame. Frame findings as opportunities to align, not failures
