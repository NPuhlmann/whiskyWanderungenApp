// Edge Function: create-payment-intent
// Erstellt Stripe Payment Intent mit Company-Kontext und sicherer Vault-Integration
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
  countryCode: string;
  countryName: string;
  state?: string;
}

interface PaymentIntentRequest {
  companyId: string;
  hikeId: number;
  userId: string;
  deliveryType: 'pickup' | 'standard_shipping' | 'express_shipping' | 'premium_shipping';
  deliveryAddress?: DeliveryAddress;
  orderValue: number; // Basis-Hike-Preis
  shippingCost: number;
  currency?: string; // Default: 'eur'
  metadata?: { [key: string]: string };
}

interface StripeConfig {
  publishable_key: string;
  secret_key: string;
  webhook_secret: string;
  environment: string;
  api_version: string;
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

interface PaymentIntentResult {
  success: boolean;
  paymentIntentId: string;
  clientSecret: string;
  orderNumber: string;
  orderId: number;
  amount: number; // In cents
  currency: string;
  metadata: { [key: string]: string };
  companyInfo: {
    name: string;
    country: string;
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
    const requestBody: PaymentIntentRequest = await req.json()

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

    // Company-Daten abrufen und validieren
    const { data: company, error: companyError } = await supabase
      .from('companies')
      .select('*')
      .eq('id', requestBody.companyId)
      .eq('is_active', true)
      .eq('is_verified', true)
      .single()

    if (companyError || !company) {
      console.error('Company not found or not verified:', companyError)
      return new Response(
        JSON.stringify({ error: 'Company not found, inactive, or not verified' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Hike-Daten validieren
    const { data: hike, error: hikeError } = await supabase
      .from('hikes')
      .select('*')
      .eq('id', requestBody.hikeId)
      .eq('company_id', requestBody.companyId)
      .eq('is_available', true)
      .single()

    if (hikeError || !hike) {
      console.error('Hike not found or not available:', hikeError)
      return new Response(
        JSON.stringify({ error: 'Hike not found, not available, or does not belong to specified company' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Stripe-Konfiguration aus Vault abrufen
    const stripeConfig = await getStripeConfig(supabase)
    
    // Order erstellen
    const orderResult = await createOrder(
      supabase,
      requestBody,
      company,
      hike
    )

    // Payment Intent bei Stripe erstellen
    const paymentIntentResult = await createStripePaymentIntent(
      stripeConfig,
      requestBody,
      orderResult,
      company,
      hike
    )

    // Order mit Payment Intent ID aktualisieren
    await supabase
      .from('orders')
      .update({ payment_intent_id: paymentIntentResult.id })
      .eq('id', orderResult.orderId)

    // Erfolgreiche Response
    return new Response(
      JSON.stringify({
        success: true,
        paymentIntentId: paymentIntentResult.id,
        clientSecret: paymentIntentResult.client_secret,
        orderNumber: orderResult.orderNumber,
        orderId: orderResult.orderId,
        amount: paymentIntentResult.amount,
        currency: paymentIntentResult.currency,
        metadata: paymentIntentResult.metadata,
        companyInfo: {
          name: company.name,
          country: company.country_name,
        },
        requestInfo: {
          timestamp: new Date().toISOString(),
        }
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Payment intent creation error:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error during payment intent creation',
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
 * Validiert die Eingabedaten für Payment Intent Creation
 */
function validateRequest(request: any): { isValid: boolean; error?: string } {
  if (!request) {
    return { isValid: false, error: 'Request body is required' }
  }

  // Required fields validation
  const requiredFields = ['companyId', 'hikeId', 'userId', 'deliveryType', 'orderValue', 'shippingCost']
  
  for (const field of requiredFields) {
    if (request[field] === undefined || request[field] === null) {
      return { isValid: false, error: `${field} is required` }
    }
  }

  // Type validations
  if (typeof request.companyId !== 'string' || request.companyId.trim() === '') {
    return { isValid: false, error: 'companyId must be a non-empty string' }
  }

  if (typeof request.hikeId !== 'number' || request.hikeId <= 0) {
    return { isValid: false, error: 'hikeId must be a positive number' }
  }

  if (typeof request.userId !== 'string' || request.userId.trim() === '') {
    return { isValid: false, error: 'userId must be a non-empty string' }
  }

  const validDeliveryTypes = ['pickup', 'standard_shipping', 'express_shipping', 'premium_shipping']
  if (!validDeliveryTypes.includes(request.deliveryType)) {
    return { isValid: false, error: `deliveryType must be one of: ${validDeliveryTypes.join(', ')}` }
  }

  if (typeof request.orderValue !== 'number' || request.orderValue <= 0) {
    return { isValid: false, error: 'orderValue must be a positive number' }
  }

  if (typeof request.shippingCost !== 'number' || request.shippingCost < 0) {
    return { isValid: false, error: 'shippingCost must be a non-negative number' }
  }

  // Delivery address validation für shipping
  if (request.deliveryType !== 'pickup') {
    if (!request.deliveryAddress || typeof request.deliveryAddress !== 'object') {
      return { isValid: false, error: 'deliveryAddress is required for shipping orders' }
    }

    const addr = request.deliveryAddress
    const requiredAddressFields = ['firstName', 'lastName', 'addressLine1', 'city', 'postalCode', 'countryCode']
    
    for (const field of requiredAddressFields) {
      if (!addr[field] || typeof addr[field] !== 'string' || addr[field].trim() === '') {
        return { isValid: false, error: `deliveryAddress.${field} is required for shipping` }
      }
    }

    if (!/^[A-Z]{2}$/.test(addr.countryCode)) {
      return { isValid: false, error: 'deliveryAddress.countryCode must be a valid ISO 3166-1 alpha-2 code' }
    }
  }

  return { isValid: true }
}

/**
 * Ruft Stripe-Konfiguration aus dem Supabase Vault ab
 */
async function getStripeConfig(supabase: any): Promise<StripeConfig> {
  // Bestimme Environment (Test vs Live) basierend auf ENV Variable
  const environment = Deno.env.get('ENVIRONMENT') || 'test'
  
  try {
    // Rufe Stripe-Konfiguration via RPC-Funktion ab
    const { data, error } = await supabase.rpc('get_stripe_config', {
      p_environment: environment === 'prod' ? 'live' : 'test'
    })

    if (error) {
      console.error('Error fetching Stripe config from vault:', error)
      throw new Error(`Failed to retrieve Stripe configuration: ${error.message}`)
    }

    if (!data || !data.secret_key || !data.publishable_key) {
      throw new Error('Incomplete Stripe configuration retrieved from vault')
    }

    console.log(`✅ Retrieved Stripe config for ${data.environment} environment`)
    
    return data as StripeConfig

  } catch (error) {
    console.error('Vault access error:', error)
    throw new Error(`Vault access failed: ${error.message}`)
  }
}

/**
 * Erstellt eine neue Bestellung in der Datenbank
 */
async function createOrder(
  supabase: any,
  request: PaymentIntentRequest,
  company: Company,
  hike: any
): Promise<{ orderId: number; orderNumber: string }> {
  
  const totalAmount = request.orderValue + request.shippingCost

  // Bestelldaten zusammenstellen
  const orderData = {
    company_id: request.companyId,
    user_id: request.userId,
    hike_id: request.hikeId,
    total_amount: totalAmount,
    delivery_type: request.deliveryType,
    status: 'pending',
    delivery_address: request.deliveryAddress ? JSON.stringify(request.deliveryAddress) : null,
  }

  // Bestellung erstellen
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .insert([orderData])
    .select()
    .single()

  if (orderError) {
    console.error('Error creating order:', orderError)
    throw new Error(`Failed to create order: ${orderError.message}`)
  }

  // Order Items erstellen
  const orderItemData = {
    order_id: order.id,
    hike_id: request.hikeId,
    quantity: 1,
    unit_price: request.orderValue,
    total_price: request.orderValue,
  }

  const { error: orderItemError } = await supabase
    .from('order_items')
    .insert([orderItemData])

  if (orderItemError) {
    console.error('Error creating order item:', orderItemError)
    // Rollback: Bestellung löschen
    await supabase.from('orders').delete().eq('id', order.id)
    throw new Error(`Failed to create order item: ${orderItemError.message}`)
  }

  console.log(`✅ Order created: ${order.order_number} (ID: ${order.id})`)

  return {
    orderId: order.id,
    orderNumber: order.order_number,
  }
}

/**
 * Erstellt Payment Intent bei Stripe
 */
async function createStripePaymentIntent(
  stripeConfig: StripeConfig,
  request: PaymentIntentRequest,
  orderResult: { orderId: number; orderNumber: string },
  company: Company,
  hike: any
): Promise<any> {
  
  const currency = request.currency || 'eur'
  const totalAmount = request.orderValue + request.shippingCost
  const amountInCents = Math.round(totalAmount * 100)

  // Metadata für Stripe
  const metadata = {
    // Order Information
    order_id: orderResult.orderId.toString(),
    order_number: orderResult.orderNumber,
    
    // Multi-Vendor Context
    company_id: request.companyId,
    company_name: company.name,
    company_country: company.country_code,
    
    // Product Information
    hike_id: request.hikeId.toString(),
    hike_name: hike.name,
    
    // User Information
    user_id: request.userId,
    
    // Delivery Information
    delivery_type: request.deliveryType,
    delivery_country: request.deliveryAddress?.countryCode || 'PICKUP',
    
    // Pricing Breakdown
    base_amount: (request.orderValue * 100).toString(), // in cents
    shipping_cost: (request.shippingCost * 100).toString(), // in cents
    
    // System Information
    created_via: 'edge_function',
    system: 'whisky_hikes_multi_vendor',
    
    // Additional metadata from request
    ...request.metadata,
  }

  // Stripe API Request
  const stripeResponse = await fetch('https://api.stripe.com/v1/payment_intents', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${stripeConfig.secret_key}`,
      'Content-Type': 'application/x-www-form-urlencoded',
      'Stripe-Version': stripeConfig.api_version,
    },
    body: new URLSearchParams({
      amount: amountInCents.toString(),
      currency: currency,
      'automatic_payment_methods[enabled]': 'true',
      description: `Whisky Hike: ${hike.name} by ${company.name}`,
      ...Object.entries(metadata).reduce((acc, [key, value]) => {
        acc[`metadata[${key}]`] = value
        return acc
      }, {} as any),
    }),
  })

  if (!stripeResponse.ok) {
    const errorText = await stripeResponse.text()
    console.error('Stripe API error:', errorText)
    throw new Error(`Stripe payment intent creation failed: ${stripeResponse.status} ${errorText}`)
  }

  const paymentIntent = await stripeResponse.json()
  
  console.log(`✅ Stripe Payment Intent created: ${paymentIntent.id}`)
  
  return paymentIntent
}

// Deno Deploy Konfiguration
console.log("💳 Payment Intent Creation Edge Function is ready!")
console.log("🔐 With secure Supabase Vault integration for Stripe secrets")
console.log("🏢 Multi-Vendor support with company context")