-- Sample Companies and Shipping Rules Data
-- For testing the Multi-Vendor Whisky Hikes system

-- Sample Companies from different countries
INSERT INTO public.companies (
    name, 
    description, 
    contact_email, 
    phone,
    country_code, 
    country_name, 
    city, 
    postal_code,
    address_line_1,
    is_active,
    is_verified
) VALUES 
-- German Company
(
    'Bavarian Whisky Trails', 
    'Premium whisky hiking experiences in the Bavarian Alps',
    'info@bavarian-whisky-trails.de',
    '+49 89 12345678',
    'DE', 
    'Germany', 
    'Munich', 
    '80331',
    'Marienplatz 1',
    TRUE,
    TRUE
),
-- Australian Company  
(
    'Outback Whisky Adventures',
    'Unique whisky tasting experiences in the Australian wilderness',
    'hello@outback-whisky.com.au',
    '+61 2 9876 5432',
    'AU',
    'Australia', 
    'Sydney',
    '2000',
    '123 Harbour Bridge Road',
    TRUE,
    TRUE
),
-- Scottish Company
(
    'Highland Spirit Tours',
    'Authentic Scottish whisky distillery hikes through the Highlands',
    'bookings@highland-spirit.co.uk',
    '+44 1234 567890',
    'GB',
    'United Kingdom',
    'Edinburgh',
    'EH1 1YZ',
    '45 Royal Mile',
    TRUE,
    TRUE
),
-- US Company
(
    'American Whiskey Trails',
    'Bourbon and rye whiskey experiences across American landscapes',
    'tours@american-whiskey-trails.com',
    '+1 555 123 4567',
    'US',
    'United States',
    'Louisville',
    '40202',
    '123 Bourbon Street',
    TRUE,
    TRUE
);

-- Sample Company Shipping Rules
-- German Company Shipping Rules
INSERT INTO public.company_shipping_rules (
    company_id,
    from_country_code,
    to_country_code,
    to_region,
    shipping_cost,
    free_shipping_threshold,
    estimated_delivery_days_min,
    estimated_delivery_days_max,
    service_name,
    is_active
) VALUES
-- Bavarian Whisky Trails (German company)
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'DE', 'DOMESTIC', 4.90, 50.00, 1, 3, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'AT', 'DACH', 7.90, 75.00, 2, 4, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'CH', 'DACH', 9.90, 75.00, 3, 5, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'FR', 'EU', 8.90, 60.00, 3, 5, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'IT', 'EU', 9.90, 60.00, 4, 6, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'ES', 'EU', 10.90, 60.00, 4, 7, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'NL', 'EU', 7.90, 60.00, 2, 4, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'GB', 'EUROPE', 12.90, 80.00, 5, 8, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'US', 'INTERNATIONAL', 19.90, 100.00, 7, 14, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'), 'DE', 'AU', 'INTERNATIONAL', 24.90, 120.00, 10, 21, 'Standard', TRUE),

-- Australian Company Shipping Rules  
((SELECT id FROM public.companies WHERE name = 'Outback Whisky Adventures'), 'AU', 'AU', 'DOMESTIC', 8.50, 75.00, 2, 5, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Outback Whisky Adventures'), 'AU', 'NZ', 'OCEANIA', 12.90, 100.00, 3, 7, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Outback Whisky Adventures'), 'AU', 'US', 'INTERNATIONAL', 22.90, 150.00, 7, 14, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Outback Whisky Adventures'), 'AU', 'GB', 'INTERNATIONAL', 25.90, 150.00, 8, 16, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Outback Whisky Adventures'), 'AU', 'DE', 'INTERNATIONAL', 27.90, 150.00, 9, 18, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Outback Whisky Adventures'), 'AU', 'FR', 'INTERNATIONAL', 26.90, 150.00, 9, 18, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Outback Whisky Adventures'), 'AU', 'JP', 'ASIA', 19.90, 120.00, 5, 10, 'Standard', TRUE),

-- Scottish Company Shipping Rules
((SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours'), 'GB', 'GB', 'DOMESTIC', 5.50, 40.00, 1, 3, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours'), 'GB', 'IE', 'IRELAND', 8.90, 50.00, 2, 4, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours'), 'GB', 'DE', 'EU', 11.90, 70.00, 4, 7, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours'), 'GB', 'FR', 'EU', 10.90, 70.00, 3, 6, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours'), 'GB', 'IT', 'EU', 12.90, 70.00, 4, 8, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours'), 'GB', 'US', 'INTERNATIONAL', 18.90, 90.00, 6, 12, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours'), 'GB', 'AU', 'INTERNATIONAL', 23.90, 120.00, 8, 16, 'Standard', TRUE),

-- US Company Shipping Rules
((SELECT id FROM public.companies WHERE name = 'American Whiskey Trails'), 'US', 'US', 'DOMESTIC', 6.99, 50.00, 2, 5, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'American Whiskey Trails'), 'US', 'CA', 'NORTH_AMERICA', 12.99, 75.00, 5, 10, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'American Whiskey Trails'), 'US', 'GB', 'INTERNATIONAL', 19.99, 100.00, 7, 14, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'American Whiskey Trails'), 'US', 'DE', 'INTERNATIONAL', 21.99, 100.00, 8, 15, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'American Whiskey Trails'), 'US', 'AU', 'INTERNATIONAL', 24.99, 120.00, 10, 18, 'Standard', TRUE),
((SELECT id FROM public.companies WHERE name = 'American Whiskey Trails'), 'US', 'JP', 'ASIA', 18.99, 90.00, 6, 12, 'Standard', TRUE);

-- Default/Fallback Shipping Rules for countries not covered above
INSERT INTO public.default_shipping_rules (
    from_country_code,
    to_country_code,
    to_region,
    shipping_cost,
    estimated_delivery_days_min,
    estimated_delivery_days_max,
    is_active
) VALUES
-- European defaults
('DE', 'PT', 'EU', 11.90, 4, 8, TRUE),
('DE', 'SE', 'EU', 9.90, 3, 6, TRUE),
('DE', 'DK', 'EU', 8.90, 2, 5, TRUE),
('DE', 'NO', 'EUROPE', 13.90, 4, 7, TRUE),

-- Global defaults (expensive fallbacks)
('*', '*', 'WORLDWIDE', 29.90, 10, 21, TRUE);

-- Update existing hikes to have company associations (for testing)
-- This assumes you have some sample hikes already in the system
UPDATE public.hikes 
SET company_id = (SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails' LIMIT 1)
WHERE company_id IS NULL 
    AND id IN (
        SELECT id FROM public.hikes 
        WHERE company_id IS NULL 
        LIMIT 2
    );

UPDATE public.hikes 
SET company_id = (SELECT id FROM public.companies WHERE name = 'Highland Spirit Tours' LIMIT 1)
WHERE company_id IS NULL 
    AND id IN (
        SELECT id FROM public.hikes 
        WHERE company_id IS NULL 
        LIMIT 1
    );

-- Comments
COMMENT ON TABLE public.companies IS 'Sample companies: German, Australian, Scottish, and American whisky tour providers';
COMMENT ON TABLE public.company_shipping_rules IS 'Realistic shipping costs based on actual international shipping rates';

-- Test the shipping calculation function
-- Example: Calculate shipping from German company to Australia
SELECT * FROM calculate_company_shipping_cost(
    (SELECT id FROM public.companies WHERE name = 'Bavarian Whisky Trails'),
    'AU',
    45.00 -- Order value of 45 EUR
);