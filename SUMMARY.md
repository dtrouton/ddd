# DDD Plugin for Claude Code — Summary

## What It Is

A Claude Code plugin (v0.1.0) that integrates **Domain Driven Design** principles into the development workflow using **Event Storming** methodology. It helps teams discover, model, and document their business domains before writing code.

## Core Components

| Component | Location | Purpose |
|---|---|---|
| **Strategic DDD Skill** | `skills/strategic-ddd/SKILL.md` | Auto-activates during domain discussions; covers Bounded Contexts, Ubiquitous Language, Context Mapping, and Subdomains |
| **Domain Exploration Command** | `commands/explore.md` | `/ddd:explore` — a guided, 5-phase Event Storming session |
| **Domain Modeler Agent** | `agents/domain-modeler.md` | Autonomous agent that analyzes codebases and generates domain documentation |
| **Integration Hooks** | `hooks/hooks.json` | Automatically injects DDD reminders into feature development prompts and checks for existing domain docs on session start |

## Event Storming Phases

The `/ddd:explore` command walks users through:

1. **Domain Event Discovery** — capture business events in past tense (e.g., "Order Placed")
2. **Command & Trigger Identification** — identify what causes events (e.g., "Place Order")
3. **Aggregate Identification** — cluster related events and commands
4. **Bounded Context Discovery** — find linguistic and organizational boundaries
5. **Context Relationship Mapping** — define how contexts communicate

## Generated Artifacts

The plugin creates and maintains three files in `docs/domain/`:

- **`bounded-contexts.md`** — context map showing boundaries and relationships
- **`glossary.md`** — ubiquitous language definitions organized by context
- **`events.md`** — domain event catalog with triggers and consumers

## Reference Materials

The plugin includes extensive reference documentation:

- **Event Storming Guide** — facilitation techniques, remote session tips, and session phases
- **Context Mapping Patterns** — Partnership, Shared Kernel, Customer-Supplier, Conformist, Anti-Corruption Layer, Open Host Service, Published Language, Separate Ways
- **Modeling Techniques** — Domain Storytelling, Aggregate Design Canvas, Wardley Mapping, context discovery heuristics

## Examples

Includes a complete e-commerce domain example with six bounded contexts: Product Catalog, Order Management, Inventory, Customer Management, Payment Processing, and Shipping.

## Installation

```bash
claude --plugin-dir /path/to/ddd
```

Or add to your Claude Code plugins configuration.
