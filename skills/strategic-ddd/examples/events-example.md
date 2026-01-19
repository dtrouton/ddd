# Domain Events Catalog

Catalog of significant domain events organized by aggregate.

---

## Order Aggregate

### OrderCreated

**Trigger**: CreateOrder command when customer initiates checkout

**Actor**: Customer (via storefront)

**Data**:
```json
{
  "eventType": "OrderCreated",
  "orderId": "ord-uuid",
  "customerId": "cust-uuid",
  "items": [
    {
      "productId": "prod-uuid",
      "sku": "WIDG-BLUE-LG",
      "productName": "Blue Widget (Large)",
      "quantity": 2,
      "unitPrice": {
        "amount": 29.99,
        "currency": "USD"
      }
    }
  ],
  "shippingAddress": {
    "line1": "123 Main St",
    "city": "Portland",
    "state": "OR",
    "postalCode": "97201",
    "country": "US"
  },
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Consumers**:
- Inventory: Creates reservations for items
- Payment: Initiates payment processing
- Analytics: Records order funnel conversion

**Business Rules**:
- Must have at least one item
- Customer must exist and be active
- Shipping address must be valid

---

### OrderPaid

**Trigger**: Payment service confirms successful payment capture

**Actor**: System (via payment webhook)

**Data**:
```json
{
  "eventType": "OrderPaid",
  "orderId": "ord-uuid",
  "paymentId": "pay-uuid",
  "amountPaid": {
    "amount": 64.98,
    "currency": "USD"
  },
  "paymentMethod": "credit_card",
  "paidAt": "2024-01-15T10:32:15Z"
}
```

**Consumers**:
- Order Management: Updates status to `paid`
- Inventory: Confirms reservations
- Fulfillment: Queues order for processing
- Email: Sends order confirmation

**Business Rules**:
- Amount must match order total
- Can only happen once per order

---

### OrderShipped

**Trigger**: Warehouse marks order as handed to carrier

**Actor**: Warehouse Staff (via fulfillment system)

**Data**:
```json
{
  "eventType": "OrderShipped",
  "orderId": "ord-uuid",
  "shipmentId": "ship-uuid",
  "carrier": "UPS",
  "trackingNumber": "1Z999AA10123456784",
  "estimatedDelivery": "2024-01-18",
  "shippedAt": "2024-01-15T14:20:00Z"
}
```

**Consumers**:
- Order Management: Updates status to `shipped`
- Customer: Sends shipping notification with tracking
- Analytics: Records fulfillment metrics

---

### OrderCancelled

**Trigger**: CancelOrder command from customer or support

**Actor**: Customer or Support Staff

**Data**:
```json
{
  "eventType": "OrderCancelled",
  "orderId": "ord-uuid",
  "reason": "customer_request",
  "reasonDetail": "Changed mind about purchase",
  "cancelledBy": "cust-uuid",
  "refundRequired": true,
  "cancelledAt": "2024-01-15T11:00:00Z"
}
```

**Consumers**:
- Inventory: Releases reservations
- Payment: Initiates refund if paid
- Email: Sends cancellation confirmation

**Business Rules**:
- Cannot cancel after shipping
- Must provide cancellation reason

---

## Customer Aggregate

### CustomerRegistered

**Trigger**: Customer completes registration form

**Actor**: Visitor (becoming Customer)

**Data**:
```json
{
  "eventType": "CustomerRegistered",
  "customerId": "cust-uuid",
  "email": "customer@example.com",
  "name": "Jane Smith",
  "registrationSource": "website",
  "registeredAt": "2024-01-10T09:15:00Z"
}
```

**Consumers**:
- Email: Sends welcome email
- Marketing: Adds to onboarding campaign
- Analytics: Records acquisition

---

### CustomerLoyaltyTierChanged

**Trigger**: Loyalty calculation job or manual upgrade

**Actor**: System (scheduled job) or Support Staff

**Data**:
```json
{
  "eventType": "CustomerLoyaltyTierChanged",
  "customerId": "cust-uuid",
  "previousTier": "silver",
  "newTier": "gold",
  "reason": "annual_spend_threshold",
  "effectiveDate": "2024-02-01",
  "changedAt": "2024-01-31T23:59:59Z"
}
```

**Consumers**:
- Email: Sends tier upgrade notification
- Pricing: Updates discount eligibility
- Customer Profile: Updates displayed tier

---

## Inventory Aggregate

### InventoryReserved

**Trigger**: OrderCreated event received

**Actor**: System (event handler)

**Data**:
```json
{
  "eventType": "InventoryReserved",
  "reservationId": "res-uuid",
  "orderId": "ord-uuid",
  "items": [
    {
      "sku": "WIDG-BLUE-LG",
      "warehouseId": "wh-portland",
      "quantity": 2,
      "location": "A-3-12"
    }
  ],
  "expiresAt": "2024-01-15T11:00:00Z",
  "reservedAt": "2024-01-15T10:30:05Z"
}
```

**Consumers**:
- Order Management: Confirms items available
- Warehouse Display: Updates available counts

**Business Rules**:
- Cannot reserve more than available
- Reservation expires after 30 minutes

---

### InventoryDepleted

**Trigger**: Available stock reaches zero

**Actor**: System (after reservation or adjustment)

**Data**:
```json
{
  "eventType": "InventoryDepleted",
  "sku": "WIDG-BLUE-LG",
  "warehouseId": "wh-portland",
  "lastQuantity": 2,
  "depletedAt": "2024-01-15T10:30:05Z"
}
```

**Consumers**:
- Product Catalog: Marks as out of stock
- Purchasing: Triggers reorder alert
- Marketing: Pauses ads for item

---

## Payment Aggregate

### PaymentAuthorized

**Trigger**: Payment provider authorizes charge

**Actor**: System (payment gateway callback)

**Data**:
```json
{
  "eventType": "PaymentAuthorized",
  "paymentId": "pay-uuid",
  "orderId": "ord-uuid",
  "amount": {
    "amount": 64.98,
    "currency": "USD"
  },
  "authorizationCode": "AUTH123456",
  "expiresAt": "2024-01-22T10:32:00Z",
  "authorizedAt": "2024-01-15T10:32:00Z"
}
```

**Consumers**:
- Order Management: Proceeds with order confirmation
- Fraud Detection: Logs for analysis

---

### PaymentFailed

**Trigger**: Payment provider declines charge

**Actor**: System (payment gateway callback)

**Data**:
```json
{
  "eventType": "PaymentFailed",
  "paymentId": "pay-uuid",
  "orderId": "ord-uuid",
  "amount": {
    "amount": 64.98,
    "currency": "USD"
  },
  "failureCode": "insufficient_funds",
  "failureMessage": "Card declined - insufficient funds",
  "failedAt": "2024-01-15T10:32:00Z"
}
```

**Consumers**:
- Order Management: Updates order status, notifies customer
- Inventory: Releases reservations
- Email: Sends payment failure notification

---

## Event Flow Example

```
Customer places order
         │
         ▼
    OrderCreated
    ┌────┴────┐
    │         │
    ▼         ▼
InventoryReserved  PaymentAuthorized
                          │
                          ▼
                     OrderPaid
                          │
                    ┌─────┴─────┐
                    │           │
                    ▼           ▼
           InventoryConfirmed  FulfillmentQueued
                                    │
                                    ▼
                              OrderShipped
                                    │
                                    ▼
                             OrderDelivered
```

---

## Policies (Event → Reaction)

| When | Then |
|------|------|
| OrderCreated | Reserve inventory, authorize payment |
| PaymentAuthorized | Capture payment |
| PaymentCaptured | Confirm reservations, queue fulfillment |
| PaymentFailed | Release reservations, notify customer |
| OrderShipped | Notify customer with tracking |
| InventoryDepleted | Update catalog, alert purchasing |
| CustomerRegistered | Send welcome email, start onboarding |
