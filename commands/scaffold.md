---
name: scaffold
description: Generate tactical DDD code scaffolding from domain documentation
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - TodoWrite
argument-hint: "[bounded context name] [language: typescript|python|java|go]"
---

# Tactical DDD Code Scaffolding

Generate code scaffolding for a bounded context based on the domain documentation in `docs/domain/`.

## Prerequisites

Before scaffolding, verify that domain documentation exists:

1. **Check for `docs/domain/bounded-contexts.md`** — required
2. **Check for `docs/domain/events.md`** — required
3. **Check for `docs/domain/glossary.md`** — recommended

If documentation is missing, suggest running `/ddd:explore` first.

## Session Setup

1. **Read domain documentation**
   - Parse `docs/domain/bounded-contexts.md` for context definitions, key concepts, and relationships
   - Parse `docs/domain/events.md` for domain events, commands, and aggregates
   - Parse `docs/domain/glossary.md` for ubiquitous language terms

2. **Identify the target context**
   - If arguments specify a context name, use it
   - Otherwise, list available bounded contexts and ask which one to scaffold

3. **Detect language and framework**
   - If arguments specify a language, use it
   - Otherwise, scan the project for existing code to detect language:
     - `package.json` or `tsconfig.json` → TypeScript
     - `requirements.txt` or `pyproject.toml` → Python
     - `pom.xml` or `build.gradle` → Java
     - `go.mod` → Go
   - If no existing code, ask the user

4. **Detect existing project structure**
   - Scan for existing source directories (`src/`, `app/`, `lib/`, etc.)
   - Identify naming conventions (camelCase, snake_case, PascalCase)
   - Identify module/package structure patterns already in use

## Scaffolding Structure

Generate the following directory structure for the bounded context. Adapt naming conventions to match the detected language.

```
src/<context-name>/
├── domain/
│   ├── aggregates/        # Aggregate root classes
│   ├── entities/          # Entity classes
│   ├── value-objects/     # Value objects
│   ├── events/            # Domain event definitions
│   └── commands/          # Command definitions
├── application/
│   ├── command-handlers/  # Command handler implementations
│   └── event-handlers/    # Domain event handler stubs
├── infrastructure/
│   ├── repositories/      # Repository implementations (stubs)
│   └── acl/               # Anti-corruption layer (if context has ACL relationship)
└── README.md              # Context documentation
```

## Generation Rules

### Aggregates

For each aggregate identified in the bounded context:

- Create an aggregate root class with:
  - Properties derived from event data and glossary definitions
  - Command methods that validate invariants and emit domain events
  - A factory method or constructor that enforces creation rules
- Keep aggregates small — only include what must be consistent together

### Domain Events

For each event in `docs/domain/events.md` that belongs to this context:

- Create an event class/type with:
  - All fields from the documented event data schema
  - An `occurredAt` timestamp
  - The aggregate ID that produced it
- Events are immutable — no setters, no mutation methods

### Value Objects

For domain terms in the glossary that represent descriptive concepts (not entities):

- Create value objects with:
  - Equality by value (not reference)
  - Immutability
  - Self-validation in the constructor
- Common examples: Money, Address, Email, SKU, DateRange

### Commands

For each command/trigger documented in the events catalog:

- Create a command class/type with:
  - Required input data
  - The target aggregate identifier

### Command Handlers

For each command:

- Create a handler stub that:
  - Loads the aggregate from a repository
  - Calls the appropriate aggregate method
  - Persists changes
  - Has TODO comments for business logic

### Event Handlers

For each event that has documented consumers within this context:

- Create a handler stub with:
  - The event type it handles
  - TODO comments describing the expected reaction (from the policies table)

### Repositories

For each aggregate:

- Create a repository interface/protocol with:
  - `findById(id)` — load an aggregate
  - `save(aggregate)` — persist an aggregate
- Create a stub/in-memory implementation for development

### Anti-Corruption Layer

If the context has an ACL relationship documented in bounded-contexts.md:

- Create a translation layer with:
  - An interface defining what this context needs from the external context
  - A translator that maps external models to internal domain models
  - TODO comments noting what external API/model is being translated

## Language-Specific Conventions

### TypeScript

```
src/<context-name>/
├── domain/
│   ├── aggregates/Order.ts
│   ├── value-objects/Money.ts
│   ├── events/OrderCreated.ts
│   └── commands/CreateOrder.ts
├── application/
│   ├── command-handlers/CreateOrderHandler.ts
│   └── event-handlers/OnOrderCreated.ts
├── infrastructure/
│   └── repositories/OrderRepository.ts
└── index.ts
```

- Use classes for aggregates and entities
- Use readonly properties + branded types for value objects
- Use interfaces for repository contracts
- Export domain types from `index.ts`

### Python

```
src/<context_name>/
├── domain/
│   ├── aggregates/order.py
│   ├── value_objects/money.py
│   ├── events/order_created.py
│   └── commands/create_order.py
├── application/
│   ├── command_handlers/create_order_handler.py
│   └── event_handlers/on_order_created.py
├── infrastructure/
│   └── repositories/order_repository.py
└── __init__.py
```

- Use dataclasses or attrs for value objects and events
- Use ABC for repository interfaces
- Use snake_case for files and functions, PascalCase for classes

### Java

```
src/main/java/com/<org>/<context>/
├── domain/
│   ├── aggregates/Order.java
│   ├── valueobjects/Money.java
│   ├── events/OrderCreated.java
│   └── commands/CreateOrder.java
├── application/
│   ├── commandhandlers/CreateOrderHandler.java
│   └── eventhandlers/OnOrderCreated.java
├── infrastructure/
│   └── repositories/OrderRepository.java
└── package-info.java
```

- Use records for value objects and events (Java 16+)
- Use interfaces for repository contracts
- Follow standard Maven/Gradle layout

### Go

```
<context>/
├── domain/
│   ├── order.go          # Aggregate + methods
│   ├── money.go          # Value objects
│   ├── events.go         # All domain events
│   └── commands.go       # All commands
├── application/
│   ├── handlers.go       # Command + event handlers
│   └── service.go        # Application service
├── infrastructure/
│   └── repository.go     # Repository interface + implementation
└── doc.go
```

- Use structs for aggregates, value objects, events
- Use interfaces for repositories
- Group related types in single files

## Post-Scaffolding

After generating code:

1. **Summarize** what was created — list all files with a one-line description
2. **Highlight TODOs** — list the business logic that needs to be implemented
3. **Suggest next steps**:
   - Implement aggregate business rules from the documented invariants
   - Wire up infrastructure (database, message bus)
   - Write tests for aggregate behavior
4. **Warn about gaps** — if any documented concepts couldn't be scaffolded, explain why

## Important Guidelines

- **Never invent domain concepts** — only scaffold what's documented in `docs/domain/`
- **Use ubiquitous language** — class names, method names, and variable names must match the glossary
- **Don't over-engineer** — generate minimal, clean code. No frameworks, no DI containers, no ORMs in the domain layer
- **Respect existing code** — if the project already has code, match its style. Don't overwrite existing files without asking
- **Aggregate boundaries matter** — don't put entities from different aggregates in the same module
