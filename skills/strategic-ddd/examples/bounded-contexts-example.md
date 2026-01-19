# Bounded Context Map

## Overview

This document maps the bounded contexts for an e-commerce platform, showing context boundaries and their relationships.

## Contexts

### Product Catalog
- **Purpose**: Manage product information, categories, and searchability
- **Key Concepts**: Product, Category, Attribute, SearchIndex
- **Classification**: Supporting Subdomain
- **Team**: Catalog Team

### Order Management
- **Purpose**: Handle the order lifecycle from creation to completion
- **Key Concepts**: Order, LineItem, OrderStatus, Fulfillment
- **Classification**: Core Domain
- **Team**: Orders Team

### Inventory
- **Purpose**: Track stock levels and manage reservations
- **Key Concepts**: StockItem, Reservation, Warehouse, SKU
- **Classification**: Supporting Subdomain
- **Team**: Warehouse Team

### Customer Management
- **Purpose**: Manage customer profiles, preferences, and history
- **Key Concepts**: Customer, Profile, Preferences, LoyaltyTier
- **Classification**: Core Domain
- **Team**: Customer Team

### Payment Processing
- **Purpose**: Handle payment authorization, capture, and refunds
- **Key Concepts**: Payment, Transaction, PaymentMethod, Refund
- **Classification**: Generic Subdomain
- **Team**: Payments Team (uses external provider)

### Shipping
- **Purpose**: Manage delivery logistics and tracking
- **Key Concepts**: Shipment, Carrier, TrackingNumber, DeliveryEstimate
- **Classification**: Supporting Subdomain
- **Team**: Logistics Team

## Context Map Diagram

```
                          ┌──────────────────┐
                          │                  │
                          │  Product Catalog │
                          │                  │
                          └────────┬─────────┘
                                   │
                                   │ OHS (Product API)
                                   │
                          ┌────────▼─────────┐
                          │                  │
              ┌───────────│ Order Management │───────────┐
              │           │                  │           │
              │           └────────┬─────────┘           │
              │                    │                     │
              │ Customer-Supplier  │ Partnership         │ ACL
              │                    │                     │
    ┌─────────▼────────┐  ┌────────▼─────────┐  ┌───────▼──────────┐
    │                  │  │                  │  │                  │
    │    Customer      │  │    Inventory     │  │     Payment      │
    │   Management     │  │                  │  │   Processing     │
    │                  │  │                  │  │   (External)     │
    └──────────────────┘  └────────┬─────────┘  └──────────────────┘
                                   │
                                   │ Customer-Supplier
                                   │
                          ┌────────▼─────────┐
                          │                  │
                          │     Shipping     │
                          │                  │
                          └──────────────────┘
```

## Relationships

### Product Catalog → Order Management
- **Type**: Open Host Service
- **Description**: Catalog provides REST API for product lookup
- **Data Flow**: Product details, pricing, availability
- **Protocol**: REST/JSON

### Order Management → Customer Management
- **Type**: Customer-Supplier
- **Description**: Orders queries customer data, Customer provides
- **Data Flow**: Customer profiles, shipping addresses
- **Contract**: Customer team accommodates Orders team requests

### Order Management ↔ Inventory
- **Type**: Partnership
- **Description**: Tight coordination for stock reservation
- **Data Flow**: Reservations, stock levels, backorders
- **Integration**: Shared event bus, coordinated releases

### Order Management → Payment Processing
- **Type**: Anticorruption Layer
- **Description**: ACL protects from external payment API changes
- **Data Flow**: Payment requests, confirmations, refunds
- **Translation**: PaymentRequest → StripeChargeRequest

### Inventory → Shipping
- **Type**: Customer-Supplier
- **Description**: Shipping consumes inventory allocation data
- **Data Flow**: Ready-to-ship items, warehouse locations
- **Contract**: Inventory publishes fulfillment-ready events

## Integration Points

### Event Bus Topics

| Topic | Publisher | Consumers |
|-------|-----------|-----------|
| order.placed | Order Management | Inventory, Payment |
| order.paid | Payment Processing | Order Management |
| inventory.reserved | Inventory | Order Management, Shipping |
| shipment.dispatched | Shipping | Order Management, Customer |

### Shared Events

```json
{
  "eventType": "OrderPlaced",
  "version": "1.0",
  "orderId": "ord-123",
  "customerId": "cust-456",
  "items": [
    {"productId": "prod-789", "quantity": 2}
  ],
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Notes

- Payment Processing uses Stripe as external provider; ACL isolates us from their API changes
- Consider merging Inventory and Shipping if warehouse team grows
- Product Catalog may need splitting if catalog vs search concerns diverge
