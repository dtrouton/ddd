# Domain Glossary

Ubiquitous language definitions for each bounded context.

---

## Order Management Context

### Order
**Definition**: A confirmed intent by a customer to purchase one or more products, representing a contractual commitment to pay for and receive goods.

**Examples**:
- A customer completes checkout with 3 items → creates one Order
- A subscription renewal → creates a recurring Order

**Related Terms**: LineItem, OrderStatus, Fulfillment

**Not to be confused with**: Cart (which is uncommitted intent), Quote (which is a price proposal)

---

### Line Item
**Definition**: A single product entry within an Order, specifying the product, quantity, and agreed price at time of order.

**Examples**:
- "2x Blue Widget at $10.00 each" is one LineItem
- An Order with 3 different products has 3 LineItems

**Related Terms**: Order, Product (from Catalog context)

**Business Rules**:
- Quantity must be positive
- Price is locked at order time (doesn't change if catalog price changes)

---

### Order Status
**Definition**: The current state of an Order in its lifecycle.

**Values**:
| Status | Meaning |
|--------|---------|
| `pending_payment` | Order created, awaiting payment |
| `paid` | Payment confirmed, ready for fulfillment |
| `processing` | Being prepared for shipment |
| `shipped` | Handed to carrier |
| `delivered` | Confirmed receipt by customer |
| `cancelled` | Order terminated before completion |

**Transitions**:
```
pending_payment → paid → processing → shipped → delivered
       ↓           ↓         ↓
    cancelled   cancelled  cancelled (with refund)
```

---

### Fulfillment
**Definition**: The process of preparing and delivering an Order to the customer, from warehouse picking to doorstep delivery.

**Examples**:
- Picking items from warehouse shelves
- Packing items into shipping container
- Handing package to carrier

**Related Terms**: Shipment (in Shipping context), Reservation (in Inventory context)

---

## Customer Management Context

### Customer
**Definition**: An individual or organization who has created an account and can place Orders. A Customer has a unique identity that persists across sessions and transactions.

**Examples**:
- A person who registered via the website
- A business account with multiple authorized users

**Related Terms**: Profile, LoyaltyTier

**Not to be confused with**:
- User (authentication concept in Identity context)
- Contact (in Marketing context, may not have purchased)
- Guest (unregistered purchaser, no persistent identity)

---

### Profile
**Definition**: The collection of preferences, addresses, and personal information associated with a Customer.

**Contains**:
- Shipping addresses (multiple allowed)
- Billing addresses
- Communication preferences
- Display preferences

**Related Terms**: Customer, Preferences

---

### Loyalty Tier
**Definition**: A classification of Customer based on purchase history and engagement, determining benefits and pricing.

**Values**:
| Tier | Qualification | Benefits |
|------|--------------|----------|
| Bronze | Default | Base pricing |
| Silver | $500+ annual spend | 5% discount |
| Gold | $2000+ annual spend | 10% discount, free shipping |
| Platinum | $10000+ annual spend | 15% discount, priority support |

---

## Inventory Context

### Stock Item
**Definition**: A countable unit of a specific product variant held in a warehouse, tracked by SKU and location.

**Examples**:
- 50 units of "Blue Widget (Large)" in Warehouse A, Aisle 3
- 12 units of same product in Warehouse B

**Related Terms**: SKU, Warehouse, Reservation

**Not to be confused with**: Product (in Catalog context - describes what it is, not how many)

---

### SKU (Stock Keeping Unit)
**Definition**: A unique identifier for a specific product variant, used to track inventory and fulfill orders.

**Format**: `{CATEGORY}-{PRODUCT}-{VARIANT}`

**Examples**:
- `WIDG-BLUE-LG` (Blue Widget, Large)
- `WIDG-BLUE-SM` (Blue Widget, Small)

**Related Terms**: Stock Item, Product (in Catalog)

---

### Reservation
**Definition**: A temporary hold on Stock Items for a pending Order, preventing overselling while payment is processed.

**Lifecycle**:
1. Created when Order placed
2. Confirmed when payment succeeds
3. Released if payment fails or Order cancelled
4. Consumed when items shipped

**Examples**:
- Order for 2 Blue Widgets creates Reservation for 2 units
- Reservation expires after 30 minutes if unpaid

**Business Rules**:
- Cannot reserve more than available stock
- Reservation reduces "available" count but not "physical" count
- Expired reservations automatically release

---

## Payment Processing Context

### Payment
**Definition**: A financial transaction representing the transfer of funds from a Customer to the business for an Order.

**Examples**:
- Credit card charge of $99.00
- PayPal transfer of $150.00

**Related Terms**: Transaction, PaymentMethod, Refund

**Not to be confused with**: Invoice (a request for payment, not the payment itself)

---

### Transaction
**Definition**: A record of a payment attempt, whether successful or failed, including authorization and capture details.

**States**:
| State | Meaning |
|-------|---------|
| `authorized` | Funds held, not yet captured |
| `captured` | Funds transferred |
| `failed` | Attempt unsuccessful |
| `refunded` | Funds returned |

---

### Refund
**Definition**: A reversal of a Payment, returning funds to the Customer.

**Types**:
- Full refund: entire Payment amount returned
- Partial refund: portion of Payment returned

**Business Rules**:
- Can only refund captured transactions
- Total refunds cannot exceed original Payment
- Refund creates audit trail

---

## Cross-Context Terms

Some terms appear in multiple contexts with different meanings:

### "Product"

| Context | Meaning |
|---------|---------|
| **Catalog** | Marketing description, images, categories, searchable attributes |
| **Inventory** | Physical item tracked by SKU, warehouse location, quantity |
| **Order** | Snapshot of product details at time of purchase (name, price) |

### "Customer"

| Context | Meaning |
|---------|---------|
| **Customer Management** | Account holder with profile and history |
| **Order** | Reference (ID) to who placed the order |
| **Marketing** | Contact for campaigns, may not have account |

### "Price"

| Context | Meaning |
|---------|---------|
| **Catalog** | Current listed price, may change anytime |
| **Order** | Locked price at time of order, doesn't change |
| **Promotion** | Discounted price during campaign period |
