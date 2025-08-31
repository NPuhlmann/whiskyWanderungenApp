-- Enhanced Order System Tables
-- Extends basic orders with comprehensive tracking and multi-vendor support
-- Based on EnhancedOrder model and OrderStatusChange

-- Enhanced Orders Table (extends basic orders functionality)
CREATE TABLE IF NOT EXISTS public.enhanced_orders (
    id SERIAL PRIMARY KEY,
    order_number TEXT NOT NULL UNIQUE,
    
    -- Multi-Vendor Context
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE RESTRICT,
    
    -- Order Details
    hike_id INTEGER REFERENCES public.hikes(id) ON DELETE RESTRICT,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    shipping_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (shipping_cost >= 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    currency TEXT NOT NULL DEFAULT 'EUR' CHECK (currency IN ('EUR', 'USD', 'GBP', 'CHF')),
    base_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (base_amount >= 0),
    
    -- Status & Timestamps
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
        'pending', 'paymentPending', 'confirmed', 'processing', 
        'shipped', 'outForDelivery', 'delivered', 'cancelled', 'refunded', 'failed'
    )),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    
    -- Customer Information
    customer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_email TEXT,
    customer_phone TEXT,
    
    -- Delivery & Shipping
    delivery_type TEXT NOT NULL DEFAULT 'standardShipping' CHECK (delivery_type IN (
        'pickup', 'standardShipping', 'expressShipping', 'premiumShipping'
    )),
    delivery_address JSONB NOT NULL,
    tracking_number TEXT,
    tracking_url TEXT,
    shipping_carrier TEXT,
    shipping_method TEXT,
    shipping_service TEXT,
    estimated_delivery_date TEXT,
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    actual_delivery TIMESTAMP WITH TIME ZONE,
    shipping_details JSONB,
    
    -- Payment Information
    payment_intent_id TEXT,
    payment_method_id TEXT,
    payment_status TEXT,
    payment_date TIMESTAMP WITH TIME ZONE,
    
    -- Additional Details
    notes TEXT,
    internal_notes TEXT,
    metadata JSONB,
    tags TEXT[],
    
    -- Vendor Specific
    vendor_order_id TEXT,
    vendor_notes TEXT,
    vendor_metadata JSONB,
    
    -- Constraints
    CONSTRAINT enhanced_orders_delivery_address_check CHECK (delivery_address IS NOT NULL),
    CONSTRAINT enhanced_orders_total_calculation_check CHECK (
        total_amount = subtotal + tax_amount + shipping_cost
    )
);

-- Order Status History Table (for audit trail)
CREATE TABLE IF NOT EXISTS public.order_status_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES public.enhanced_orders(id) ON DELETE CASCADE,
    from_status TEXT NOT NULL,
    to_status TEXT NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    reason TEXT,
    notes TEXT,
    changed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    metadata JSONB,
    
    -- Constraints
    CONSTRAINT valid_status_values CHECK (
        from_status IN ('pending', 'paymentPending', 'confirmed', 'processing', 
                       'shipped', 'outForDelivery', 'delivered', 'cancelled', 'refunded', 'failed') AND
        to_status IN ('pending', 'paymentPending', 'confirmed', 'processing', 
                     'shipped', 'outForDelivery', 'delivered', 'cancelled', 'refunded', 'failed')
    )
);

-- Shipping Carriers Table (for carrier management)
CREATE TABLE IF NOT EXISTS public.shipping_carriers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE,
    tracking_url_template TEXT, -- e.g., 'https://tracking.dhl.com/tracking/{tracking_number}'
    is_active BOOLEAN NOT NULL DEFAULT true,
    supported_countries TEXT[], -- ISO country codes
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Shipping Methods Table (for method-specific configuration)
CREATE TABLE IF NOT EXISTS public.shipping_methods (
    id SERIAL PRIMARY KEY,
    carrier_id INTEGER NOT NULL REFERENCES public.shipping_carriers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    estimated_days_min INTEGER,
    estimated_days_max INTEGER,
    base_cost DECIMAL(10,2),
    cost_per_kg DECIMAL(10,2),
    free_shipping_threshold DECIMAL(10,2),
    is_active BOOLEAN NOT NULL DEFAULT true,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(carrier_id, code)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_company_id ON public.enhanced_orders(company_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_customer_id ON public.enhanced_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_hike_id ON public.enhanced_orders(hike_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_order_number ON public.enhanced_orders(order_number);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_status ON public.enhanced_orders(status);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_delivery_type ON public.enhanced_orders(delivery_type);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_tracking_number ON public.enhanced_orders(tracking_number);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_created_at ON public.enhanced_orders(created_at);
CREATE INDEX IF NOT EXISTS idx_enhanced_orders_payment_intent_id ON public.enhanced_orders(payment_intent_id);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON public.order_status_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_changed_at ON public.order_status_history(changed_at);
CREATE INDEX IF NOT EXISTS idx_order_status_history_to_status ON public.order_status_history(to_status);

CREATE INDEX IF NOT EXISTS idx_shipping_carriers_code ON public.shipping_carriers(code);
CREATE INDEX IF NOT EXISTS idx_shipping_carriers_is_active ON public.shipping_carriers(is_active);

CREATE INDEX IF NOT EXISTS idx_shipping_methods_carrier_id ON public.shipping_methods(carrier_id);
CREATE INDEX IF NOT EXISTS idx_shipping_methods_code ON public.shipping_methods(code);
CREATE INDEX IF NOT EXISTS idx_shipping_methods_is_active ON public.shipping_methods(is_active);

-- Triggers for updated_at timestamps
CREATE TRIGGER update_enhanced_orders_updated_at BEFORE UPDATE ON public.enhanced_orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Status history trigger (automatically record status changes)
CREATE OR REPLACE FUNCTION record_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Only record if status actually changed
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.order_status_history (
            order_id,
            from_status,
            to_status,
            changed_at,
            reason,
            changed_by
        ) VALUES (
            NEW.id,
            COALESCE(OLD.status, 'pending'),
            NEW.status,
            NOW(),
            CASE 
                WHEN NEW.status = 'confirmed' AND OLD.status = 'paymentPending' THEN 'Payment confirmed'
                WHEN NEW.status = 'processing' AND OLD.status = 'confirmed' THEN 'Order processing started'
                WHEN NEW.status = 'shipped' AND OLD.status = 'processing' THEN 'Package shipped'
                WHEN NEW.status = 'delivered' AND OLD.status IN ('shipped', 'outForDelivery') THEN 'Package delivered'
                WHEN NEW.status = 'cancelled' THEN 'Order cancelled'
                ELSE 'Status updated'
            END,
            auth.uid()
        );
        
        -- Update timestamp fields based on status
        IF NEW.status = 'confirmed' AND OLD.status != 'confirmed' THEN
            NEW.confirmed_at = NOW();
        ELSIF NEW.status = 'shipped' AND OLD.status != 'shipped' THEN
            NEW.shipped_at = NOW();
        ELSIF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
            NEW.delivered_at = NOW();
        ELSIF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
            NEW.cancelled_at = NOW();
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply status history trigger
CREATE TRIGGER enhanced_orders_status_history_trigger
    BEFORE UPDATE ON public.enhanced_orders
    FOR EACH ROW EXECUTE FUNCTION record_order_status_change();

-- Row Level Security (RLS)
ALTER TABLE public.enhanced_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_methods ENABLE ROW LEVEL SECURITY;

-- Enhanced Orders Policies
CREATE POLICY "Users can view their own enhanced orders" ON public.enhanced_orders
    FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Users can insert their own enhanced orders" ON public.enhanced_orders
    FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Users can update their own enhanced orders" ON public.enhanced_orders
    FOR UPDATE USING (auth.uid() = customer_id);

-- Company owners can view their company's orders
CREATE POLICY "Company owners can view company orders" ON public.enhanced_orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.companies c
            WHERE c.id = enhanced_orders.company_id
            AND c.owner_id = auth.uid()
        )
    );

-- Order Status History Policies
CREATE POLICY "Users can view their order status history" ON public.order_status_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.enhanced_orders eo
            WHERE eo.id = order_status_history.order_id
            AND eo.customer_id = auth.uid()
        )
    );

-- Shipping Carriers/Methods Policies (read-only for authenticated users)
CREATE POLICY "Authenticated users can view shipping carriers" ON public.shipping_carriers
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can view shipping methods" ON public.shipping_methods
    FOR SELECT TO authenticated USING (true);

-- Service role policies (full access for backend operations)
CREATE POLICY "Service role full access enhanced orders" ON public.enhanced_orders
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

CREATE POLICY "Service role full access order status history" ON public.order_status_history
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

CREATE POLICY "Service role full access shipping carriers" ON public.shipping_carriers
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

CREATE POLICY "Service role full access shipping methods" ON public.shipping_methods
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Insert default shipping carriers
INSERT INTO public.shipping_carriers (name, code, tracking_url_template, supported_countries) VALUES
    ('DHL Express', 'DHL_EXPRESS', 'https://www.dhl.com/en/express/tracking.html?AWB={tracking_number}', ARRAY['DE', 'AT', 'CH', 'NL', 'BE', 'FR', 'IT', 'ES', 'US', 'GB']),
    ('DHL Paket', 'DHL_PAKET', 'https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=de&idc={tracking_number}', ARRAY['DE', 'AT']),
    ('Deutsche Post', 'DEUTSCHE_POST', 'https://www.deutschepost.de/sendung/simpleQuery.html?locale=de_DE&mcId={tracking_number}', ARRAY['DE']),
    ('UPS', 'UPS', 'https://www.ups.com/track?trackingNumber={tracking_number}', ARRAY['DE', 'AT', 'CH', 'US', 'GB', 'FR', 'IT', 'ES']),
    ('FedEx', 'FEDEX', 'https://www.fedex.com/fedextrack/?trknbr={tracking_number}', ARRAY['US', 'GB', 'FR', 'IT', 'ES', 'DE', 'AT', 'CH']),
    ('Hermes', 'HERMES', 'https://www.myhermes.de/empfangen/sendungsverfolgung/sendungsinformation/#trackId={tracking_number}', ARRAY['DE', 'AT']),
    ('GLS', 'GLS', 'https://gls-group.eu/DE/de/paketverfolgung?match={tracking_number}', ARRAY['DE', 'AT', 'CH', 'NL', 'BE', 'FR'])
ON CONFLICT (code) DO NOTHING;

-- Insert default shipping methods
INSERT INTO public.shipping_methods (carrier_id, name, code, estimated_days_min, estimated_days_max, base_cost, free_shipping_threshold) 
SELECT 
    c.id,
    method.name,
    method.code,
    method.days_min,
    method.days_max,
    method.cost,
    method.free_threshold
FROM public.shipping_carriers c
CROSS JOIN (
    VALUES 
        ('DHL_EXPRESS', 'DHL Express Worldwide', 'EXPRESS_WORLDWIDE', 1, 3, 25.00, 100.00),
        ('DHL_PAKET', 'DHL Paket Standard', 'PAKET_STANDARD', 1, 3, 4.90, 50.00),
        ('DEUTSCHE_POST', 'Deutsche Post Standardbrief', 'POST_STANDARD', 2, 4, 2.90, 30.00),
        ('UPS', 'UPS Express', 'UPS_EXPRESS', 1, 2, 20.00, 100.00),
        ('UPS', 'UPS Standard', 'UPS_STANDARD', 2, 5, 8.90, 50.00),
        ('HERMES', 'Hermes Päckchen', 'HERMES_PAECKCHEN', 2, 4, 3.90, 40.00),
        ('GLS', 'GLS ParcelService', 'GLS_STANDARD', 1, 3, 6.90, 50.00)
) AS method(carrier_code, name, code, days_min, days_max, cost, free_threshold)
WHERE c.code = method.carrier_code
ON CONFLICT (carrier_id, code) DO NOTHING;

-- Comments
COMMENT ON TABLE public.enhanced_orders IS 'Enhanced order system with comprehensive tracking and multi-vendor support';
COMMENT ON TABLE public.order_status_history IS 'Audit trail for order status changes';
COMMENT ON TABLE public.shipping_carriers IS 'Shipping carrier configuration and tracking templates';
COMMENT ON TABLE public.shipping_methods IS 'Available shipping methods per carrier';

COMMENT ON COLUMN public.enhanced_orders.company_id IS 'Company/vendor that owns this order';
COMMENT ON COLUMN public.enhanced_orders.delivery_address IS 'Full delivery address as JSONB';
COMMENT ON COLUMN public.enhanced_orders.shipping_details IS 'Shipping calculation result and details';
COMMENT ON COLUMN public.enhanced_orders.tracking_number IS 'Carrier tracking number';
COMMENT ON COLUMN public.enhanced_orders.tracking_url IS 'Full tracking URL for customer';