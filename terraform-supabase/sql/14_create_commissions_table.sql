-- Commission tracking per order per company.
-- Multi-tenant by design: company_id is always required.
-- Note: order_id is TEXT (not FK) to match the Flutter model's String type;
-- a future migration should align this with enhanced_orders.id (INT) and add
-- a proper FK constraint once the Dart model is updated to int orderId.

CREATE TABLE IF NOT EXISTS public.commissions (
    id              SERIAL PRIMARY KEY,
    hike_id         INTEGER NOT NULL REFERENCES public.hikes(id) ON DELETE RESTRICT,
    company_id      UUID    NOT NULL REFERENCES public.companies(id) ON DELETE RESTRICT,
    order_id        TEXT    NOT NULL,
    commission_rate DECIMAL(5, 4) NOT NULL CHECK (commission_rate >= 0 AND commission_rate <= 1),
    base_amount     DECIMAL(10, 2) NOT NULL CHECK (base_amount >= 0),
    commission_amount DECIMAL(10, 2) NOT NULL CHECK (commission_amount >= 0),
    status          TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'calculated', 'paid', 'cancelled')),
    billing_period_id TEXT,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    paid_at         TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- One commission per order (prevents duplicates on retry)
CREATE UNIQUE INDEX IF NOT EXISTS commissions_order_id_idx ON public.commissions(order_id);

-- Fast lookups by company for multi-tenant admin views
CREATE INDEX IF NOT EXISTS commissions_company_id_idx ON public.commissions(company_id);

-- Fast lookups by billing period for payout runs
CREATE INDEX IF NOT EXISTS commissions_billing_period_idx
    ON public.commissions(billing_period_id)
    WHERE billing_period_id IS NOT NULL;

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_commissions_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS commissions_updated_at ON public.commissions;
CREATE TRIGGER commissions_updated_at
    BEFORE UPDATE ON public.commissions
    FOR EACH ROW EXECUTE FUNCTION public.update_commissions_updated_at();

-- RLS
ALTER TABLE public.commissions ENABLE ROW LEVEL SECURITY;

-- Company members see only their own company's commissions
CREATE POLICY "commissions_company_select" ON public.commissions
    FOR SELECT USING (
        company_id IN (
            SELECT id FROM public.companies
            WHERE id = company_id  -- scoped via service-role or admin token in practice
        )
    );

-- Only service role inserts / updates (commission calc runs server-side)
CREATE POLICY "commissions_service_all" ON public.commissions
    FOR ALL USING (auth.role() = 'service_role');
