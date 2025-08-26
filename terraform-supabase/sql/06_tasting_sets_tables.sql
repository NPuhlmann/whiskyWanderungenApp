-- Tasting Sets table (1:1 relationship with hikes)
CREATE TABLE IF NOT EXISTS public.tasting_sets (
    id SERIAL PRIMARY KEY,
    hike_id INTEGER UNIQUE REFERENCES public.hikes(id) ON DELETE CASCADE, -- UNIQUE constraint for 1:1 relationship
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- Default 0 since it's included in hike price
    image_url TEXT,
    is_included BOOLEAN DEFAULT TRUE, -- Always true since it's part of the hike
    is_available BOOLEAN DEFAULT TRUE,
    available_from TIMESTAMP WITH TIME ZONE,
    available_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Whisky Samples table
CREATE TABLE IF NOT EXISTS public.whisky_samples (
    id SERIAL PRIMARY KEY,
    tasting_set_id INTEGER REFERENCES public.tasting_sets(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    distillery TEXT NOT NULL,
    age INTEGER,
    region TEXT,
    tasting_notes TEXT,
    image_url TEXT,
    abv DECIMAL(4,2),
    category TEXT,
    sample_size_ml DECIMAL(5,2) DEFAULT 5.0,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Remove the order_tasting_sets table since it's no longer needed
-- (tasting sets are automatically included with hikes)

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_tasting_sets_hike_id ON public.tasting_sets(hike_id);
CREATE INDEX IF NOT EXISTS idx_tasting_sets_available ON public.tasting_sets(is_available, available_from, available_until);
CREATE INDEX IF NOT EXISTS idx_whisky_samples_tasting_set_id ON public.whisky_samples(tasting_set_id);
CREATE INDEX IF NOT EXISTS idx_whisky_samples_order ON public.whisky_samples(tasting_set_id, order_index);

-- RLS Policies
ALTER TABLE public.tasting_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whisky_samples ENABLE ROW LEVEL SECURITY;

-- Public read access for tasting sets and samples
CREATE POLICY "Anyone can view tasting sets" ON public.tasting_sets FOR SELECT USING (true);
CREATE POLICY "Anyone can view whisky samples" ON public.whisky_samples FOR SELECT USING (true);

-- Companies can manage tasting sets for their hikes
CREATE POLICY "Companies can manage tasting sets for their hikes" ON public.tasting_sets
    USING (
        EXISTS (
            SELECT 1 FROM public.hikes 
            WHERE id = tasting_sets.hike_id AND company_id = auth.uid()
        )
    );

-- Companies can manage whisky samples for their tasting sets
CREATE POLICY "Companies can manage whisky samples for their tasting sets" ON public.whisky_samples
    USING (
        EXISTS (
            SELECT 1 FROM public.tasting_sets ts
            JOIN public.hikes h ON ts.hike_id = h.id
            WHERE ts.id = whisky_samples.tasting_set_id AND h.company_id = auth.uid()
        )
    );

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tasting_sets_updated_at 
    BEFORE UPDATE ON public.tasting_sets 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data for testing (1:1 relationship)
INSERT INTO public.tasting_sets (hike_id, name, description, price, image_url, is_included, is_available) VALUES
(1, 'Highland Collection', 'Eine Auswahl der besten Highland Whiskys', 0.00, 'https://example.com/highland-collection.jpg', true, true),
(2, 'Islay Peat Experience', 'Rauchige Islay Whiskys für Kenner', 0.00, 'https://example.com/islay-peat.jpg', true, true),
(3, 'Speyside Classics', 'Die klassischen Speyside Whiskys', 0.00, 'https://example.com/speyside-classics.jpg', true, true);

INSERT INTO public.whisky_samples (tasting_set_id, name, distillery, age, region, tasting_notes, image_url, abv, category, sample_size_ml, order_index) VALUES
(1, 'Highland Park 12', 'Highland Park', 12, 'Highland', 'Honig, Vanille, leichte Rauchnoten', 'https://example.com/highland-park-12.jpg', 43.0, 'Single Malt', 5.0, 0),
(1, 'Glenmorangie 10', 'Glenmorangie', 10, 'Highland', 'Zitrus, Vanille, Mandeln', 'https://example.com/glenmorangie-10.jpg', 40.0, 'Single Malt', 5.0, 1),
(2, 'Laphroaig 10', 'Laphroaig', 10, 'Islay', 'Starker Torfrauch, Jod, Medizin', 'https://example.com/laphroaig-10.jpg', 43.0, 'Single Malt', 5.0, 0),
(2, 'Ardbeg 10', 'Ardbeg', 10, 'Islay', 'Intensiver Torfrauch, Pfeffer, Zitrone', 'https://example.com/ardbeg-10.jpg', 46.0, 'Single Malt', 5.0, 1),
(3, 'Glenfiddich 12', 'Glenfiddich', 12, 'Speyside', 'Birne, Apfel, leichte Eichennoten', 'https://example.com/glenfiddich-12.jpg', 40.0, 'Single Malt', 5.0, 0),
(3, 'The Macallan 12', 'The Macallan', 12, 'Speyside', 'Sherry, Schokolade, getrocknete Früchte', 'https://example.com/macallan-12.jpg', 43.0, 'Single Malt', 5.0, 1);
