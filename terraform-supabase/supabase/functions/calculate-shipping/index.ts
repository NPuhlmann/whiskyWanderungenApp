// Edge Function: calculate-shipping
// Berechnet Versandkosten basierend auf Company und Lieferadresse
// Multi-Vendor Whisky Hikes System

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Types für bessere TypeScript-Unterstützung
interface DeliveryAddress {
  firstName: string;
  lastName: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  postalCode: string;
  countryCode: string; // ISO 3166-1 alpha-2
  countryName: string;
  state?: string;
}

interface ShippingCalculationRequest {
  companyId: string;
  deliveryAddress: DeliveryAddress;
  orderValue: number;
  hikeId?: number; // Optional für zusätzlichen Kontext
}

interface ShippingRule {
  id: number;
  company_id: string;
  from_country_code: string;
  to_country_code: string;
  to_region?: string;
  shipping_cost: number;
  free_shipping_threshold?: number;
  estimated_delivery_days_min?: number;
  estimated_delivery_days_max?: number;
  service_name: string;
  tracking_available: boolean;
  signature_required: boolean;
}

interface Company {
  id: string;
  name: string;
  country_code: string;
  country_name: string;
  city: string;
  is_active: boolean;
  is_verified: boolean;
}

interface ShippingResult {
  cost: number;
  isFreeShipping: boolean;
  serviceName: string;
  estimatedDaysMin?: number;
  estimatedDaysMax?: number;
  region?: string;
  description: string;
  trackingAvailable: boolean;
  signatureRequired: boolean;
  companyInfo: {
    name: string;
    country: string;
    city: string;
  };
}

// CORS Headers für Frontend-Zugriff
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // CORS Preflight Request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Nur POST-Requests erlauben
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { 
          status: 405, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Request Body parsen
    const requestBody: ShippingCalculationRequest = await req.json()

    // Input Validation
    const validation = validateRequest(requestBody)
    if (!validation.isValid) {
      return new Response(
        JSON.stringify({ error: validation.error }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Supabase Client initialisieren
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    // Company-Daten abrufen
    const { data: company, error: companyError } = await supabase
      .from('companies')
      .select('*')
      .eq('id', requestBody.companyId)
      .eq('is_active', true)
      .single()

    if (companyError || !company) {
      console.error('Company not found:', companyError)
      return new Response(
        JSON.stringify({ error: 'Company not found or inactive' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Versandkosten berechnen
    const shippingResult = await calculateShipping(
      supabase,
      company,
      requestBody.deliveryAddress,
      requestBody.orderValue
    )

    // Erfolgreiche Response
    return new Response(
      JSON.stringify({
        success: true,
        result: shippingResult,
        requestInfo: {
          companyId: requestBody.companyId,
          fromCountry: company.country_code,
          toCountry: requestBody.deliveryAddress.countryCode,
          orderValue: requestBody.orderValue,
          timestamp: new Date().toISOString(),
        }
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Shipping calculation error:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error during shipping calculation',
        details: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

/**
 * Validiert die Eingabedaten für die Shipping-Berechnung
 */
function validateRequest(request: any): { isValid: boolean; error?: string } {
  if (!request) {
    return { isValid: false, error: 'Request body is required' }
  }

  if (!request.companyId || typeof request.companyId !== 'string') {
    return { isValid: false, error: 'companyId is required and must be a string' }
  }

  if (!request.deliveryAddress || typeof request.deliveryAddress !== 'object') {
    return { isValid: false, error: 'deliveryAddress is required and must be an object' }
  }

  const addr = request.deliveryAddress
  const requiredFields = ['firstName', 'lastName', 'addressLine1', 'city', 'postalCode', 'countryCode', 'countryName']
  
  for (const field of requiredFields) {
    if (!addr[field] || typeof addr[field] !== 'string' || addr[field].trim() === '') {
      return { isValid: false, error: `deliveryAddress.${field} is required` }
    }
  }

  // Ländercode-Format validieren
  if (!/^[A-Z]{2}$/.test(addr.countryCode)) {
    return { isValid: false, error: 'deliveryAddress.countryCode must be a valid ISO 3166-1 alpha-2 code' }
  }

  if (typeof request.orderValue !== 'number' || request.orderValue <= 0) {
    return { isValid: false, error: 'orderValue is required and must be a positive number' }
  }

  return { isValid: true }
}

/**
 * Berechnet die Versandkosten basierend auf Company und Lieferadresse
 */
async function calculateShipping(
  supabase: any,
  company: Company,
  deliveryAddress: DeliveryAddress,
  orderValue: number
): Promise<ShippingResult> {
  
  const fromCountry = company.country_code
  const toCountry = deliveryAddress.countryCode

  // 1. Suche company-spezifische Versandregeln
  const { data: companyRules, error: companyRulesError } = await supabase
    .from('company_shipping_rules')
    .select('*')
    .eq('company_id', company.id)
    .eq('from_country_code', fromCountry)
    .eq('to_country_code', toCountry)
    .eq('is_active', true)
    .order('service_name')
    .limit(1)

  let shippingRule: ShippingRule | null = null

  if (companyRulesError) {
    console.warn('Error fetching company shipping rules:', companyRulesError)
  } else if (companyRules && companyRules.length > 0) {
    shippingRule = companyRules[0]
    console.log('Using company-specific shipping rule:', shippingRule)
  }

  // 2. Fallback auf Default-Regeln wenn keine Company-Regel existiert
  if (!shippingRule) {
    const { data: defaultRules, error: defaultRulesError } = await supabase
      .from('default_shipping_rules')
      .select('*')
      .eq('from_country_code', fromCountry)
      .eq('to_country_code', toCountry)
      .eq('is_active', true)
      .limit(1)

    if (!defaultRulesError && defaultRules && defaultRules.length > 0) {
      const defaultRule = defaultRules[0]
      shippingRule = {
        id: defaultRule.id,
        company_id: company.id,
        from_country_code: defaultRule.from_country_code,
        to_country_code: defaultRule.to_country_code,
        to_region: defaultRule.to_region,
        shipping_cost: defaultRule.shipping_cost,
        free_shipping_threshold: null, // Default rules don't have free shipping
        estimated_delivery_days_min: defaultRule.estimated_delivery_days_min,
        estimated_delivery_days_max: defaultRule.estimated_delivery_days_max,
        service_name: 'Standard',
        tracking_available: true,
        signature_required: false,
      }
      console.log('Using default shipping rule:', shippingRule)
    }
  }

  // 3. Fallback auf generische International-Regel
  if (!shippingRule) {
    console.log('No specific rule found, using fallback international shipping')
    
    // Einfache Logik für Fallback-Preise
    let fallbackCost = 25.0 // International default
    let estimatedDays = { min: 10, max: 21 }

    if (fromCountry === toCountry) {
      fallbackCost = 5.0 // Domestic
      estimatedDays = { min: 1, max: 3 }
    } else if (isDACHRegion(fromCountry) && isDACHRegion(toCountry)) {
      fallbackCost = 8.0 // DACH
      estimatedDays = { min: 2, max: 5 }
    } else if (isEURegion(fromCountry) && isEURegion(toCountry)) {
      fallbackCost = 12.0 // EU
      estimatedDays = { min: 4, max: 8 }
    }

    shippingRule = {
      id: 0,
      company_id: company.id,
      from_country_code: fromCountry,
      to_country_code: toCountry,
      to_region: 'INTERNATIONAL',
      shipping_cost: fallbackCost,
      free_shipping_threshold: null,
      estimated_delivery_days_min: estimatedDays.min,
      estimated_delivery_days_max: estimatedDays.max,
      service_name: 'Standard',
      tracking_available: true,
      signature_required: false,
    }
  }

  // 4. Berechne finale Kosten (inkl. Free Shipping)
  let finalCost = shippingRule.shipping_cost
  let isFreeShipping = false

  if (shippingRule.free_shipping_threshold && 
      orderValue >= shippingRule.free_shipping_threshold) {
    finalCost = 0
    isFreeShipping = true
  }

  // 5. Beschreibung generieren
  const description = generateShippingDescription(
    shippingRule,
    isFreeShipping,
    company,
    deliveryAddress
  )

  // 6. Result zusammenstellen
  const result: ShippingResult = {
    cost: finalCost,
    isFreeShipping,
    serviceName: shippingRule.service_name,
    estimatedDaysMin: shippingRule.estimated_delivery_days_min,
    estimatedDaysMax: shippingRule.estimated_delivery_days_max,
    region: shippingRule.to_region,
    description,
    trackingAvailable: shippingRule.tracking_available,
    signatureRequired: shippingRule.signature_required,
    companyInfo: {
      name: company.name,
      country: company.country_name,
      city: company.city,
    }
  }

  return result
}

/**
 * Generiert eine benutzerfreundliche Beschreibung der Versandkosten
 */
function generateShippingDescription(
  rule: ShippingRule,
  isFreeShipping: boolean,
  company: Company,
  deliveryAddress: DeliveryAddress
): string {
  const parts: string[] = []

  // Kosten
  if (isFreeShipping) {
    parts.push('Kostenloser Versand')
  } else {
    parts.push(`${rule.shipping_cost.toFixed(2)} € Versandkosten`)
  }

  // Lieferzeit
  if (rule.estimated_delivery_days_min && rule.estimated_delivery_days_max) {
    if (rule.estimated_delivery_days_min === rule.estimated_delivery_days_max) {
      parts.push(`${rule.estimated_delivery_days_min} Werktage`)
    } else {
      parts.push(`${rule.estimated_delivery_days_min}-${rule.estimated_delivery_days_max} Werktage`)
    }
  }

  // Service-Features
  const features: string[] = []
  if (rule.tracking_available) {
    features.push('Sendungsverfolgung')
  }
  if (rule.signature_required) {
    features.push('Unterschrift erforderlich')
  }
  
  if (features.length > 0) {
    parts.push(`inkl. ${features.join(' + ')}`)
  }

  // Versandweg
  parts.push(`von ${company.city}, ${company.country_name} nach ${deliveryAddress.city}, ${deliveryAddress.countryName}`)

  return parts.join(' • ')
}

/**
 * Prüft ob ein Land zur DACH-Region gehört
 */
function isDACHRegion(countryCode: string): boolean {
  return ['DE', 'AT', 'CH'].includes(countryCode)
}

/**
 * Prüft ob ein Land zur EU gehört
 */
function isEURegion(countryCode: string): boolean {
  const euCountries = [
    'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR',
    'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
    'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE'
  ]
  return euCountries.includes(countryCode)
}

// Deno Deploy konfiguration
console.log("🚚 Shipping Calculation Edge Function is ready!")
console.log("📦 Multi-Vendor system with international shipping support")