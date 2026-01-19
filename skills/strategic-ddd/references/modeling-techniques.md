# Advanced Modeling Techniques

Additional techniques for domain modeling beyond Event Storming basics.

## Domain Storytelling

Narrative-based domain exploration using pictographic language.

### When to Use

- Stakeholders uncomfortable with abstract modeling
- Need to capture specific scenarios in detail
- Want to validate understanding with domain experts
- Documenting as-is processes before designing to-be

### Process

1. **Identify a scenario** - Specific business activity to explore
2. **Identify actors** - Who participates in this scenario
3. **Tell the story** - Walk through step by step
4. **Draw as you go** - Create visual narrative
5. **Number the steps** - Show sequence clearly

### Notation

```
[Actor] → (action) → [Work Object] → (action) → [Actor]

Example:
[Customer] → orders → [Product] → from → [E-commerce Site]
    ↓
[E-commerce Site] → creates → [Order]
    ↓
[Warehouse] → receives → [Order] → and ships → [Package]
    ↓
[Customer] → receives → [Package]
```

### Benefits

- Very accessible to non-technical stakeholders
- Captures happy path and variations
- Reveals handoffs and pain points
- Natural basis for bounded context discovery

---

## Aggregate Design Canvas

Structured approach to designing aggregates after Event Storming.

### Canvas Sections

```
┌─────────────────────────────────────────────────────────────┐
│ AGGREGATE: [Name]                                           │
├─────────────────┬───────────────────────────────────────────┤
│ PURPOSE         │ Why does this aggregate exist?            │
│                 │ What invariants does it protect?          │
├─────────────────┼───────────────────────────────────────────┤
│ COMMANDS        │ What operations can be performed?         │
│                 │ - CreateOrder                             │
│                 │ - AddLineItem                             │
│                 │ - SubmitOrder                             │
├─────────────────┼───────────────────────────────────────────┤
│ EVENTS          │ What events does it emit?                 │
│                 │ - OrderCreated                            │
│                 │ - LineItemAdded                           │
│                 │ - OrderSubmitted                          │
├─────────────────┼───────────────────────────────────────────┤
│ INVARIANTS      │ What rules must always be true?           │
│                 │ - Order total must be positive            │
│                 │ - Submitted orders cannot be modified     │
│                 │ - Must have at least one line item        │
├─────────────────┼───────────────────────────────────────────┤
│ CORRECTIVE      │ What if invariants are violated?          │
│ POLICIES        │ - Reject command                          │
│                 │ - Compensating action                     │
├─────────────────┼───────────────────────────────────────────┤
│ STATE           │ Key data this aggregate maintains         │
│                 │ - status, lineItems[], total, customerId  │
└─────────────────┴───────────────────────────────────────────┘
```

### Design Principles

**Small aggregates**: Prefer many small aggregates over few large ones
**Consistency boundary**: Only include what must be immediately consistent
**Reference by ID**: Link to other aggregates by identifier, not object
**Design for concurrency**: Smaller aggregates = fewer conflicts

---

## Wardley Mapping for Subdomains

Use Wardley Maps to classify and prioritize subdomains.

### The Value Chain

```
           Visible to User
                  ↑
    ┌─────────────────────────────┐
    │      User Interface         │  ← Customer-facing
    ├─────────────────────────────┤
    │     Business Logic          │  ← Core Domain
    ├─────────────────────────────┤
    │      Data Services          │  ← Supporting
    ├─────────────────────────────┤
    │     Infrastructure          │  ← Generic
    └─────────────────────────────┘
                  ↓
           Invisible to User
```

### Evolution Axis

```
Genesis → Custom Built → Product → Commodity
   │           │            │          │
   └───────────┴────────────┴──────────┘

Genesis: Novel, uncertain, experiment
Custom: Understood, tailored solution
Product: Available solutions, build vs buy
Commodity: Utility, outsource/buy
```

### Subdomain Classification Matrix

| Subdomain | Evolution Stage | Strategy |
|-----------|----------------|----------|
| Core | Genesis/Custom | Build, invest heavily |
| Supporting | Custom/Product | Build simple, consider buying |
| Generic | Product/Commodity | Buy, outsource |

---

## Context Discovery Heuristics

### Linguistic Boundaries

**Same word, different meaning** = Different contexts

Examples:
- "Account" in Banking vs Marketing
- "Order" in Sales vs Fulfillment
- "Product" in Catalog vs Inventory

**Questions to reveal**:
- "When you say X, what exactly do you mean?"
- "Is that the same X as in [other area]?"
- "What attributes does X have here?"

### Organizational Boundaries

**Different teams** often indicate different contexts

But verify:
- Do they use different models?
- Would they benefit from independence?
- Are they coupled by necessity or accident?

### Process Boundaries

**Different lifecycle stages** often indicate different contexts

Example lifecycle:
```
Lead → Prospect → Customer → Former Customer
 │         │          │            │
 └─────────┴──────────┴────────────┘
 Marketing   Sales    Support    Retention
 Context    Context   Context    Context
```

### Data Boundaries

**Different data views** of same concept = Different contexts

Example: "Customer"
```
Marketing: demographics, segments, campaigns
Sales: deals, contacts, revenue potential
Support: tickets, satisfaction, history
Billing: payment methods, invoices, terms
```

---

## Eventstorming to Code

Translating Event Storming artifacts to implementation.

### Events → Event Classes

```
Orange sticky: "Order Placed"

→ Code:
class OrderPlaced(DomainEvent):
    order_id: OrderId
    customer_id: CustomerId
    items: List[LineItem]
    total: Money
    placed_at: datetime
```

### Commands → Command Handlers

```
Blue sticky: "Place Order"

→ Code:
class PlaceOrderCommand:
    customer_id: CustomerId
    items: List[OrderItemRequest]

class PlaceOrderHandler:
    def handle(self, command: PlaceOrderCommand) -> OrderPlaced:
        order = Order.create(command.customer_id, command.items)
        return OrderPlaced(...)
```

### Aggregates → Aggregate Roots

```
Yellow sticky: "Order"

→ Code:
class Order(AggregateRoot):
    id: OrderId
    status: OrderStatus
    items: List[LineItem]

    def place(self) -> OrderPlaced:
        self._assert_can_place()
        self.status = OrderStatus.PLACED
        return OrderPlaced(...)

    def _assert_can_place(self):
        if not self.items:
            raise InvalidOrderError("Order must have items")
```

### Policies → Event Handlers/Sagas

```
Purple sticky: "When order placed, reserve inventory"

→ Code:
class ReserveInventoryPolicy:
    @handles(OrderPlaced)
    def on_order_placed(self, event: OrderPlaced):
        for item in event.items:
            inventory.reserve(item.product_id, item.quantity)
```

---

## Bounded Context Canvas

Document each bounded context comprehensively.

```
┌─────────────────────────────────────────────────────────────────┐
│ BOUNDED CONTEXT: [Name]                                         │
├──────────────────────────┬──────────────────────────────────────┤
│ PURPOSE                  │ Strategic importance and role        │
├──────────────────────────┼──────────────────────────────────────┤
│ CLASSIFICATION           │ Core / Supporting / Generic          │
├──────────────────────────┼──────────────────────────────────────┤
│ UBIQUITOUS LANGUAGE      │ Key terms and definitions            │
├──────────────────────────┼──────────────────────────────────────┤
│ KEY AGGREGATES           │ Main consistency boundaries          │
├──────────────────────────┼──────────────────────────────────────┤
│ INBOUND COMMUNICATION    │ Commands/queries this context        │
│                          │ accepts from outside                 │
├──────────────────────────┼──────────────────────────────────────┤
│ OUTBOUND COMMUNICATION   │ Events/data this context publishes   │
├──────────────────────────┼──────────────────────────────────────┤
│ DEPENDENCIES             │ Other contexts this depends on       │
├──────────────────────────┼──────────────────────────────────────┤
│ DEPENDENTS               │ Contexts that depend on this one     │
├──────────────────────────┼──────────────────────────────────────┤
│ TEAM                     │ Who owns and maintains this context  │
└──────────────────────────┴──────────────────────────────────────┘
```

---

## Model Integrity Patterns

Techniques for maintaining model consistency.

### Immutable Value Objects

Use for concepts without identity:
- Money, Address, DateRange, Quantity
- Always valid on construction
- Equality by value, not reference

### Entity Identity

Use for concepts with lifecycle:
- Customer, Order, Product
- Unique identifier
- Mutable state
- Equality by ID

### Aggregate Transactional Boundary

```
Transaction boundary = Aggregate boundary

Good:
┌────────────────┐
│ Order          │ ← Single transaction
│  └─ LineItems  │
└────────────────┘

Bad:
┌────────────────┐   ┌─────────────┐
│ Order ─────────┼───│ Inventory   │ ← Transaction spans aggregates
└────────────────┘   └─────────────┘
```

### Eventually Consistent Across Aggregates

Use domain events for cross-aggregate consistency:

```
Order placed → (event) → Inventory reserved
     ↓                         ↓
  Order aggregate         Inventory aggregate
  (immediate consistency)  (eventual consistency)
```

---

## Anti-Corruption Layer Implementation

Practical patterns for ACL implementation.

### Adapter Pattern

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Domain Service  │ ──► │ ACL Adapter     │ ──► │ External API    │
│                 │     │ (translation)   │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘

class CustomerAdapter:
    def __init__(self, legacy_crm: LegacyCRM):
        self.crm = legacy_crm

    def get_customer(self, id: CustomerId) -> Customer:
        legacy = self.crm.fetch_contact(id.value)
        return self._translate(legacy)

    def _translate(self, legacy: LegacyContact) -> Customer:
        return Customer(
            id=CustomerId(legacy.contact_id),
            name=f"{legacy.first_name} {legacy.last_name}",
            email=Email(legacy.email_address),
            status=self._translate_status(legacy.status_code)
        )
```

### Facade Pattern

Simplify complex external interfaces:

```
class PaymentFacade:
    """Simplified interface to payment system complexity"""

    def charge(self, amount: Money, card: CardToken) -> PaymentResult:
        # Hides: retries, idempotency, multiple providers
        pass

    def refund(self, payment_id: PaymentId, amount: Money) -> RefundResult:
        # Hides: partial refund logic, provider selection
        pass
```

### Translator Service

For complex bi-directional mapping:

```
class OrderTranslator:
    def to_external(self, order: Order) -> ExternalOrder:
        """Convert domain order to external format"""
        pass

    def from_external(self, external: ExternalOrder) -> Order:
        """Convert external format to domain order"""
        pass
```
