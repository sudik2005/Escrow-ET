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

export function register({ username, password, phoneNumber, role, email = '' }) {
  return request('/auth/register/', {
    method: 'POST',
    body: { username, password, phone_number: phoneNumber, role, email },
  })
}

export function me(token) {
  return request('/auth/me/', { token })
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
