Enh# Payment Database Schema Migration

## ✅ TDD Status: RED → GREEN Phase Ready

### Integration Tests Created
- ✅ **14 comprehensive integration tests** covering all payment tables
- ✅ **Tests currently FAILING** (expected) - tables don't exist yet
- ✅ **Ready for GREEN phase** once schema is applied

### Schema Files Created
- ✅ **`terraform-supabase/sql/05_create_payment_tables.sql`** - Complete payment schema

## How to Apply Schema to Supabase

### Option 1: Supabase Dashboard
1. Login to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your Whisky Hikes project
3. Go to **SQL Editor**
4. Copy contents of `terraform-supabase/sql/05_create_payment_tables.sql`
5. Execute the SQL

### Option 2: Supabase CLI
```bash
# If using Supabase CLI
supabase db reset
supabase db push
```

### Option 3: Terraform (Recommended)
```bash
cd terraform-supabase
terraform plan
terraform apply
```

## Expected Results After Schema Application

### Database Tables Created
1. **`public.orders`** - Customer orders
2. **`public.order_items`** - Items within orders  
3. **`public.payments`** - Stripe payment records

### Features Implemented
- ✅ **Foreign Key Constraints** - Data integrity
- ✅ **Check Constraints** - Business rule validation
- ✅ **Row Level Security (RLS)** - User-specific access
- ✅ **Indexes** - Query performance optimization
- ✅ **Triggers** - Auto-updating timestamps & validation
- ✅ **Business Logic Validation** - Order/payment amount matching

### Test Verification
After applying schema, run integration tests:
```bash
flutter test test/integration/database/payment_schema_integration_test.dart
```

**Expected**: All 14 tests should **PASS** ✅

## Schema Details

### Orders Table Structure
```sql
- id: SERIAL PRIMARY KEY
- order_number: TEXT UNIQUE (e.g., 'WH2025-000123')
- hike_id: INTEGER → public.hikes(id)
- user_id: UUID → auth.users(id)
- total_amount: DECIMAL(10,2)
- delivery_type: TEXT ('pickup', 'shipping')
- status: TEXT ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')
- estimated_delivery: TIMESTAMP (optional)
- tracking_number: TEXT (optional)
- delivery_address: JSONB (optional)
- payment_intent_id: TEXT (optional)
- created_at/updated_at: TIMESTAMP
```

### Order Items Table Structure  
```sql
- id: SERIAL PRIMARY KEY
- order_id: INTEGER → public.orders(id)
- hike_id: INTEGER → public.hikes(id)
- quantity: INTEGER (CHECK > 0)
- unit_price: DECIMAL(10,2) (CHECK >= 0)
- total_price: DECIMAL(10,2) (CHECK >= 0)
- created_at/updated_at: TIMESTAMP
```

### Payments Table Structure
```sql
- id: SERIAL PRIMARY KEY
- order_id: INTEGER → public.orders(id)
- payment_intent_id: TEXT UNIQUE
- client_secret: TEXT (optional)
- amount: INTEGER (CHECK > 0) -- Cents
- currency: TEXT ('eur', 'usd', 'gbp', 'chf')
- status: TEXT ('pending', 'succeeded', 'failed', 'cancelled', 'requires_action')
- payment_method: TEXT ('card', 'sepa_debit', 'paypal', 'apple_pay', 'google_pay')
- failure_reason: TEXT (optional)
- metadata: JSONB (optional)
- stripe_created_at: TIMESTAMP (optional)
- created_at/updated_at: TIMESTAMP
```

## Business Logic Validation

### Automatic Validation Triggers
1. **Order Total Validation** - Ensures order.total_amount equals sum of order_items.total_price
2. **Payment Amount Validation** - Ensures payment.amount (cents) matches order.total_amount * 100

### Row Level Security Policies
- **Users**: Can only access their own orders/payments
- **Service Role**: Full access for backend operations
- **Anonymous**: No access

## Next Steps After Schema Application

1. **✅ Verify Tests Pass** - Run integration tests
2. **🔄 Create PaymentRepository** - Next TDD phase (Schritt 6)
3. **🔄 Build Checkout UI** - Widget tests then implementation (Schritt 7)

---
*Generated via TDD methodology - RED phase complete, GREEN phase ready*