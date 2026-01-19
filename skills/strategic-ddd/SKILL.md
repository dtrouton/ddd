---
name: Strategic DDD
description: This skill should be used when the user asks to "model the domain", "identify bounded contexts", "create a context map", "define ubiquitous language", "run event storming", "explore the domain", "design domain boundaries", "what are bounded contexts", "help with strategic DDD", "explain DDD concepts", or when starting feature development that requires understanding domain concepts, aggregates, or system integration points.
version: 0.1.0
---

# Strategic Domain Driven Design

Apply Strategic DDD principles to understand and model complex business domains before writing code. Strategic DDD focuses on the big picture: identifying bounded contexts, establishing ubiquitous language, and mapping relationships between different parts of the system.

## Core Concepts

### Bounded Contexts

A Bounded Context is a semantic boundary where a particular domain model applies. Within a bounded context:
- Terms have precise, unambiguous meanings
- The model is internally consistent
- Different contexts may use the same term differently (e.g., "Customer" in Sales vs Support)

Identify bounded contexts by looking for:
- Distinct business capabilities or departments
- Different meanings for the same terms
- Natural team boundaries
- Independent deployment needs

### Ubiquitous Language

Establish a shared vocabulary between developers and domain experts:
- Define terms precisely within each bounded context
- Use domain language in code (class names, method names, variables)
- Avoid technical jargon when naming domain concepts
- Document definitions in a glossary

### Context Mapping

Map relationships between bounded contexts:

| Relationship | Description |
|--------------|-------------|
| **Partnership** | Contexts cooperate, coordinated development |
| **Shared Kernel** | Shared subset of domain model |
| **Customer-Supplier** | Upstream provides, downstream consumes |
| **Conformist** | Downstream conforms to upstream model |
| **Anticorruption Layer** | Translation layer protects downstream |
| **Open Host Service** | Published API for integration |
| **Published Language** | Shared exchange format (JSON schema, etc.) |

### Subdomains

Classify subdomains to prioritize effort:
- **Core Domain**: Primary competitive advantage, invest heavily
- **Supporting Subdomain**: Necessary but not differentiating
- **Generic Subdomain**: Common problems, consider off-the-shelf solutions

## Event Storming Methodology

Use Event Storming to discover domain concepts collaboratively. This is the primary technique for domain exploration.

### Process Overview

1. **Discover Domain Events** - Orange sticky notes
   - Past tense verbs: "Order Placed", "Payment Received", "Shipment Dispatched"
   - Focus on business-significant state changes

2. **Identify Commands** - Blue sticky notes
   - Actions that trigger events: "Place Order", "Process Payment"
   - Connect commands to the events they produce

3. **Find Aggregates** - Yellow sticky notes
   - Clusters of entities that change together
   - Each aggregate enforces consistency boundaries

4. **Map Bounded Contexts** - Draw boundaries around related concepts
   - Look for linguistic boundaries
   - Identify where models diverge

5. **Identify External Systems** - Pink sticky notes
   - Payment gateways, shipping APIs, legacy systems
   - Note integration points and dependencies

### Facilitation Guidelines

- Start with the happy path, add edge cases later
- Encourage questions: "What happens when...?"
- Look for hotspots (areas of confusion or debate)
- Time-box sessions (2-3 hours max)

## Artifact Creation

Create domain documentation in `docs/domain/` with three key files:

| File | Purpose | Template |
|------|---------|----------|
| `bounded-contexts.md` | Context map showing boundaries and relationships | See `examples/bounded-contexts-example.md` |
| `glossary.md` | Ubiquitous language definitions by context | See `examples/glossary-example.md` |
| `events.md` | Domain event catalog with triggers and consumers | See `examples/events-example.md` |

Each file follows a consistent structure. Copy and adapt the examples for the specific domain.

## Workflow Integration

When starting feature development:

1. **Identify the domain area** - Which bounded context does this feature belong to?
2. **Review existing model** - Check `docs/domain/` for current understanding
3. **Validate language** - Ensure feature uses ubiquitous language correctly
4. **Consider boundaries** - Does this feature cross context boundaries?
5. **Update artifacts** - Add new concepts discovered during development

### Questions to Ask

Before implementing a feature:
- What domain events does this feature produce or consume?
- Which aggregate(s) are affected?
- Are we introducing new domain concepts? If so, define them.
- Does this cross bounded context boundaries? If so, how do we integrate?
- Is the feature name using ubiquitous language?

## Common Patterns

### Identifying Bounded Contexts

Signs a bounded context should be split:
- Team conflicts over model changes
- Same entity has different behaviors in different areas
- Frequent misunderstandings about term meanings
- Deployment coupling causing friction

Signs contexts should merge:
- Excessive translation between contexts
- Artificial boundaries causing overhead
- Same team owns both contexts

### Naming Conventions

Align code with ubiquitous language:

```
# Domain term → Code
Order → Order (class)
place an order → placeOrder() (method)
order was placed → OrderPlaced (event)
order placement → OrderPlacement (service)
```

## Additional Resources

### Reference Files

For detailed patterns and techniques:
- **`references/event-storming-guide.md`** - Comprehensive Event Storming facilitation guide
- **`references/context-mapping-patterns.md`** - Detailed context relationship patterns
- **`references/modeling-techniques.md`** - Advanced modeling approaches

### Example Files

Working templates in `examples/`:
- **`bounded-contexts-example.md`** - Sample bounded context map
- **`glossary-example.md`** - Sample domain glossary
- **`events-example.md`** - Sample event catalog

## Anti-Patterns to Avoid

- **Big Ball of Mud**: No clear boundaries, everything depends on everything
- **Anemic Domain Model**: Domain objects with no behavior, all logic in services
- **Leaky Abstractions**: Internal model details exposed across boundaries
- **Premature Decomposition**: Splitting contexts before understanding the domain
- **Ignoring Linguistic Boundaries**: Using same term for different concepts

## Getting Started

To begin domain exploration:

1. Schedule an Event Storming session (or work through it conversationally)
2. Identify the key domain events in the system
3. Group related events to find bounded contexts
4. Define the ubiquitous language for each context
5. Create initial documentation in `docs/domain/`
6. Iterate as understanding deepens

Use `/ddd:explore` to start a guided domain exploration session.
