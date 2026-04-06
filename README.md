# DDD Plugin for Claude Code

A Domain Driven Design plugin that guides users through Strategic DDD concepts using Event Storming methodology.

## Features

- **Strategic DDD Skill**: Auto-activates during domain discussions to provide guidance on Bounded Contexts, Context Mapping, Ubiquitous Language, and Subdomains
- **Domain Exploration Command**: `/ddd:explore` - Guided Event Storming session for new features
- **Code Scaffolding Command**: `/ddd:scaffold` - Generate tactical DDD code (aggregates, events, value objects, repositories) from domain documentation
- **Drift Detection Command**: `/ddd:drift` - Detect where code has diverged from the documented domain model
- **Domain Modeler Agent**: Autonomous agent that creates domain documentation
- **Feature Development Integration**: Injects DDD considerations when starting feature work
- **Drift Detection Hook**: Lightweight check on session start that flags mismatches between code and domain docs

## Artifacts

The plugin creates documentation in `docs/domain/`:
- `bounded-contexts.md` - Context map and boundaries
- `glossary.md` - Ubiquitous language definitions
- `events.md` - Domain event catalog

## Usage

### Start Domain Exploration
```
/ddd:explore
```

### Scaffold Code from Domain Docs
```
/ddd:scaffold [context-name] [language]
```
Generates tactical DDD code structure — aggregates, domain events, value objects, commands, handlers, and repository interfaces — directly from your domain documentation. Supports TypeScript, Python, Java, and Go.

### Check for Domain Drift
```
/ddd:drift [context-name or 'all']
```
Compares the codebase against `docs/domain/` and reports: undocumented contexts, missing implementations, glossary violations, boundary violations, undocumented events, and stale documentation.

### Auto-Activation
The DDD skill automatically activates when discussing:
- New features requiring domain modeling
- Bounded context design
- Domain events and aggregates
- System integration boundaries

## Installation

Add to your Claude Code plugins or use locally with:
```bash
claude --plugin-dir /path/to/ddd
```
