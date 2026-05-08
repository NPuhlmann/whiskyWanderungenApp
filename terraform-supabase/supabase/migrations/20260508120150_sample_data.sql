-- Beispieldaten für die Whisky Hikes App

-- Sample Hikes (Wanderungen)
INSERT INTO public.hikes (name, length, steep, elevation, description, price, difficulty, thumbnail_image_url) VALUES
('Whisky Trail Highlands', 12.5, 0.15, 450, 'Eine malerische Wanderung durch die schottischen Highlands mit Besuch traditioneller Whisky-Destillerien. Genießen Sie atemberaubende Ausblicke und lernen Sie die Kunst der Whisky-Herstellung kennen.', 29.99, 'mid', 'https://example.com/images/highlands-trail.jpg'),
('Speyside Whisky Experience', 8.2, 0.08, 280, 'Entdecken Sie die berühmte Speyside-Region mit ihren weltbekannten Whisky-Destillerien. Diese gemütliche Wanderung ist perfekt für Whisky-Enthusiasten.', 24.99, 'easy', 'https://example.com/images/speyside-trail.jpg'),
('Islay Coastal Adventure', 15.8, 0.25, 620, 'Eine anspruchsvolle Küstenwanderung auf der Isle of Islay. Besuchen Sie rauchige Whisky-Destillerien und genießen Sie die raue Schönheit der Atlantikküste.', 39.99, 'hard', 'https://example.com/images/islay-coastal.jpg'),
('Lowlands Whisky Discovery', 6.5, 0.05, 150, 'Eine entspannte Wanderung durch die sanften Lowlands. Perfekt für Anfänger und Familien, die die milderen Whisky-Sorten entdecken möchten.', 19.99, 'easy', 'https://example.com/images/lowlands-discovery.jpg'),
('Campbeltown Heritage Trail', 10.3, 0.18, 380, 'Erkunden Sie die historische Whisky-Stadt Campbeltown. Diese Wanderung verbindet Geschichte, Kultur und erstklassige Whisky-Destillerien.', 34.99, 'mid', 'https://example.com/images/campbeltown-heritage.jpg'),
('Glenfiddich Explorer', 13.7, 0.22, 520, 'Eine abenteuerliche Wanderung durch das Glenfiddich-Tal. Besuchen Sie eine der berühmtesten Whisky-Destillerien der Welt.', 44.99, 'hard', 'https://example.com/images/glenfiddich-explorer.jpg'),
('Talisker Skye Journey', 18.2, 0.35, 780, 'Eine epische Wanderung auf der Isle of Skye zur Talisker-Destillerie. Diese anspruchsvolle Route bietet dramatische Landschaften und erstklassigen Whisky.', 54.99, 'very_hard', 'https://example.com/images/talisker-skye.jpg'),
('Aberlour Riverside Walk', 7.8, 0.12, 320, 'Eine malerische Wanderung entlang des Flusses Spey zur Aberlour-Destillerie. Genießen Sie die friedliche Atmosphäre und den sanften Whisky.', 27.99, 'easy', 'https://example.com/images/aberlour-riverside.jpg');

-- Sample Waypoints (Wegpunkte)
INSERT INTO public.waypoints (name, description, latitude, longitude, images) VALUES
-- Whisky Trail Highlands Wegpunkte
('Glenmorangie Distillery', 'Besuchen Sie die berühmte Glenmorangie-Destillerie und lernen Sie die Kunst der Whisky-Herstellung kennen. Genießen Sie eine Führung und Verkostung.', 57.8231, -4.0333, ARRAY['https://example.com/images/glenmorangie-1.jpg', 'https://example.com/images/glenmorangie-2.jpg']),
('Highland Viewpoint', 'Atemberaubender Ausblick über die schottischen Highlands. Perfekter Ort für eine Pause und Fotos.', 57.8500, -4.0500, ARRAY['https://example.com/images/highland-view.jpg']),
('Traditional Pub Stop', 'Historisches Pub mit lokalen Spezialitäten und einer großen Auswahl an Highland-Whiskys.', 57.8400, -4.0400, ARRAY['https://example.com/images/traditional-pub.jpg']),

-- Speyside Whisky Experience Wegpunkte
('Macallan Estate', 'Besuchen Sie das beeindruckende Macallan-Anwesen und erfahren Sie mehr über die Geschichte dieser prestigeträchtigen Destillerie.', 57.4847, -3.2089, ARRAY['https://example.com/images/macallan-estate.jpg']),
('Spey River Bridge', 'Historische Brücke über den Fluss Spey mit wunderschönem Ausblick auf das Tal.', 57.4800, -3.2100, ARRAY['https://example.com/images/spey-bridge.jpg']),
('Whisky Museum', 'Interaktives Museum über die Geschichte und Herstellung von Speyside-Whisky.', 57.4850, -3.2090, ARRAY['https://example.com/images/whisky-museum.jpg']),

-- Islay Coastal Adventure Wegpunkte
('Laphroaig Distillery', 'Besuchen Sie die berühmte Laphroaig-Destillerie und erleben Sie den charakteristischen rauchigen Geschmack.', 55.6300, -6.1500, ARRAY['https://example.com/images/laphroaig-1.jpg', 'https://example.com/images/laphroaig-2.jpg']),
('Coastal Cliff View', 'Dramatischer Ausblick auf die Atlantikküste und die raue Schönheit von Islay.', 55.6400, -6.1600, ARRAY['https://example.com/images/islay-cliffs.jpg']),
('Port Ellen Harbour', 'Historischer Hafen mit traditionellen Fischerbooten und einem gemütlichen Café.', 55.6200, -6.1400, ARRAY['https://example.com/images/port-ellen.jpg']),

-- Lowlands Whisky Discovery Wegpunkte
('Auchentoshan Distillery', 'Besuchen Sie die einzige Destillerie in den Lowlands, die dreifach destilliert. Sanfter, milder Whisky.', 55.9200, -4.4300, ARRAY['https://example.com/images/auchentoshan.jpg']),
('Lowland Meadows', 'Sanfte Wiesen und Felder der Lowlands - perfekt für eine entspannte Pause.', 55.9250, -4.4350, ARRAY['https://example.com/images/lowland-meadows.jpg']),
('Historic Village', 'Charmantes historisches Dorf mit traditioneller Architektur und gemütlichen Cafés.', 55.9180, -4.4280, ARRAY['https://example.com/images/historic-village.jpg']),

-- Campbeltown Heritage Trail Wegpunkte
('Springbank Distillery', 'Besuchen Sie die älteste unabhängige Destillerie Schottlands und erleben Sie traditionelle Handwerkskunst.', 55.4200, -5.6100, ARRAY['https://example.com/images/springbank.jpg']),
('Campbeltown Harbour', 'Historischer Hafen mit Blick auf die Kintyre-Halbinsel und die Inseln.', 55.4250, -5.6150, ARRAY['https://example.com/images/campbeltown-harbour.jpg']),
('Heritage Centre', 'Informationszentrum über die reiche Geschichte von Campbeltown als Whisky-Hauptstadt.', 55.4220, -5.6120, ARRAY['https://example.com/images/heritage-centre.jpg']),

-- Glenfiddich Explorer Wegpunkte
('Glenfiddich Distillery', 'Besuchen Sie die weltberühmte Glenfiddich-Destillerie und erleben Sie die Geschichte dieser ikonischen Marke.', 57.4567, -3.1289, ARRAY['https://example.com/images/glenfiddich-1.jpg', 'https://example.com/images/glenfiddich-2.jpg']),
('Valley Viewpoint', 'Atemberaubender Ausblick über das Glenfiddich-Tal und die umgebenden Berge.', 57.4600, -3.1300, ARRAY['https://example.com/images/valley-viewpoint.jpg']),
('Whisky Warehouse', 'Historisches Lagerhaus mit Tausenden von Whisky-Fässern und der Möglichkeit zur Verkostung.', 57.4580, -3.1290, ARRAY['https://example.com/images/whisky-warehouse.jpg']),

-- Talisker Skye Journey Wegpunkte
('Talisker Distillery', 'Besuchen Sie die einzige Destillerie auf der Isle of Skye und erleben Sie den charakteristischen Meeresgeschmack.', 57.3000, -6.3500, ARRAY['https://example.com/images/talisker-1.jpg', 'https://example.com/images/talisker-2.jpg']),
('Cuillin Mountains View', 'Dramatischer Ausblick auf die Cuillin-Berge und die raue Schönheit von Skye.', 57.3100, -6.3600, ARRAY['https://example.com/images/cuillin-mountains.jpg']),
('Coastal Path', 'Wunderschöner Küstenweg mit Ausblick auf das Meer und die umgebenden Inseln.', 57.3050, -6.3550, ARRAY['https://example.com/images/coastal-path.jpg']),

-- Aberlour Riverside Walk Wegpunkte
('Aberlour Distillery', 'Besuchen Sie die charmante Aberlour-Destillerie und genießen Sie den sanften, fruchtigen Whisky.', 57.4700, -3.2300, ARRAY['https://example.com/images/aberlour-1.jpg']),
('Riverside Picnic Spot', 'Idyllischer Picknickplatz am Ufer des Flusses Spey mit wunderschönem Ausblick.', 57.4750, -3.2350, ARRAY['https://example.com/images/riverside-picnic.jpg']),
('Historic Bridge', 'Historische Steinbrücke über den Fluss Spey mit traditioneller Architektur.', 57.4720, -3.2320, ARRAY['https://example.com/images/historic-bridge.jpg']);

-- Verknüpfungen zwischen Hikes und Waypoints
INSERT INTO public.hikes_waypoints (hike_id, waypoint_id) VALUES
-- Whisky Trail Highlands (Hike ID 1)
(1, 1), (1, 2), (1, 3),
-- Speyside Whisky Experience (Hike ID 2)
(2, 4), (2, 5), (2, 6),
-- Islay Coastal Adventure (Hike ID 3)
(3, 7), (3, 8), (3, 9),
-- Lowlands Whisky Discovery (Hike ID 4)
(4, 10), (4, 11), (4, 12),
-- Campbeltown Heritage Trail (Hike ID 5)
(5, 13), (5, 14), (5, 15),
-- Glenfiddich Explorer (Hike ID 6)
(6, 16), (6, 17), (6, 18),
-- Talisker Skye Journey (Hike ID 7)
(7, 19), (7, 20), (7, 21),
-- Aberlour Riverside Walk (Hike ID 8)
(8, 22), (8, 23), (8, 24);

-- Sample Hike Images
INSERT INTO public.hike_images (hike_id, image_url) VALUES
(1, 'https://example.com/images/highlands-trail-1.jpg'),
(1, 'https://example.com/images/highlands-trail-2.jpg'),
(2, 'https://example.com/images/speyside-trail-1.jpg'),
(2, 'https://example.com/images/speyside-trail-2.jpg'),
(3, 'https://example.com/images/islay-coastal-1.jpg'),
(3, 'https://example.com/images/islay-coastal-2.jpg'),
(4, 'https://example.com/images/lowlands-discovery-1.jpg'),
(5, 'https://example.com/images/campbeltown-heritage-1.jpg'),
(6, 'https://example.com/images/glenfiddich-explorer-1.jpg'),
(6, 'https://example.com/images/glenfiddich-explorer-2.jpg'),
(7, 'https://example.com/images/talisker-skye-1.jpg'),
(7, 'https://example.com/images/talisker-skye-2.jpg'),
(8, 'https://example.com/images/aberlour-riverside-1.jpg'); 