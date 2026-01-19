# Context Mapping Patterns

Detailed patterns for managing relationships between bounded contexts.

## Relationship Types

### Partnership

Two contexts with mutual dependency where teams coordinate development.

**When to use**:
- Features span both contexts
- Both teams benefit from tight coordination
- Changes frequently affect both sides

**Implementation**:
- Joint planning sessions
- Shared integration tests
- Synchronized releases
- Common communication channels

**Notation**: `Context A <-> Context B` (bidirectional arrow)

**Example**:
```
Shipping <-> Inventory
- Shipping reserves inventory before dispatch
- Inventory notifies shipping of stock changes
- Teams sync weekly on integration points
```

**Risks**:
- Coordination overhead
- Coupled release schedules
- May evolve into customer-supplier

---

### Shared Kernel

A small, explicitly shared subset of the domain model.

**When to use**:
- Core concepts genuinely shared
- Both teams willing to coordinate changes
- Shared code is stable

**Implementation**:
- Shared library or module
- Joint ownership of shared code
- Changes require agreement from both teams
- Comprehensive shared test suite

**Notation**: `Context A <-[Shared Kernel]-> Context B`

**Example**:
```
Sales <-[Money, Currency]-> Accounting
- Money value object shared
- Currency enum shared
- Both teams approve changes to shared kernel
```

**Risks**:
- Kernel grows over time
- Coordination becomes burden
- Hidden coupling

**Best practices**:
- Keep kernel minimal
- Document boundaries clearly
- Review kernel contents quarterly

---

### Customer-Supplier

Upstream context (supplier) provides data/functionality to downstream context (customer).

**When to use**:
- Clear direction of dependency
- Downstream needs upstream data
- Upstream can accommodate reasonable requests

**Implementation**:
- Upstream publishes API/events
- Downstream adapts to upstream model
- Negotiated SLAs and contracts
- Downstream can request features

**Notation**: `Supplier -D-> Customer` (D for downstream)

**Example**:
```
Order Management -D-> Reporting
- Order Management publishes OrderPlaced, OrderShipped events
- Reporting consumes events for dashboards
- Reporting can request new event types
```

**Variations**:
- **Respectful supplier**: Accommodates customer needs
- **Dominant supplier**: Customer must adapt

---

### Conformist

Downstream context fully adopts upstream model without translation.

**When to use**:
- Upstream model is good enough
- Translation cost exceeds benefit
- Upstream is external or unchangeable
- Faster integration needed

**Implementation**:
- Direct use of upstream types/schemas
- No anticorruption layer
- Accept upstream's modeling choices

**Notation**: `Upstream -> Downstream (CF)` (CF for conformist)

**Example**:
```
External Payment API -> Billing (CF)
- Billing uses payment API types directly
- No translation layer
- Accept API's charge/refund model
```

**Risks**:
- Upstream changes break downstream
- Upstream model may not fit well
- Hard to change later

**When to avoid**:
- Upstream model is poor quality
- Core domain affected
- Multiple downstreams need different views

---

### Anticorruption Layer (ACL)

Translation layer that protects downstream from upstream model.

**When to use**:
- Upstream model differs significantly
- Protect core domain from external influence
- Integrating with legacy systems
- Multiple upstream sources with different models

**Implementation**:
- Adapter/translator service
- Maps upstream to downstream concepts
- Isolates upstream changes
- Can facade multiple upstreams

**Notation**: `Upstream -[ACL]-> Downstream`

**Example**:
```
Legacy CRM -[ACL]-> Customer Management
- ACL translates legacy Customer to modern CustomerProfile
- ACL handles legacy status codes → domain states
- Legacy changes don't ripple into core domain
```

**Components**:
```
┌─────────────────────────────────────────┐
│            Anticorruption Layer         │
├─────────────────────────────────────────┤
│  Facade      │  Adapter     │  Translator│
│  (Simplified │  (Interface  │  (Model    │
│   interface) │   adaptation)│   mapping) │
└─────────────────────────────────────────┘
```

**Best practices**:
- Keep ACL thin (translation only)
- Test ACL thoroughly
- Document mapping decisions
- Consider generating from schemas

---

### Open Host Service (OHS)

Published, well-documented API for integration.

**When to use**:
- Multiple consumers need access
- Stable integration point
- Public or partner API

**Implementation**:
- Versioned API
- Published documentation
- Backward compatibility commitments
- Standard protocols (REST, gRPC, GraphQL)

**Notation**: `Context -[OHS]-> (multiple consumers)`

**Example**:
```
Product Catalog -[OHS]->
  - E-commerce Site
  - Mobile App
  - Partner APIs
  - Reporting
```

**Best practices**:
- Version from day one
- Document breaking changes
- Provide SDKs/clients
- Monitor usage patterns

---

### Published Language (PL)

Shared, documented data exchange format.

**When to use**:
- Need standard data format
- Multiple producers/consumers
- Industry standards exist

**Implementation**:
- JSON Schema, Protocol Buffers, Avro
- Shared schema registry
- Versioned schemas
- Validation at boundaries

**Notation**: `Context A -[PL: Format]-> Context B`

**Example**:
```
Order Service -[PL: OrderEvent.avro]-> Event Bus -[PL]-> Analytics
- OrderEvent schema in Avro
- Schema registry for evolution
- Both contexts validate against schema
```

**Common formats**:
- JSON Schema for REST APIs
- Protocol Buffers for gRPC
- Avro for event streaming
- XML Schema for enterprise integration

---

### Separate Ways

Contexts with no integration - duplicate rather than integrate.

**When to use**:
- Integration cost exceeds benefit
- Contexts truly independent
- Simple features not worth coordinating

**Implementation**:
- Accept duplication
- No shared code or data
- Independent evolution

**Notation**: `Context A || Context B` (parallel lines)

**Example**:
```
Marketing Site || Internal Admin
- Both need user authentication
- Each implements independently
- Different security requirements anyway
```

**When to avoid**:
- Core business logic duplicated
- Data consistency required
- Future integration likely

## Context Map Diagram

Create visual context maps showing relationships:

```
┌─────────────────┐         ┌─────────────────┐
│                 │   OHS   │                 │
│  Product        ├────────►│  E-commerce     │
│  Catalog        │         │  Storefront     │
│                 │         │                 │
└────────┬────────┘         └────────┬────────┘
         │                           │
         │ Customer-Supplier         │ ACL
         │                           │
         ▼                           ▼
┌─────────────────┐         ┌─────────────────┐
│                 │         │                 │
│  Inventory      │◄───────►│  Order          │
│  Management     │Partnership Management    │
│                 │         │                 │
└─────────────────┘         └────────┬────────┘
                                     │
                                     │ PL: OrderEvent
                                     ▼
                            ┌─────────────────┐
                            │                 │
                            │  Analytics      │
                            │                 │
                            └─────────────────┘
```

## Choosing Relationships

### Decision Flow

```
Is integration needed?
├─ No → Separate Ways
└─ Yes → Is upstream model acceptable?
         ├─ Yes → Conformist
         └─ No → Need protection?
                  ├─ Yes → ACL
                  └─ No → Can we influence upstream?
                           ├─ Yes → Customer-Supplier
                           └─ No → Conformist or ACL
```

### Factors to Consider

| Factor | Favors | Avoids |
|--------|--------|--------|
| Model quality | Conformist | ACL needed |
| Rate of change | ACL | Conformist |
| Team relationship | Partnership | Separate Ways |
| Shared ownership | Shared Kernel | Customer-Supplier |
| Multiple consumers | OHS + PL | Point-to-point |

## Evolution Patterns

Relationships evolve over time:

1. **Conformist → ACL**: As upstream model diverges from needs
2. **Partnership → Customer-Supplier**: As power dynamics clarify
3. **Shared Kernel → Separate**: As kernel becomes burden
4. **ACL → OHS**: As upstream improves their API
5. **Separate → Integrated**: As business needs align

## Documentation Template

```markdown
## Context Relationship: [Upstream] → [Downstream]

**Type**: [Relationship type]

**Direction**: [Upstream] supplies [Downstream]

**Integration Mechanism**:
- Protocol: REST/gRPC/Events
- Format: JSON/Protobuf/Avro
- Frequency: Real-time/Batch/On-demand

**Data Exchanged**:
- [Entity/Event 1]: [Description]
- [Entity/Event 2]: [Description]

**Translation** (if ACL):
- Upstream.X → Downstream.Y
- Upstream.Status → Downstream.State

**SLA/Contract**:
- Availability: [Target]
- Latency: [Target]
- Breaking change policy: [Policy]

**Owner**: [Team responsible for integration]

**Risks/Notes**:
- [Any concerns or considerations]
```
