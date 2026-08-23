const BASE_URL = (
  import.meta.env.VITE_API_BASE_URL || 'https://escrow-et-backend.vercel.app/api'
).replace(/\/$/, '')

class ApiError extends Error {
  constructor(message, status) {
    super(message)
    this.status = status
  }
}

async function request(path, { token, method = 'GET', body } = {}) {
  const headers = { 'Content-Type': 'application/json', Accept: 'application/json' }
  if (token) headers['Authorization'] = `Token ${token}`

  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  })

  let data = null
  try {
    data = await res.json()
  } catch {
    data = {}
  }

  if (!res.ok) {
    const msg =
      data?.detail ||
      data?.error ||
      Object.values(data || {}).flat().join(' ') ||
      `Request failed (${res.status})`
    throw new ApiError(msg, res.status)
  }

  return data
}

// ── Auth ──────────────────────────────────────────────────────────────────────

export function login(username, password) {
  return request('/auth/login/', { method: 'POST', body: { username, password } })
}

export function loginWithFayda(rawPayload) {
  return request('/auth/login/', { method: 'POST', body: { raw_payload: rawPayload } })
}

export function register({ phoneNumber, role, rawPayload }) {
  return request('/auth/register/', {
    method: 'POST',
    body: { phone_number: phoneNumber, role, raw_payload: rawPayload },
  })
}

export function me(token) {
  return request('/auth/me/', { token })
}

export function updateProfile(token, payload) {
  return request('/auth/me/', { method: 'PATCH', token, body: payload })
}

export function logout(token) {
  return request('/auth/logout/', { method: 'POST', token })
}

// ── Escrow contracts ──────────────────────────────────────────────────────────

export function mineContracts(token) {
  return request('/escrow/mine/', { token })
}

export function getContract(token, id) {
  return request(`/escrow/${id}/`, { token })
}

export function createContract(token, { buyerPhone, itemName, amount }) {
  const pin = Array.from(crypto.getRandomValues(new Uint8Array(4)))
    .map((b) => b % 10)
    .join('')
  return request('/escrow/create/', {
    method: 'POST',
    token,
    body: {
      buyer_phone: buyerPhone,
      item_name: itemName,
      amount: String(amount),
      verification_pin: `${pin}${pin}`,
    },
  })
}

export function pay(token, id) {
  return request(`/escrow/${id}/pay/`, { method: 'POST', token })
}

export function sandboxFund(token, id) {
  return request(`/escrow/${id}/sandbox-fund/`, { method: 'POST', token })
}

export function markShipped(token, id) {
  return request(`/escrow/${id}/mark-shipped/`, { method: 'POST', token })
}

export function confirmDelivery(token, id, { qrToken, pin } = {}) {
  return request(`/escrow/${id}/confirm-delivery/`, {
    method: 'POST',
    token,
    body: {
      ...(qrToken ? { qr_token: qrToken } : {}),
      ...(pin ? { pin } : {}),
    },
  })
}

export function openDispute(token, id, reason) {
  return request(`/escrow/${id}/dispute/`, {
    method: 'POST',
    token,
    body: { reason },
  })
}

// ── Merchant settings ─────────────────────────────────────────────────────────

export function getMerchantSettings(token) {
  return request('/merchant/settings/', { token })
}

export function updateMerchantSettings(token, payload) {
  return request('/merchant/settings/', { method: 'PATCH', token, body: payload })
}

export function rotateMerchantKeys(token) {
  return request('/merchant/settings/rotate/', { method: 'POST', token })
}

// ── Disputes ──────────────────────────────────────────────────────────────────

export function listDisputes(token) {
  return request('/disputes/', { token })
}

export function getDispute(token, id) {
  return request(`/disputes/${id}/`, { token })
}

export function sendDisputeMessage(token, id, { message, attachmentUrl } = {}) {
  return request(`/disputes/${id}/messages/`, {
    method: 'POST',
    token,
    body: {
      message,
      ...(attachmentUrl ? { attachment_url: attachmentUrl } : {}),
    },
  })
}

export function reviewDispute(token, id) {
  return request(`/disputes/${id}/review/`, { method: 'POST', token })
}

export function resolveDispute(token, id, resolution) {
  return request(`/disputes/${id}/resolve/`, {
    method: 'POST',
    token,
    body: { resolution },
  })
}

export function adminOverview(token) {
  return request('/admin/overview/', { token })
}

export { ApiError, BASE_URL }
