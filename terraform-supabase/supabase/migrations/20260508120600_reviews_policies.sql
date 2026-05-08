-- RLS Policies für die Reviews Tabelle
-- Sicherheitsrichtlinien für den Zugriff auf Bewertungen

-- Policy: Jeder kann alle Reviews lesen (für öffentliche Anzeige)
CREATE POLICY "Reviews sind öffentlich lesbar" ON public.reviews
    FOR SELECT TO authenticated
    USING (true);

-- Policy: Nur authentifizierte Nutzer können Reviews erstellen
CREATE POLICY "Authentifizierte Nutzer können Reviews erstellen" ON public.reviews
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Policy: Nutzer können nur ihre eigenen Reviews bearbeiten
CREATE POLICY "Nutzer können nur eigene Reviews bearbeiten" ON public.reviews
    FOR UPDATE TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Nutzer können nur ihre eigenen Reviews löschen
CREATE POLICY "Nutzer können nur eigene Reviews löschen" ON public.reviews
    FOR DELETE TO authenticated
    USING (auth.uid() = user_id);

-- Policy für Service Role (Backend-API Zugriff)
-- Ermöglicht vollständigen Zugriff für Backend-Operationen
CREATE POLICY "Service role hat vollen Zugriff" ON public.reviews
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Kommentare zur Dokumentation
COMMENT ON POLICY "Reviews sind öffentlich lesbar" ON public.reviews IS 'Alle authentifizierten Nutzer können Reviews lesen';
COMMENT ON POLICY "Authentifizierte Nutzer können Reviews erstellen" ON public.reviews IS 'Nur angemeldete Nutzer können neue Reviews erstellen';
COMMENT ON POLICY "Nutzer können nur eigene Reviews bearbeiten" ON public.reviews IS 'Reviews können nur vom Ersteller bearbeitet werden';
COMMENT ON POLICY "Nutzer können nur eigene Reviews löschen" ON public.reviews IS 'Reviews können nur vom Ersteller gelöscht werden';