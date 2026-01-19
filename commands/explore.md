---
name: explore
description: Start a guided domain exploration session using Event Storming methodology
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - AskUserQuestion
  - TodoWrite
argument-hint: "[feature or domain area to explore]"
---

# Domain Exploration Session

Guide the user through a structured Event Storming session to discover and document their domain model.

## Session Setup

Before starting exploration:

1. **Check for existing domain documentation**
   - Look for `docs/domain/` directory
   - Read existing `bounded-contexts.md`, `glossary.md`, `events.md` if present
   - Note what's already documented to avoid repetition

2. **Identify the scope**
   - If arguments provided, focus on that specific area
   - If no arguments, ask user what domain area or feature to explore
   - Clarify whether this is greenfield exploration or extending existing model

3. **Create documentation structure if needed**
   ```
   docs/domain/
   ├── bounded-contexts.md
   ├── glossary.md
   └── events.md
   ```

## Event Storming Process

Guide through these phases conversationally:

### Phase 1: Domain Event Discovery

Ask the user to identify significant things that happen in their domain:

- "What are the key business events in [area]?"
- "What state changes are important to track?"
- "What would appear in an audit log?"

Capture events in past tense: "Order Placed", "Payment Received", "User Registered"

**Prompt suggestions:**
- Start with the happy path
- Think about what the business cares about
- Consider what triggers notifications

### Phase 2: Commands and Triggers

For each event discovered:

- "What action causes [Event] to happen?"
- "Who or what initiates this?"

Commands are imperative: "Place Order", "Process Payment", "Register User"

### Phase 3: Aggregate Identification

Group related events and commands:

- "Which events must be consistent with each other?"
- "What data changes together?"

Name aggregates as nouns: "Order", "Customer", "Payment"

### Phase 4: Bounded Context Discovery

Look for linguistic and organizational boundaries:

- "Does [term] mean the same thing everywhere?"
- "Who owns this process?"
- "Could this change independently from [other area]?"

### Phase 5: Context Relationships

For each context boundary identified:

- "How does [Context A] communicate with [Context B]?"
- "Who depends on whom?"
- "Is there shared data or events?"

## Documentation Output

After each major discovery, update the domain documentation:

### Update `docs/domain/events.md`

Add discovered events with:
- Event name
- Trigger (command or policy)
- Key data carried
- Consumers

### Update `docs/domain/glossary.md`

Add new terms with:
- Precise definition in this context
- Examples
- What it's NOT (disambiguation)

### Update `docs/domain/bounded-contexts.md`

Add or update:
- Context purpose and scope
- Key aggregates
- Relationships to other contexts

## Session Flow

1. **Opening**: Summarize scope, check existing docs
2. **Discovery**: Iterative questioning through phases
3. **Documentation**: Write findings to `docs/domain/`
4. **Summary**: Recap what was discovered, suggest next steps

## Facilitation Tips

- Ask one question at a time
- Confirm understanding before moving on
- It's okay to revisit earlier phases
- Capture uncertainties as "hotspots" to investigate later
- Don't try to solve everything in one session

## Completion

End the session by:

1. Summarizing key discoveries
2. Listing any hotspots or open questions
3. Suggesting follow-up exploration areas
4. Confirming documentation was saved

If the user wants to continue with implementation, suggest using the domain-modeler agent for deeper analysis or proceeding with feature development using the documented domain model.
