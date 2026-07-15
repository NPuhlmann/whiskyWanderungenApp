-- =============================================================================
-- Curated demo content for the Whisky Hikes catalogue.
--
-- This migration is idempotent. It creates five clearly identifiable demo hikes,
-- each with three images, four ordered waypoints, one included tasting set and
-- four whisky samples. Image files are uploaded before applying this migration.
-- =============================================================================

DO $$
DECLARE
    storage_url TEXT := 'https://qpijqelnwqozuohucapx.supabase.co/storage/v1/object/public/hike-images/demo';
    hike_schwarzwald INTEGER;
    hike_mosel INTEGER;
    hike_harz INTEGER;
    hike_allgaeu INTEGER;
    hike_ruegen INTEGER;
    set_schwarzwald INTEGER;
    set_mosel INTEGER;
    set_harz INTEGER;
    set_allgaeu INTEGER;
    set_ruegen INTEGER;
BEGIN
    INSERT INTO public.hikes (
        name, length, steep, elevation, description, price, difficulty,
        thumbnail_image_url
    ) VALUES
        (
            '[Demo] Schwarzwald Fasspfad', 11.8, 0.12, 410,
            'Ein stiller Rundweg durch dunkle Tannenwälder und über Granitrücken bei Baden-Baden. Vier Stationen führen von fruchtigen Malts zu würzigen Fassnoten.',
            34.90, 'mid', storage_url || '/schwarzwald-fasspfad-01.jpg'
        ),
        (
            '[Demo] Mosel Schieferweg', 9.4, 0.10, 290,
            'Ein aussichtsreicher Weinbergpfad oberhalb der Mosel. Schiefer, Flusswind und goldene Reben schaffen den passenden Rahmen für elegante, fruchtige Whiskys.',
            29.90, 'easy', storage_url || '/mosel-schieferweg-01.jpg'
        ),
        (
            '[Demo] Harz Hexenstieg', 16.2, 0.19, 690,
            'Eine anspruchsvolle Etappe über Moorstege, Felsen und windige Höhen zum Brocken. Kräftige, rauchige Abfüllungen begleiten die vier Wegpunkte.',
            44.90, 'hard', storage_url || '/harz-hexenstieg-01.jpg'
        ),
        (
            '[Demo] Allgaeu Alpenglut', 13.6, 0.16, 760,
            'Vom Bergsee über blühende Almwiesen bis zur Aussicht auf die Kalkalpen. Die Tour verbindet sportliche Höhenmeter mit hellen, cremigen Single Malts.',
            39.90, 'hard', storage_url || '/allgaeu-alpenglut-01.jpg'
        ),
        (
            '[Demo] Ruegen Kuestenmalz', 10.7, 0.07, 160,
            'Ein entspannter Küstenpfad zwischen Buchenwald, Kreidefelsen und Ostseestrand. Maritime Noten und milde Malts stehen im Mittelpunkt.',
            31.90, 'easy', storage_url || '/ruegen-kuestenmalz-01.jpg'
        )
    ON CONFLICT DO NOTHING;

    SELECT id INTO hike_schwarzwald
      FROM public.hikes WHERE name = '[Demo] Schwarzwald Fasspfad';
    SELECT id INTO hike_mosel
      FROM public.hikes WHERE name = '[Demo] Mosel Schieferweg';
    SELECT id INTO hike_harz
      FROM public.hikes WHERE name = '[Demo] Harz Hexenstieg';
    SELECT id INTO hike_allgaeu
      FROM public.hikes WHERE name = '[Demo] Allgaeu Alpenglut';
    SELECT id INTO hike_ruegen
      FROM public.hikes WHERE name = '[Demo] Ruegen Kuestenmalz';

    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_schwarzwald, storage_url || '/schwarzwald-fasspfad-01.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_schwarzwald
          AND image_url = storage_url || '/schwarzwald-fasspfad-01.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_schwarzwald, storage_url || '/schwarzwald-fasspfad-02.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_schwarzwald
          AND image_url = storage_url || '/schwarzwald-fasspfad-02.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_schwarzwald, storage_url || '/schwarzwald-fasspfad-03.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_schwarzwald
          AND image_url = storage_url || '/schwarzwald-fasspfad-03.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_mosel, storage_url || '/mosel-schieferweg-01.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_mosel
          AND image_url = storage_url || '/mosel-schieferweg-01.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_mosel, storage_url || '/mosel-schieferweg-02.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_mosel
          AND image_url = storage_url || '/mosel-schieferweg-02.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_mosel, storage_url || '/mosel-schieferweg-03.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_mosel
          AND image_url = storage_url || '/mosel-schieferweg-03.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_harz, storage_url || '/harz-hexenstieg-01.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_harz
          AND image_url = storage_url || '/harz-hexenstieg-01.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_harz, storage_url || '/harz-hexenstieg-02.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_harz
          AND image_url = storage_url || '/harz-hexenstieg-02.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_harz, storage_url || '/harz-hexenstieg-03.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_harz
          AND image_url = storage_url || '/harz-hexenstieg-03.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_allgaeu, storage_url || '/allgaeu-alpenglut-01.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_allgaeu
          AND image_url = storage_url || '/allgaeu-alpenglut-01.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_allgaeu, storage_url || '/allgaeu-alpenglut-02.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_allgaeu
          AND image_url = storage_url || '/allgaeu-alpenglut-02.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_allgaeu, storage_url || '/allgaeu-alpenglut-03.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_allgaeu
          AND image_url = storage_url || '/allgaeu-alpenglut-03.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_ruegen, storage_url || '/ruegen-kuestenmalz-01.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_ruegen
          AND image_url = storage_url || '/ruegen-kuestenmalz-01.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_ruegen, storage_url || '/ruegen-kuestenmalz-02.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_ruegen
          AND image_url = storage_url || '/ruegen-kuestenmalz-02.jpg'
    );
    INSERT INTO public.hike_images (hike_id, image_url)
    SELECT hike_ruegen, storage_url || '/ruegen-kuestenmalz-03.jpg'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.hike_images
        WHERE hike_id = hike_ruegen
          AND image_url = storage_url || '/ruegen-kuestenmalz-03.jpg'
    );

    INSERT INTO public.waypoints (name, description, latitude, longitude)
    VALUES
        ('[Demo] Geroldsauer Wasserfall', 'Start am Wasserfall. Frische, florale Noten eröffnen die Schwarzwald-Tour.', 48.7315, 8.2735),
        ('[Demo] Ebersteinburg Aussicht', 'Weitblick über das Tal. Zeit für die zweite Probe und eine kurze Pause.', 48.7622, 8.2574),
        ('[Demo] Battertfelsen', 'Granitfelsen und dichte Tannen markieren den kräftigsten Dram der Runde.', 48.7807, 8.2398),
        ('[Demo] Merkur Bergstation', 'Finale auf dem Baden-Badener Hausberg mit Blick bis in die Rheinebene.', 48.7735, 8.2448),
        ('[Demo] Piesporter Goldtroepfchen', 'Start zwischen steilen Reben und warmen Schieferterrassen.', 49.8871, 6.9178),
        ('[Demo] Mosel Panorama', 'Offene Aussicht auf die Flussschleife und die Weinorte im Tal.', 49.8919, 6.9306),
        ('[Demo] Neumagener Hafen', 'Rast am Wasser. Der Flusswind passt zur fruchtigen dritten Probe.', 49.8564, 6.8964),
        ('[Demo] Schieferkanzel', 'Abschluss auf einer kleinen Kanzel über den Weinbergen.', 49.8739, 6.9065),
        ('[Demo] Torfhaus Moorsteg', 'Der Einstieg führt über Holzstege durch eine offene Moorlandschaft.', 51.8044, 10.5348),
        ('[Demo] Eckersprung Quelle', 'Klares Quellwasser und Granitfelsen bieten eine geschuetzte Rast.', 51.7886, 10.5092),
        ('[Demo] Brockenblick', 'Windige Hoehe mit weitem Blick zum Brockenmassiv.', 51.7898, 10.5543),
        ('[Demo] Goetheweg Schutzhuette', 'Letzte Station mit Blick auf die Baumgrenze und die Rueckroute.', 51.8016, 10.5661),
        ('[Demo] Oberstdorfer Bergsee', 'Klarer Bergsee als ruhiger Auftakt der alpinen Runde.', 47.4083, 10.2793),
        ('[Demo] Gaisalpe', 'Almwiesen und Kalksteinfelsen rahmen die zweite Verkostung.', 47.4187, 10.3032),
        ('[Demo] Nebelhornblick', 'Hoechster Punkt der Tour mit Blick ueber die Allgaeuer Gipfel.', 47.4325, 10.3198),
        ('[Demo] Alpenhutte Einkehr', 'Warme Einkehr am Ende der Tour, ideal fuer den abschliessenden Malt.', 47.4154, 10.2937),
        ('[Demo] Koenigsstuhl Kreidefelsen', 'Start oberhalb der hellen Kreidefelsen mit freiem Blick auf die Ostsee.', 54.5649, 13.6644),
        ('[Demo] Victoria Sicht', 'Waldpfad und Kreidekueste treffen an einem stillen Aussichtspunkt aufeinander.', 54.5531, 13.6609),
        ('[Demo] Wissower Ufer', 'Kuestenlicht und Buchenwald begleiten die maritime dritte Probe.', 54.5476, 13.6473),
        ('[Demo] Sassnitz Hafenblick', 'Finale mit Blick auf Hafen, Meer und die Rueckfahrt.', 54.5156, 13.6437)
    ON CONFLICT DO NOTHING;

    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_schwarzwald, id, 0 FROM public.waypoints WHERE name = '[Demo] Geroldsauer Wasserfall'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_schwarzwald, id, 1 FROM public.waypoints WHERE name = '[Demo] Ebersteinburg Aussicht'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_schwarzwald, id, 2 FROM public.waypoints WHERE name = '[Demo] Battertfelsen'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_schwarzwald, id, 3 FROM public.waypoints WHERE name = '[Demo] Merkur Bergstation'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_mosel, id, 0 FROM public.waypoints WHERE name = '[Demo] Piesporter Goldtroepfchen'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_mosel, id, 1 FROM public.waypoints WHERE name = '[Demo] Mosel Panorama'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_mosel, id, 2 FROM public.waypoints WHERE name = '[Demo] Neumagener Hafen'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_mosel, id, 3 FROM public.waypoints WHERE name = '[Demo] Schieferkanzel'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_harz, id, 0 FROM public.waypoints WHERE name = '[Demo] Torfhaus Moorsteg'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_harz, id, 1 FROM public.waypoints WHERE name = '[Demo] Eckersprung Quelle'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_harz, id, 2 FROM public.waypoints WHERE name = '[Demo] Brockenblick'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_harz, id, 3 FROM public.waypoints WHERE name = '[Demo] Goetheweg Schutzhuette'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_allgaeu, id, 0 FROM public.waypoints WHERE name = '[Demo] Oberstdorfer Bergsee'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_allgaeu, id, 1 FROM public.waypoints WHERE name = '[Demo] Gaisalpe'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_allgaeu, id, 2 FROM public.waypoints WHERE name = '[Demo] Nebelhornblick'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_allgaeu, id, 3 FROM public.waypoints WHERE name = '[Demo] Alpenhutte Einkehr'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_ruegen, id, 0 FROM public.waypoints WHERE name = '[Demo] Koenigsstuhl Kreidefelsen'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_ruegen, id, 1 FROM public.waypoints WHERE name = '[Demo] Victoria Sicht'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_ruegen, id, 2 FROM public.waypoints WHERE name = '[Demo] Wissower Ufer'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;
    INSERT INTO public.hikes_waypoints (hike_id, waypoint_id, order_index)
    SELECT hike_ruegen, id, 3 FROM public.waypoints WHERE name = '[Demo] Sassnitz Hafenblick'
    ON CONFLICT (hike_id, waypoint_id) DO UPDATE SET order_index = EXCLUDED.order_index;

    INSERT INTO public.tasting_sets (
        hike_id, name, description, price, image_url, is_included, is_available
    ) VALUES
        (hike_schwarzwald, '[Demo] Schwarzwald Fassauswahl', 'Vier fruchtig-wuerzige Single Malts fuer den Waldpfad.', 0.00, storage_url || '/schwarzwald-fasspfad-03.jpg', TRUE, TRUE),
        (hike_mosel, '[Demo] Mosel Frucht & Schiefer', 'Vier elegante Whiskys mit Frucht, Honig und dezenter Wuerze.', 0.00, storage_url || '/mosel-schieferweg-03.jpg', TRUE, TRUE),
        (hike_harz, '[Demo] Harz Rauch & Moor', 'Vier charakterstarke Malts mit Rauch, Salz und dunkler Frucht.', 0.00, storage_url || '/harz-hexenstieg-03.jpg', TRUE, TRUE),
        (hike_allgaeu, '[Demo] Allgaeu Alpenmalz', 'Vier helle und cremige Single Malts fuer die alpine Etappe.', 0.00, storage_url || '/allgaeu-alpenglut-01.jpg', TRUE, TRUE),
        (hike_ruegen, '[Demo] Ruegen Kuestenmalz', 'Vier maritime Whiskys mit Zitrus, Salz und sanfter Eiche.', 0.00, storage_url || '/ruegen-kuestenmalz-01.jpg', TRUE, TRUE)
    ON CONFLICT (hike_id) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        image_url = EXCLUDED.image_url,
        is_included = TRUE,
        is_available = TRUE;

    SELECT id INTO set_schwarzwald FROM public.tasting_sets WHERE hike_id = hike_schwarzwald;
    SELECT id INTO set_mosel FROM public.tasting_sets WHERE hike_id = hike_mosel;
    SELECT id INTO set_harz FROM public.tasting_sets WHERE hike_id = hike_harz;
    SELECT id INTO set_allgaeu FROM public.tasting_sets WHERE hike_id = hike_allgaeu;
    SELECT id INTO set_ruegen FROM public.tasting_sets WHERE hike_id = hike_ruegen;

    DELETE FROM public.whisky_samples
    WHERE tasting_set_id IN (set_schwarzwald, set_mosel, set_harz, set_allgaeu, set_ruegen);

    INSERT INTO public.whisky_samples (
        tasting_set_id, name, distillery, age, region, tasting_notes, image_url,
        abv, category, sample_size_ml, order_index
    ) VALUES
        (set_schwarzwald, 'GlenDronach 12 Original', 'The GlenDronach', 12, 'Highland', 'Kirsche, dunkle Schokolade, Sherry und Walnuss.', storage_url || '/schwarzwald-fasspfad-03.jpg', 43.0, 'Single Malt', 20.0, 0),
        (set_schwarzwald, 'Clynelish 14', 'Clynelish', 14, 'Highland', 'Wachs, Mandarine, Heidekraut und dezente Kuestensalzigkeit.', storage_url || '/schwarzwald-fasspfad-01.jpg', 46.0, 'Single Malt', 20.0, 1),
        (set_schwarzwald, 'Aberlour 12 Double Cask', 'Aberlour', 12, 'Speyside', 'Rote Beeren, Toffee, Zimt und weiche Eiche.', storage_url || '/schwarzwald-fasspfad-02.jpg', 40.0, 'Single Malt', 20.0, 2),
        (set_schwarzwald, 'Balblair 15', 'Balblair', 15, 'Highland', 'Honig, Leder, reife Aprikose und Gewuerznelke.', storage_url || '/schwarzwald-fasspfad-03.jpg', 46.0, 'Single Malt', 20.0, 3),
        (set_mosel, 'Glenfiddich 15 Solera', 'Glenfiddich', 15, 'Speyside', 'Birne, Honig, Marzipan und sanfte Sherrynoten.', storage_url || '/mosel-schieferweg-03.jpg', 40.0, 'Single Malt', 20.0, 0),
        (set_mosel, 'GlenAllachie 12', 'The GlenAllachie', 12, 'Speyside', 'Rosinen, Mokka, Honig und Zimt.', storage_url || '/mosel-schieferweg-01.jpg', 46.0, 'Single Malt', 20.0, 1),
        (set_mosel, 'Arran 10', 'Isle of Arran', 10, 'Islands', 'Zitrus, gruener Apfel, Vanille und helle Eiche.', storage_url || '/mosel-schieferweg-02.jpg', 46.0, 'Single Malt', 20.0, 2),
        (set_mosel, 'Tamdhu 12', 'Tamdhu', 12, 'Speyside', 'Orange, Trockenfruechte, Butterkeks und Sherry.', storage_url || '/mosel-schieferweg-03.jpg', 43.0, 'Single Malt', 20.0, 3),
        (set_harz, 'Ardbeg Uigeadail', 'Ardbeg', 0, 'Islay', 'Torfrauch, Espresso, Rosinen und schwarzer Pfeffer.', storage_url || '/harz-hexenstieg-03.jpg', 54.2, 'Single Malt', 20.0, 0),
        (set_harz, 'Ledaig 10', 'Tobermory', 10, 'Isle of Mull', 'Kuestenrauch, Zitrone, Salz und Pfeffer.', storage_url || '/harz-hexenstieg-01.jpg', 46.3, 'Single Malt', 20.0, 1),
        (set_harz, 'Port Charlotte 10', 'Bruichladdich', 10, 'Islay', 'Rauch, Malzzucker, Zitrone und maritime Mineralik.', storage_url || '/harz-hexenstieg-02.jpg', 50.0, 'Single Malt', 20.0, 2),
        (set_harz, 'Talisker 10', 'Talisker', 10, 'Isle of Skye', 'Pfeffer, Rauch, Apfel und salzige Gischt.', storage_url || '/harz-hexenstieg-03.jpg', 45.8, 'Single Malt', 20.0, 3),
        (set_allgaeu, 'Deanston 12', 'Deanston', 12, 'Highland', 'Honig, Malz, kandierte Frucht und weiche Vanille.', storage_url || '/allgaeu-alpenglut-01.jpg', 46.3, 'Single Malt', 20.0, 0),
        (set_allgaeu, 'Edradour 10', 'Edradour', 10, 'Highland', 'Rahmtoffee, Nuss, Trockenfrucht und Gewuerz.', storage_url || '/allgaeu-alpenglut-02.jpg', 40.0, 'Single Malt', 20.0, 1),
        (set_allgaeu, 'Benromach 10', 'Benromach', 10, 'Speyside', 'Apfel, Schokolade, leichter Rauch und Eiche.', storage_url || '/allgaeu-alpenglut-03.jpg', 43.0, 'Single Malt', 20.0, 2),
        (set_allgaeu, 'Glencadam 10', 'Glencadam', 10, 'Highland', 'Blumig, Pfirsich, Mandeln und sahnige Vanille.', storage_url || '/allgaeu-alpenglut-01.jpg', 46.0, 'Single Malt', 20.0, 3),
        (set_ruegen, 'Old Pulteney 12', 'Old Pulteney', 12, 'Highland', 'Zitrone, Salz, Honig und trockene Eiche.', storage_url || '/ruegen-kuestenmalz-01.jpg', 40.0, 'Single Malt', 20.0, 0),
        (set_ruegen, 'Bunnahabhain 12', 'Bunnahabhain', 12, 'Islay', 'Nuss, Trockenfrucht, Salzkaramell und sanfter Rauch.', storage_url || '/ruegen-kuestenmalz-02.jpg', 46.3, 'Single Malt', 20.0, 1),
        (set_ruegen, 'Oban 14', 'Oban', 14, 'Highland', 'Orange, Meersalz, Honig und leichter Rauch.', storage_url || '/ruegen-kuestenmalz-03.jpg', 43.0, 'Single Malt', 20.0, 2),
        (set_ruegen, 'Scapa Skiren', 'Scapa', 0, 'Orkney', 'Ananas, Birne, Kokos und dezente Meeresbrise.', storage_url || '/ruegen-kuestenmalz-01.jpg', 40.0, 'Single Malt', 20.0, 3);
END $$;
