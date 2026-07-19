-- =============================================================================
-- Supabase Vault setup for the Stripe secrets used by the Edge Functions.
--
-- Ported verbatim-in-behaviour from the removed `terraform-supabase/sql/
-- 08_supabase_vault_setup.sql` so that the migration tree stays the single
-- schema authority (ADR-0003). `get_stripe_config()` is called at runtime by
-- `supabase/functions/create-payment-intent/index.ts`; `test_vault_secrets()`
-- is a manual smoke check from the SQL editor (its former caller,
-- check_vault_status.sh, was removed with the Terraform tree in #81).
--
-- Not ported: the `public.vault_access_audit` table and its `audit_vault_access`
-- trigger function. The trigger was never attached to anything (the original
-- file says so in a comment) and nothing reads the table.
--
-- This migration is idempotent and may be re-applied.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

COMMENT ON EXTENSION "supabase_vault" IS
    'Secure secrets storage with authenticated encryption';

-- Stores the Stripe API keys in the Vault. Called once during setup, never
-- from the app. Test keys are mandatory, live keys optional.
CREATE OR REPLACE FUNCTION public.setup_stripe_secrets(
    p_stripe_publishable_key_test TEXT,
    p_stripe_secret_key_test TEXT,
    p_stripe_webhook_secret_test TEXT,
    p_stripe_publishable_key_live TEXT DEFAULT NULL,
    p_stripe_secret_key_live TEXT DEFAULT NULL,
    p_stripe_webhook_secret_live TEXT DEFAULT NULL,
    p_environment TEXT DEFAULT 'dev'
) RETURNS JSON AS $$
DECLARE
    result JSON;
    test_pub_id UUID;
    test_secret_id UUID;
    test_webhook_id UUID;
    live_pub_id UUID;
    live_secret_id UUID;
    live_webhook_id UUID;
BEGIN
    IF p_stripe_publishable_key_test IS NULL
       OR LENGTH(p_stripe_publishable_key_test) < 10 THEN
        RAISE EXCEPTION
            'Test publishable key is required and must be properly formatted';
    END IF;

    IF p_stripe_secret_key_test IS NULL
       OR LENGTH(p_stripe_secret_key_test) < 10 THEN
        RAISE EXCEPTION
            'Test secret key is required and must be properly formatted';
    END IF;

    IF p_stripe_webhook_secret_test IS NULL
       OR LENGTH(p_stripe_webhook_secret_test) < 10 THEN
        RAISE EXCEPTION
            'Test webhook secret is required and must be properly formatted';
    END IF;

    SELECT vault.create_secret(
        p_stripe_publishable_key_test,
        'stripe_publishable_key_test',
        'Stripe publishable key for test environment - Multi-Vendor System'
    ) INTO test_pub_id;

    SELECT vault.create_secret(
        p_stripe_secret_key_test,
        'stripe_secret_key_test',
        'Stripe secret key for test environment - Multi-Vendor System'
    ) INTO test_secret_id;

    SELECT vault.create_secret(
        p_stripe_webhook_secret_test,
        'stripe_webhook_secret_test',
        'Stripe webhook endpoint secret for test environment'
    ) INTO test_webhook_id;

    IF p_stripe_publishable_key_live IS NOT NULL
       AND LENGTH(p_stripe_publishable_key_live) > 10 THEN
        SELECT vault.create_secret(
            p_stripe_publishable_key_live,
            'stripe_publishable_key_live',
            'Stripe publishable key for live environment - Multi-Vendor System'
        ) INTO live_pub_id;
    END IF;

    IF p_stripe_secret_key_live IS NOT NULL
       AND LENGTH(p_stripe_secret_key_live) > 10 THEN
        SELECT vault.create_secret(
            p_stripe_secret_key_live,
            'stripe_secret_key_live',
            'Stripe secret key for live environment - Multi-Vendor System'
        ) INTO live_secret_id;
    END IF;

    IF p_stripe_webhook_secret_live IS NOT NULL
       AND LENGTH(p_stripe_webhook_secret_live) > 10 THEN
        SELECT vault.create_secret(
            p_stripe_webhook_secret_live,
            'stripe_webhook_secret_live',
            'Stripe webhook endpoint secret for live environment'
        ) INTO live_webhook_id;
    END IF;

    result := json_build_object(
        'success', true,
        'environment', p_environment,
        'secrets_created', json_build_object(
            'test_secrets', json_build_object(
                'publishable_key', test_pub_id IS NOT NULL,
                'secret_key', test_secret_id IS NOT NULL,
                'webhook_secret', test_webhook_id IS NOT NULL
            ),
            'live_secrets', json_build_object(
                'publishable_key', live_pub_id IS NOT NULL,
                'secret_key', live_secret_id IS NOT NULL,
                'webhook_secret', live_webhook_id IS NOT NULL
            )
        ),
        'timestamp', NOW()
    );

    RAISE NOTICE
        'Stripe secrets successfully stored in Vault for environment: %',
        p_environment;

    RETURN result;

EXCEPTION
    WHEN OTHERS THEN
        -- Never surface the key material in the error.
        RAISE EXCEPTION 'Failed to setup Stripe secrets in Vault: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Read side used by the Edge Functions (service_role only).
CREATE OR REPLACE FUNCTION public.get_stripe_config(
    p_environment TEXT DEFAULT 'test'
) RETURNS JSON AS $$
DECLARE
    stripe_config JSON;
    publishable_key TEXT;
    secret_key TEXT;
    webhook_secret TEXT;
BEGIN
    IF p_environment NOT IN ('test', 'live') THEN
        RAISE EXCEPTION 'Environment must be either "test" or "live"';
    END IF;

    SELECT decrypted_secret INTO publishable_key
    FROM vault.decrypted_secrets
    WHERE name = CONCAT('stripe_publishable_key_', p_environment);

    SELECT decrypted_secret INTO secret_key
    FROM vault.decrypted_secrets
    WHERE name = CONCAT('stripe_secret_key_', p_environment);

    SELECT decrypted_secret INTO webhook_secret
    FROM vault.decrypted_secrets
    WHERE name = CONCAT('stripe_webhook_secret_', p_environment);

    IF publishable_key IS NULL THEN
        RAISE EXCEPTION
            'Stripe publishable key not found for environment: %', p_environment;
    END IF;

    IF secret_key IS NULL THEN
        RAISE EXCEPTION
            'Stripe secret key not found for environment: %', p_environment;
    END IF;

    IF webhook_secret IS NULL THEN
        RAISE EXCEPTION
            'Stripe webhook secret not found for environment: %', p_environment;
    END IF;

    stripe_config := json_build_object(
        'publishable_key', publishable_key,
        'secret_key', secret_key,
        'webhook_secret', webhook_secret,
        'environment', p_environment,
        'api_version', '2023-10-16'
    );

    RETURN stripe_config;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to retrieve Stripe configuration: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Connectivity probe. Counts secrets, never returns them.
CREATE OR REPLACE FUNCTION public.test_vault_secrets()
RETURNS JSON AS $$
DECLARE
    test_secrets_count INTEGER;
    live_secrets_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO test_secrets_count
    FROM vault.secrets
    WHERE name LIKE 'stripe_%_test';

    SELECT COUNT(*) INTO live_secrets_count
    FROM vault.secrets
    WHERE name LIKE 'stripe_%_live';

    RETURN json_build_object(
        'vault_available', TRUE,
        'test_secrets_count', test_secrets_count,
        'live_secrets_count', live_secrets_count,
        'expected_test_secrets', 3,
        'test_environment_ready', test_secrets_count >= 3,
        'live_environment_ready', live_secrets_count >= 3,
        'timestamp', NOW()
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'vault_available', FALSE,
            'error', 'Failed to access vault',
            'timestamp', NOW()
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE ALL ON FUNCTION public.setup_stripe_secrets FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_stripe_config FROM PUBLIC;
REVOKE ALL ON FUNCTION public.test_vault_secrets FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.get_stripe_config TO service_role;
GRANT EXECUTE ON FUNCTION public.test_vault_secrets TO service_role;
GRANT EXECUTE ON FUNCTION public.setup_stripe_secrets TO postgres;

COMMENT ON FUNCTION public.setup_stripe_secrets IS
    'Securely stores Stripe API keys in Supabase Vault - called during setup';
COMMENT ON FUNCTION public.get_stripe_config IS
    'Retrieves Stripe configuration for Edge Functions - service role only';
COMMENT ON FUNCTION public.test_vault_secrets IS
    'Tests vault connectivity and counts stored secrets';
