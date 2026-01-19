# Event Storming Facilitation Guide

A comprehensive guide to running Event Storming sessions for domain discovery.

## Session Types

### Big Picture Event Storming

Use for initial domain exploration across an entire system or organization.

**Duration**: 4-8 hours (can be split across days)
**Participants**: 10-30 people from various domains
**Output**: High-level bounded context map, key events, hotspots

### Process Modeling Event Storming

Use for detailed exploration of a specific business process.

**Duration**: 2-4 hours
**Participants**: 5-10 domain experts and developers
**Output**: Detailed event flow, commands, aggregates, policies

### Design Level Event Storming

Use for designing implementation details of a bounded context.

**Duration**: 1-2 hours
**Participants**: 3-5 developers working on the context
**Output**: Aggregate design, command handlers, event structure

## Sticky Note Legend

| Color | Concept | Example |
|-------|---------|---------|
| Orange | Domain Event | "Order Placed" |
| Blue | Command | "Place Order" |
| Yellow | Aggregate | "Order" |
| Purple | Policy/Process | "When order placed, notify warehouse" |
| Pink | External System | "Payment Gateway" |
| Red | Hotspot/Question | "What happens if payment fails?" |
| Green | Read Model/View | "Order History" |
| Small Yellow | Actor | "Customer", "Admin" |

## Phase-by-Phase Guide

### Phase 1: Chaotic Exploration (30-60 minutes)

**Goal**: Get all domain events on the board without structure.

**Facilitation**:
- Ask: "What are the significant things that happen in this domain?"
- Encourage parallel writing - everyone writes events simultaneously
- No discussion yet, just capture
- Accept duplicates (they reveal importance)
- Use past tense: "Something Happened"

**Tips**:
- Start with "happy path" events
- Don't worry about order
- Capture events at business level, not technical

### Phase 2: Timeline Ordering (20-40 minutes)

**Goal**: Arrange events in temporal sequence.

**Facilitation**:
- Move events left to right chronologically
- Identify parallel flows (stack vertically)
- Look for swim lanes (different actors/contexts)
- Merge duplicates, clarify differences

**Questions to ask**:
- "What happens before this?"
- "What happens after this?"
- "Can these happen in parallel?"

### Phase 3: Reverse Narrative (15-30 minutes)

**Goal**: Validate the flow by walking backwards.

**Facilitation**:
- Start from the end of a process
- Ask: "What had to happen for this event to occur?"
- Fill gaps discovered during walkback
- Challenge assumptions

### Phase 4: Add Commands and Actors (30-45 minutes)

**Goal**: Identify what triggers events and who triggers them.

**Facilitation**:
- For each event, ask: "What command causes this?"
- Identify the actor: "Who issues this command?"
- Some events triggered by other events (policies)
- Some events from external systems

**Command naming**:
- Imperative form: "Place Order", "Ship Package"
- Active voice: Actor + Action

### Phase 5: Identify Aggregates (30-45 minutes)

**Goal**: Group commands and events around consistency boundaries.

**Facilitation**:
- Look for clusters of related commands/events
- Ask: "What data must be consistent when this command executes?"
- Name the aggregate (noun): "Order", "Customer", "Shipment"

**Aggregate rules**:
- Receives commands
- Produces events
- Enforces invariants
- Consistency boundary for transactions

### Phase 6: Identify Bounded Contexts (20-30 minutes)

**Goal**: Draw boundaries around coherent models.

**Facilitation**:
- Look for linguistic boundaries (same word, different meaning)
- Look for team boundaries
- Look for deployment boundaries
- Draw lines around related aggregates

**Signs of a boundary**:
- Vocabulary shifts
- Different stakeholders
- Different change cadence
- Natural team ownership

### Phase 7: Mark Hotspots and Questions (ongoing)

**Goal**: Capture areas of confusion or debate.

**Facilitation**:
- Red stickies for unresolved questions
- Pink stickies for external dependencies
- Don't try to resolve everything immediately
- Hotspots indicate areas needing more exploration

## Common Challenges

### "We don't know the domain well enough"

That's exactly why you're doing Event Storming. Start with what you know. Gaps reveal where to investigate.

### "Events are too technical"

Redirect: "Imagine explaining this to the CEO. What business thing happened?" Focus on business significance, not implementation.

### "Too many events, board is chaos"

Normal in Phase 1. Structure emerges in Phase 2. Trust the process.

### "Disagreement about terminology"

Perfect! You've found a potential bounded context boundary. Document both interpretations.

### "People aren't participating"

Try:
- Ask quiet people directly (gently)
- Break into smaller groups
- Give everyone stickies and markers
- Make it safe to be wrong

## Remote Event Storming

### Tools

- Miro, Mural, FigJam for virtual boards
- Video conferencing with breakout rooms
- Pre-created sticky note templates

### Adaptations

- Shorter sessions (90 minutes max)
- More structured facilitation
- Pre-work: Have participants think about events beforehand
- Clear turn-taking for discussions
- Use voting/reactions for agreement

## After the Session

### Immediate (Same Day)

1. Photograph the board (multiple angles)
2. Capture key insights while fresh
3. Note unresolved hotspots

### Short Term (Within a Week)

1. Digitize into documentation
2. Create bounded context map
3. Draft glossary of key terms
4. Schedule follow-up sessions for hotspots

### Ongoing

1. Update as understanding evolves
2. Reference in feature development
3. Onboard new team members with the artifacts
4. Run focused sessions when entering new areas

## Event Storming Notation for Documentation

When converting to markdown, use this format:

```
## Process: [Name]

### Events (chronological)

1. **CustomerRegistered**
   - Trigger: RegisterCustomer command
   - Actor: Visitor
   - Data: email, name, preferences

2. **EmailVerificationSent**
   - Trigger: Policy (after CustomerRegistered)
   - Data: verificationToken, email

3. **EmailVerified**
   - Trigger: VerifyEmail command
   - Actor: Customer (via email link)
   - Data: customerId

### Aggregates

- **Customer**: Handles registration, verification, profile updates
- **Subscription**: Handles plan selection, billing

### Policies

- "When CustomerRegistered, send verification email"
- "When EmailVerified after 7 days of registration, send welcome discount"

### External Systems

- Email Service (SendGrid)
- Payment Processor (Stripe)

### Hotspots

- [ ] What happens if verification expires?
- [ ] How do we handle email bounces?
```

## Questions Cheat Sheet

### Discovery Questions
- "What significant things happen in this area of the business?"
- "What does the business care about tracking?"
- "What would appear in an audit log?"

### Trigger Questions
- "What causes this to happen?"
- "Who or what initiates this?"
- "Under what conditions does this occur?"

### Consequence Questions
- "What happens as a result of this?"
- "Who needs to know about this?"
- "What decisions depend on this?"

### Boundary Questions
- "Does this word mean the same thing over there?"
- "Who owns this process?"
- "Could this change independently?"

### Challenge Questions
- "What if this fails?"
- "What if this happens out of order?"
- "What if this never happens?"
