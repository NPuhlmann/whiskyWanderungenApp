-- Multi-Vendor Companies System for Whisky Hikes
-- Allows different companies to create and sell hikes internationally
-- Each company can set their own shipping costs per region

-- Companies Table (Vendors/Hike Creators)
CREATE TABLE IF NOT EXISTS public.companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    contact_email TEXT NOT NULL,
    phone TEXT,
    
    -- Location Information
    country_code TEXT NOT NULL CHECK (LENGTH(country_code) = 2), -- ISO 3166-1 alpha-2
    country_name TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT,
    address_line_1 TEXT,
    address_line_2 TEXT,
    
    -- Business Information  
    company_registration_number TEXT,
    vat_number TEXT,
    website_url TEXT,
    logo_url TEXT,
    
    -- System Fields
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT companies_email_format CHECK (contact_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT companies_country_code_format CHECK (country_code ~ '^[A-Z]{2}$')
);

-- Add company relationship to hikes
ALTER TABLE public.hikes 
ADD COLUMN IF NOT EXISTS company_id UUID REFERENCES public.companies(id) ON DELETE RESTRICT;

-- Company Shipping Rules Matrix
-- Defines shipping costs from company's country to destination countries
CREATE TABLE IF NOT EXISTS public.company_shipping_rules (
    id SERIAL PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    
    -- Geographic Rules
    from_country_code TEXT NOT NULL CHECK (LENGTH(from_country_code) = 2),
    to_country_code TEXT NOT NULL CHECK (LENGTH(to_country_code) = 2),
    to_region TEXT, -- Optional: 'EU', 'EUROPE', 'WORLDWIDE' for grouping
    
    -- Pricing Rules
    shipping_cost DECIMAL(10,2) NOT NULL CHECK (shipping_cost >= 0),
    free_shipping_threshold DECIMAL(10,2) CHECK (free_shipping_threshold >= 0),
    
    -- Delivery Estimates
    estimated_delivery_days_min INTEGER CHECK (estimated_delivery_days_min > 0),
    estimated_delivery_days_max INTEGER CHECK (estimated_delivery_days_max >= estimated_delivery_days_min),
    
    -- Service Options
    service_name TEXT, -- 'Standard', 'Express', 'Economy'
    tracking_available BOOLEAN DEFAULT TRUE,
    signature_required BOOLEAN DEFAULT FALSE,
    
    -- System Fields
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT shipping_rules_country_codes_format 
        CHECK (from_country_code ~ '^[A-Z]{2}$' AND to_country_code ~ '^[A-Z]{2}$'),
    CONSTRAINT shipping_rules_unique_rule 
        UNIQUE (company_id, from_country_code, to_country_code, service_name)
);

-- Default Shipping Rules Table
-- Fallback rules when company-specific rules don't exist
CREATE TABLE IF NOT EXISTS public.default_shipping_rules (
    id SERIAL PRIMARY KEY,
    from_country_code TEXT NOT NULL CHECK (LENGTH(from_country_code) = 2),
    to_country_code TEXT NOT NULL CHECK (LENGTH(to_country_code) = 2),
    to_region TEXT,
    shipping_cost DECIMAL(10,2) NOT NULL CHECK (shipping_cost >= 0),
    estimated_delivery_days_min INTEGER,
    estimated_delivery_days_max INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_companies_country_code ON public.companies(country_code);
CREATE INDEX IF NOT EXISTS idx_companies_is_active ON public.companies(is_active);
CREATE INDEX IF NOT EXISTS idx_companies_is_verified ON public.companies(is_verified);

CREATE INDEX IF NOT EXISTS idx_hikes_company_id ON public.hikes(company_id);

CREATE INDEX IF NOT EXISTS idx_shipping_rules_company_id ON public.company_shipping_rules(company_id);
CREATE INDEX IF NOT EXISTS idx_shipping_rules_countries ON public.company_shipping_rules(from_country_code, to_country_code);
CREATE INDEX IF NOT EXISTS idx_shipping_rules_active ON public.company_shipping_rules(is_active);

CREATE INDEX IF NOT EXISTS idx_default_shipping_countries ON public.default_shipping_rules(from_country_code, to_country_code);

-- Updated timestamp triggers
CREATE TRIGGER update_companies_updated_at 
    BEFORE UPDATE ON public.companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_company_shipping_rules_updated_at 
    BEFORE UPDATE ON public.company_shipping_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies

-- Enable RLS on all new tables
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_shipping_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.default_shipping_rules ENABLE ROW LEVEL SECURITY;

-- Companies Policies
CREATE POLICY "Anyone can view active companies" ON public.companies
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Service role can manage all companies" ON public.companies
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Company Shipping Rules Policies  
CREATE POLICY "Anyone can view active shipping rules" ON public.company_shipping_rules
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Service role can manage all shipping rules" ON public.company_shipping_rules
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Default Shipping Rules Policies
CREATE POLICY "Anyone can view default shipping rules" ON public.default_shipping_rules
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Service role can manage default shipping rules" ON public.default_shipping_rules
    FOR ALL USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Business Logic Functions

-- Function to calculate shipping cost for a company and destination
CREATE OR REPLACE FUNCTION calculate_company_shipping_cost(
    p_company_id UUID,
    p_destination_country_code TEXT,
    p_order_value DECIMAL DEFAULT 0
) RETURNS TABLE (
    shipping_cost DECIMAL(10,2),
    is_free_shipping BOOLEAN,
    estimated_days_min INTEGER,
    estimated_days_max INTEGER,
    service_name TEXT
) AS $$
DECLARE
    company_country TEXT;
    rule_record RECORD;
BEGIN
    -- Get company's country
    SELECT country_code INTO company_country 
    FROM public.companies 
    WHERE id = p_company_id AND is_active = TRUE;
    
    IF company_country IS NULL THEN
        RAISE EXCEPTION 'Company not found or not active: %', p_company_id;
    END IF;
    
    -- Look for company-specific shipping rule
    SELECT 
        csr.shipping_cost,
        csr.free_shipping_threshold,
        csr.estimated_delivery_days_min,
        csr.estimated_delivery_days_max,
        csr.service_name
    INTO rule_record
    FROM public.company_shipping_rules csr
    WHERE csr.company_id = p_company_id
        AND csr.from_country_code = company_country
        AND csr.to_country_code = p_destination_country_code
        AND csr.is_active = TRUE
    ORDER BY csr.service_name -- Prefer 'Standard' if multiple exist
    LIMIT 1;
    
    -- Fallback to default shipping rules if no company rule exists
    IF rule_record IS NULL THEN
        SELECT 
            dsr.shipping_cost,
            NULL as free_shipping_threshold,
            dsr.estimated_delivery_days_min,
            dsr.estimated_delivery_days_max,
            'Standard' as service_name
        INTO rule_record
        FROM public.default_shipping_rules dsr
        WHERE dsr.from_country_code = company_country
            AND dsr.to_country_code = p_destination_country_code
            AND dsr.is_active = TRUE
        LIMIT 1;
    END IF;
    
    -- If still no rule found, return default high cost
    IF rule_record IS NULL THEN
        shipping_cost := 25.00;
        is_free_shipping := FALSE;
        estimated_days_min := 7;
        estimated_days_max := 14;
        service_name := 'Standard';
        RETURN NEXT;
        RETURN;
    END IF;
    
    -- Check if free shipping applies
    IF rule_record.free_shipping_threshold IS NOT NULL 
       AND p_order_value >= rule_record.free_shipping_threshold THEN
        shipping_cost := 0.00;
        is_free_shipping := TRUE;
    ELSE
        shipping_cost := rule_record.shipping_cost;
        is_free_shipping := FALSE;
    END IF;
    
    estimated_days_min := rule_record.estimated_delivery_days_min;
    estimated_days_max := rule_record.estimated_delivery_days_max;
    service_name := rule_record.service_name;
    
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comments for Documentation
COMMENT ON TABLE public.companies IS 'Multi-vendor companies that create and sell hiking experiences';
COMMENT ON TABLE public.company_shipping_rules IS 'Company-specific shipping costs and rules per destination';
COMMENT ON TABLE public.default_shipping_rules IS 'Fallback shipping rules when company rules do not exist';

COMMENT ON FUNCTION calculate_company_shipping_cost IS 'Calculates shipping cost for a company to destination country, including free shipping logic';

COMMENT ON COLUMN public.companies.country_code IS 'ISO 3166-1 alpha-2 country code where company is based';
COMMENT ON COLUMN public.companies.is_verified IS 'Whether company has been verified by admin (affects visibility)';
COMMENT ON COLUMN public.company_shipping_rules.free_shipping_threshold IS 'Order value above which shipping becomes free';
COMMENT ON COLUMN public.company_shipping_rules.to_region IS 'Optional region grouping (EU, WORLDWIDE, etc.)';