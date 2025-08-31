-- Aktualisiere die Hike-Images mit den hochgeladenen Sample Images
-- Dieses Skript wird nach dem Upload der Sample Images ausgeführt

-- Lösche zuerst alle bestehenden Beispiel-Images
DELETE FROM public.hike_images 
WHERE hike_id IN (
    SELECT id FROM public.hikes 
    WHERE name IN (
        'Whisky Trail Highlands',
        'Speyside Whisky Experience',
        'Islay Coastal Adventure',
        'Lowlands Whisky Discovery',
        'Campbeltown Heritage Trail',
        'Glenfiddich Explorer',
        'Talisker Skye Journey',
        'Aberlour Riverside Walk'
    )
);

-- Aktualisiere die Thumbnail-Images der Wanderungen
UPDATE public.hikes 
SET thumbnail_image_url = CASE 
    WHEN name = 'Whisky Trail Highlands' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/whisky-trail-highlands_gemini-generated-image-yaq3ziyaq3ziyaq3.jpg'
    WHEN name = 'Speyside Whisky Experience' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/speyside-whisky-experience_gemini-generated-image-ex7ftxex7ftxex7f.jpg'
    WHEN name = 'Islay Coastal Adventure' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/islay-coastal-adventure_gemini-generated-image-r5m0bhr5m0bhr5m0.jpg'
    WHEN name = 'Lowlands Whisky Discovery' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/lowlands-whisky-discovery_gemini-generated-image-9iyguy9iyguy9iyg.jpg'
    WHEN name = 'Campbeltown Heritage Trail' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/campbeltown-heritage-trail_gemini-generated-image-phnbd9phnbd9phnb.jpg'
    WHEN name = 'Glenfiddich Explorer' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/glenfiddich-explorer_gemini-generated-image-6ljw7t6ljw7t6ljw.jpg'
    WHEN name = 'Talisker Skye Journey' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/talisker-skye-journey_gemini-generated-image-6up7hw6up7hw6up7.jpg'
    WHEN name = 'Aberlour Riverside Walk' THEN 
        'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/aberlour-riverside-walk_gemini-generated-image-x83xx5x83xx5x83x.jpg'
    ELSE thumbnail_image_url
END
WHERE name IN (
    'Whisky Trail Highlands',
    'Speyside Whisky Experience',
    'Islay Coastal Adventure',
    'Lowlands Whisky Discovery',
    'Campbeltown Heritage Trail',
    'Glenfiddich Explorer',
    'Talisker Skye Journey',
    'Aberlour Riverside Walk'
);

-- Füge die neuen Sample Images hinzu
INSERT INTO public.hike_images (hike_id, image_url) VALUES
-- Whisky Trail Highlands (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Whisky Trail Highlands'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/whisky-trail-highlands_gemini-generated-image-yaq3ziyaq3ziyaq3.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Whisky Trail Highlands'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/whisky-trail-highlands_gemini-generated-image-ex7ftxex7ftxex7f.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Whisky Trail Highlands'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/whisky-trail-highlands_gemini-generated-image-r5m0bhr5m0bhr5m0.jpg'),

-- Speyside Whisky Experience (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Speyside Whisky Experience'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/speyside-whisky-experience_gemini-generated-image-9iyguy9iyguy9iyg.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Speyside Whisky Experience'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/speyside-whisky-experience_gemini-generated-image-phnbd9phnbd9phnb.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Speyside Whisky Experience'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/speyside-whisky-experience_gemini-generated-image-6ljw7t6ljw7t6ljw.jpg'),

-- Islay Coastal Adventure (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Islay Coastal Adventure'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/islay-coastal-adventure_gemini-generated-image-6up7hw6up7hw6up7.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Islay Coastal Adventure'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/islay-coastal-adventure_gemini-generated-image-x83xx5x83xx5x83x.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Islay Coastal Adventure'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/islay-coastal-adventure_gemini-generated-image-w671avw671avw671.jpg'),

-- Lowlands Whisky Discovery (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Lowlands Whisky Discovery'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/lowlands-whisky-discovery_gemini-generated-image-fkvh8rfkvh8rfkvh.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Lowlands Whisky Discovery'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/lowlands-whisky-discovery_gemini-generated-image-yaq3ziyaq3ziyaq3.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Lowlands Whisky Discovery'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/lowlands-whisky-discovery_gemini-generated-image-ex7ftxex7ftxex7f.jpg'),

-- Campbeltown Heritage Trail (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Campbeltown Heritage Trail'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/campbeltown-heritage-trail_gemini-generated-image-r5m0bhr5m0bhr5m0.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Campbeltown Heritage Trail'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/campbeltown-heritage-trail_gemini-generated-image-9iyguy9iyguy9iyg.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Campbeltown Heritage Trail'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/campbeltown-heritage-trail_gemini-generated-image-phnbd9phnbd9phnb.jpg'),

-- Glenfiddich Explorer (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Glenfiddich Explorer'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/glenfiddich-explorer_gemini-generated-image-6ljw7t6ljw7t6ljw.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Glenfiddich Explorer'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/glenfiddich-explorer_gemini-generated-image-6up7hw6up7hw6up7.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Glenfiddich Explorer'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/glenfiddich-explorer_gemini-generated-image-x83xx5x83xx5x83x.jpg'),

-- Talisker Skye Journey (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Talisker Skye Journey'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/talisker-skye-journey_gemini-generated-image-w671avw671avw671.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Talisker Skye Journey'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/talisker-skye-journey_gemini-generated-image-fkvh8rfkvh8rfkvh.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Talisker Skye Journey'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/talisker-skye-journey_gemini-generated-image-yaq3ziyaq3ziyaq3.jpg'),

-- Aberlour Riverside Walk (3-4 Bilder)
((SELECT id FROM public.hikes WHERE name = 'Aberlour Riverside Walk'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/aberlour-riverside-walk_gemini-generated-image-ex7ftxex7ftxex7f.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Aberlour Riverside Walk'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/aberlour-riverside-walk_gemini-generated-image-r5m0bhr5m0bhr5m0.jpg'),
((SELECT id FROM public.hikes WHERE name = 'Aberlour Riverside Walk'), 'https://' || current_setting('app.settings.supabase_url') || '/storage/v1/object/public/hike-images/aberlour-riverside-walk_gemini-generated-image-9iyguy9iyguy9iyg.jpg');

-- Zeige Zusammenfassung
SELECT 
    h.name as hike_name,
    COUNT(hi.id) as image_count,
    h.thumbnail_image_url
FROM public.hikes h
LEFT JOIN public.hike_images hi ON h.id = hi.hike_id
WHERE h.name IN (
    'Whisky Trail Highlands',
    'Speyside Whisky Experience',
    'Islay Coastal Adventure',
    'Lowlands Whisky Discovery',
    'Campbeltown Heritage Trail',
    'Glenfiddich Explorer',
    'Talisker Skye Journey',
    'Aberlour Riverside Walk'
)
GROUP BY h.id, h.name, h.thumbnail_image_url
ORDER BY h.name;
