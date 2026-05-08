-- Payment System Tables for Whisky Hikes App
-- TDD Implementation - GREEN Phase
-- Based on TDD tests and BasicOrder/BasicPaymentResult models

-- Orders Tabelle (entspricht BasicOrder model)
CREATE TABLE IF NOT EXISTS public.orders (
    id SERIAL PRIMARY KEY,
    order_number TEXT NOT NULL UNIQUE,
    hike_id INTEGER NOT NULL REFERENCES public.hikes(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    delivery_type TEXT NOT NULL CHECK (delivery_type IN ('pickup', 'shipping')),
    status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    tracking_number TEXT,
    delivery_address JSONB,
    payment_intent_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order Items Tabelle (für flexible item structure)
CREATE TABLE IF NOT EXISTS public.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    hike_id INTEGER NOT NULL REFERENCES public.hikes(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payments Tabelle (für Stripe payment tracking)
CREATE TABLE IF NOT EXISTS public.payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
    payment_intent_id TEXT NOT NULL UNIQUE,
    client_secret TEXT,
    amount INTEGER NOT NULL CHECK (amount > 0), -- Amount in cents (Stripe convention)
    currency TEXT NOT NULL CHECK (currency IN ('eur', 'usd', 'gbp', 'chf')) DEFAULT 'eur',
    status TEXT NOT NULL CHECK (status IN ('pending', 'succeeded', 'failed', 'cancelled', 'requires_action')),
    payment_method TEXT CHECK (payment_method IN ('card', 'sepa_debit', 'paypal', 'apple_pay', 'google_pay')),
    failure_reason TEXT,
    metadata JSONB,
    stripe_created_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexe für bessere Performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_hike_id ON public.orders(hike_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON public.orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_hike_id ON public.order_items(hike_id);

CREATE INDEX IF NOT EXISTS idx_payments_order_id ON public.payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_intent_id ON public.payments(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at);

-- Trigger für updated_at Timestamps
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON public.order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies

-- Enable RLS auf allen payment tables
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Orders Policies (Benutzer können nur eigene orders sehen/bearbeiten)
CREATE POLICY "Users can view their own orders" ON public.orders
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own orders" ON public.orders
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own orders" ON public.orders
    FOR UPDATE USING (auth.uid() = user_id);

-- Order Items Policies (über orders table linkage)
CREATE POLICY "Users can view their own order items" ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE orders.id = order_items.order_id 
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own order items" ON public.order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE orders.id = order_items.order_id 
            AND orders.user_id = auth.uid()
        )
    );

-- Payments Policies (über orders table linkage)  
CREATE POLICY "Users can view their own payments" ON public.payments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE orders.id = payments.order_id 
            AND orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own payments" ON public.payments
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE orders.id = payments.order_id 
            AND orders.user_id = auth.uid()
        )
    );

-- Admin policies (optional - für backend access)
CREATE POLICY "Service role can access all orders" ON public.orders
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

CREATE POLICY "Service role can access all order items" ON public.order_items
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

CREATE POLICY "Service role can access all payments" ON public.payments
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Business Logic Constraints

-- Ensure order total matches sum of order items (via trigger)
CREATE OR REPLACE FUNCTION validate_order_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Only validate on update of order items
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- Check if order total matches sum of order items
        PERFORM 1 
        FROM public.orders o
        LEFT JOIN (
            SELECT order_id, SUM(total_price) as items_total
            FROM public.order_items 
            WHERE order_id = NEW.order_id
            GROUP BY order_id
        ) items ON o.id = items.order_id
        WHERE o.id = NEW.order_id
        AND ABS(o.total_amount - COALESCE(items.items_total, 0)) > 0.01;
        
        IF FOUND THEN
            RAISE EXCEPTION 'Order total must match sum of order items';
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply validation trigger
CREATE TRIGGER validate_order_total_trigger
    AFTER INSERT OR UPDATE ON public.order_items
    FOR EACH ROW EXECUTE FUNCTION validate_order_total();

-- Ensure payment amount matches order total (in cents)
CREATE OR REPLACE FUNCTION validate_payment_amount()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- Check if payment amount matches order total (converted to cents)
        PERFORM 1
        FROM public.orders o
        WHERE o.id = NEW.order_id
        AND ABS((o.total_amount * 100)::INTEGER - NEW.amount) > 1; -- Allow 1 cent rounding
        
        IF FOUND THEN
            RAISE EXCEPTION 'Payment amount must match order total (in cents)';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply payment validation trigger
CREATE TRIGGER validate_payment_amount_trigger
    BEFORE INSERT OR UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION validate_payment_amount();

-- Comments für Dokumentation
COMMENT ON TABLE public.orders IS 'Customer orders for hike purchases';
COMMENT ON TABLE public.order_items IS 'Individual items within an order';
COMMENT ON TABLE public.payments IS 'Payment transactions via Stripe';

COMMENT ON COLUMN public.orders.order_number IS 'Unique order identifier (e.g., WH2025-000123)';
COMMENT ON COLUMN public.orders.delivery_type IS 'pickup or shipping';
COMMENT ON COLUMN public.orders.status IS 'Order processing status';
COMMENT ON COLUMN public.orders.delivery_address IS 'JSONB delivery address for shipping orders';

COMMENT ON COLUMN public.payments.amount IS 'Payment amount in cents (Stripe convention)';
COMMENT ON COLUMN public.payments.payment_intent_id IS 'Stripe PaymentIntent ID';
COMMENT ON COLUMN public.payments.client_secret IS 'Stripe client secret for frontend';
COMMENT ON COLUMN public.payments.metadata IS 'Additional Stripe metadata as JSONB';