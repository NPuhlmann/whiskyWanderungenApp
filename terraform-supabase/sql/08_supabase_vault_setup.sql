-- Supabase Vault Setup für Whisky Hikes Multi-Vendor Payment System
-- Sichere Speicherung von Stripe API Keys und anderen sensiblen Daten
-- Dokumentation: https://supabase.com/docs/guides/database/vault

-- Enable the vault extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

-- Kommentare zur Vault-Sicherheit
COMMENT ON EXTENSION "supabase_vault" IS 'Secure secrets storage with authenticated encryption';
COMMENT ON SCHEMA "vault" IS 'Supabase Vault for encrypted secrets storage - restricted access';

-- Create function to safely store Stripe secrets via environment variables
-- This function should be called from Terraform with environment variables
CREATE OR REPLACE FUNCTION setup_stripe_secrets(
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
    -- Validate input parameters
    IF p_stripe_publishable_key_test IS NULL OR LENGTH(p_stripe_publishable_key_test) < 10 THEN
        RAISE EXCEPTION 'Test publishable key is required and must be properly formatted';
    END IF;
    
    IF p_stripe_secret_key_test IS NULL OR LENGTH(p_stripe_secret_key_test) < 10 THEN
        RAISE EXCEPTION 'Test secret key is required and must be properly formatted';
    END IF;
    
    IF p_stripe_webhook_secret_test IS NULL OR LENGTH(p_stripe_webhook_secret_test) < 10 THEN
        RAISE EXCEPTION 'Test webhook secret is required and must be properly formatted';
    END IF;
    
    -- Store test environment secrets
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
    
    -- Store live environment secrets (if provided)
    IF p_stripe_publishable_key_live IS NOT NULL AND LENGTH(p_stripe_publishable_key_live) > 10 THEN
        SELECT vault.create_secret(
            p_stripe_publishable_key_live,
            'stripe_publishable_key_live',
            'Stripe publishable key for live environment - Multi-Vendor System'
        ) INTO live_pub_id;
    END IF;
    
    IF p_stripe_secret_key_live IS NOT NULL AND LENGTH(p_stripe_secret_key_live) > 10 THEN
        SELECT vault.create_secret(
            p_stripe_secret_key_live,
            'stripe_secret_key_live',
            'Stripe secret key for live environment - Multi-Vendor System'  
        ) INTO live_secret_id;
    END IF;
    
    IF p_stripe_webhook_secret_live IS NOT NULL AND LENGTH(p_stripe_webhook_secret_live) > 10 THEN
        SELECT vault.create_secret(
            p_stripe_webhook_secret_live,
            'stripe_webhook_secret_live',
            'Stripe webhook endpoint secret for live environment'
        ) INTO live_webhook_id;
    END IF;
    
    -- Create result summary (no sensitive data)
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
    
    -- Log successful setup (without sensitive data)
    RAISE NOTICE 'Stripe secrets successfully stored in Vault for environment: %', p_environment;
    
    RETURN result;
    
EXCEPTION 
    WHEN OTHERS THEN
        -- Log error without exposing sensitive data
        RAISE EXCEPTION 'Failed to setup Stripe secrets in Vault: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to retrieve Stripe secrets for Edge Functions
-- This should only be called by Edge Functions with proper authentication
CREATE OR REPLACE FUNCTION get_stripe_config(p_environment TEXT DEFAULT 'test')
RETURNS JSON AS $$
DECLARE
    stripe_config JSON;
    publishable_key TEXT;
    secret_key TEXT; 
    webhook_secret TEXT;
BEGIN
    -- Validate environment parameter
    IF p_environment NOT IN ('test', 'live') THEN
        RAISE EXCEPTION 'Environment must be either "test" or "live"';
    END IF;
    
    -- Get secrets from vault based on environment
    SELECT decrypted_secret INTO publishable_key
    FROM vault.decrypted_secrets 
    WHERE name = CONCAT('stripe_publishable_key_', p_environment);
    
    SELECT decrypted_secret INTO secret_key  
    FROM vault.decrypted_secrets
    WHERE name = CONCAT('stripe_secret_key_', p_environment);
    
    SELECT decrypted_secret INTO webhook_secret
    FROM vault.decrypted_secrets 
    WHERE name = CONCAT('stripe_webhook_secret_', p_environment);
    
    -- Validate that secrets exist
    IF publishable_key IS NULL THEN
        RAISE EXCEPTION 'Stripe publishable key not found for environment: %', p_environment;
    END IF;
    
    IF secret_key IS NULL THEN
        RAISE EXCEPTION 'Stripe secret key not found for environment: %', p_environment; 
    END IF;
    
    IF webhook_secret IS NULL THEN
        RAISE EXCEPTION 'Stripe webhook secret not found for environment: %', p_environment;
    END IF;
    
    -- Build configuration object
    stripe_config := json_build_object(
        'publishable_key', publishable_key,
        'secret_key', secret_key,
        'webhook_secret', webhook_secret,
        'environment', p_environment,
        'api_version', '2023-10-16'  -- Stripe API version
    );
    
    RETURN stripe_config;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to retrieve Stripe configuration: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to test vault connectivity (without exposing secrets)
CREATE OR REPLACE FUNCTION test_vault_secrets()
RETURNS JSON AS $$
DECLARE
    test_result JSON;
    test_secrets_count INTEGER;
    live_secrets_count INTEGER;
BEGIN
    -- Count test secrets
    SELECT COUNT(*) INTO test_secrets_count
    FROM vault.secrets 
    WHERE name LIKE 'stripe_%_test';
    
    -- Count live secrets  
    SELECT COUNT(*) INTO live_secrets_count
    FROM vault.secrets
    WHERE name LIKE 'stripe_%_live';
    
    -- Build test result
    test_result := json_build_object(
        'vault_available', TRUE,
        'test_secrets_count', test_secrets_count,
        'live_secrets_count', live_secrets_count,
        'expected_test_secrets', 3, -- publishable_key, secret_key, webhook_secret
        'test_environment_ready', test_secrets_count >= 3,
        'live_environment_ready', live_secrets_count >= 3,
        'timestamp', NOW()
    );
    
    RETURN test_result;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Return error info without sensitive details
        RETURN json_build_object(
            'vault_available', FALSE,
            'error', 'Failed to access vault',
            'timestamp', NOW()
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Security: Revoke public access to vault functions
REVOKE ALL ON FUNCTION setup_stripe_secrets FROM PUBLIC;
REVOKE ALL ON FUNCTION get_stripe_config FROM PUBLIC;
REVOKE ALL ON FUNCTION test_vault_secrets FROM PUBLIC;

-- Grant access only to service role (for Edge Functions)
GRANT EXECUTE ON FUNCTION get_stripe_config TO service_role;
GRANT EXECUTE ON FUNCTION test_vault_secrets TO service_role;

-- Grant setup function to postgres (for initial setup only)
GRANT EXECUTE ON FUNCTION setup_stripe_secrets TO postgres;

-- Create audit table for secret access (optional security feature)
CREATE TABLE IF NOT EXISTS public.vault_access_audit (
    id SERIAL PRIMARY KEY,
    secret_name TEXT NOT NULL,
    accessed_by TEXT, 
    access_type TEXT CHECK (access_type IN ('READ', 'CREATE', 'UPDATE', 'DELETE')),
    client_info JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on audit table
ALTER TABLE public.vault_access_audit ENABLE ROW LEVEL SECURITY;

-- Only service role can read audit logs
CREATE POLICY "Service role can read vault audit" ON public.vault_access_audit
    FOR SELECT USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Audit trigger for secret access (optional)
CREATE OR REPLACE FUNCTION audit_vault_access() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.vault_access_audit (secret_name, access_type, client_info)
    VALUES (
        NEW.name,
        TG_OP,
        json_build_object(
            'user_agent', current_setting('request.headers', true)::json->>'user-agent',
            'ip_address', current_setting('request.headers', true)::json->>'x-forwarded-for'
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply audit trigger to vault.secrets (if permissions allow)
-- Note: This might not work due to RLS restrictions, but included for reference

-- Comments for documentation
COMMENT ON FUNCTION setup_stripe_secrets IS 'Securely stores Stripe API keys in Supabase Vault - called during setup';
COMMENT ON FUNCTION get_stripe_config IS 'Retrieves Stripe configuration for Edge Functions - service role only';  
COMMENT ON FUNCTION test_vault_secrets IS 'Tests vault connectivity and counts stored secrets';
COMMENT ON TABLE public.vault_access_audit IS 'Audit log for vault secret access attempts';

-- Display setup completion message
DO $$
BEGIN
    RAISE NOTICE '🔐 Supabase Vault setup completed successfully!';
    RAISE NOTICE '📋 Next steps:';
    RAISE NOTICE '   1. Call setup_stripe_secrets() with your API keys';
    RAISE NOTICE '   2. Test with test_vault_secrets()';  
    RAISE NOTICE '   3. Edge Functions can use get_stripe_config()';
    RAISE NOTICE '🛡️  All secrets are encrypted at rest with authenticated encryption';
END $$;