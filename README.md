# DDD Plugin for Claude Code

A Domain Driven Design plugin that guides users through Strategic DDD concepts using Event Storming methodology.

## Features

- **Strategic DDD Skill**: Auto-activates during domain discussions to provide guidance on Bounded Contexts, Context Mapping, Ubiquitous Language, and Subdomains
- **Domain Exploration Command**: `/ddd:explore` - Guided Event Storming session for new features
- **Domain Modeler Agent**: Autonomous agent that creates domain documentation
- **Feature Development Integration**: Injects DDD considerations when starting feature work

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
