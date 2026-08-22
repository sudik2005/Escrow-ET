export function normalizeStatus(status) {
  return String(status || '').toUpperCase()
}

export function isPendingPayment(status) {
  return normalizeStatus(status) === 'PENDING_PAYMENT'
}

export function isLocked(status) {
  return ['FUNDED', 'IN_TRANSIT', 'DELIVERED_UNVERIFIED', 'DISPUTED'].includes(
    normalizeStatus(status),
  )
}

export function isReleased(status) {
  return normalizeStatus(status) === 'COMPLETED'
}

export function isDisputed(status) {
  return normalizeStatus(status) === 'DISPUTED'
}

export function statusVariant(status) {
  const s = normalizeStatus(status)
  if (s === 'COMPLETED') return 'released'
  if (s === 'DISPUTED' || s === 'CANCELLED') return 'disputed'
  return 'locked'
}

export function statusLabel(status) {
  const map = {
    PENDING_PAYMENT: 'Pending payment',
    FUNDED: 'Funds locked',
    IN_TRANSIT: 'In transit',
    DELIVERED_UNVERIFIED: 'Delivered',
    COMPLETED: 'Released',
    DISPUTED: 'Disputed',
    CANCELLED: 'Cancelled',
  }
  const s = normalizeStatus(status)
  return map[s] || status || 'Unknown'
}

export function timelineSteps(status) {
  const s = normalizeStatus(status)
  const steps = [
    { label: 'Payment initiated', state: 'upcoming' },
    { label: 'Funds locked', state: 'upcoming' },
    { label: 'Delivery in progress', state: 'upcoming' },
    { label: 'Funds released', state: 'upcoming' },
  ]

  if (s === 'PENDING_PAYMENT') {
    steps[0].state = 'current'
  } else if (s === 'FUNDED') {
    steps[0].state = 'done'
    steps[1].state = 'current'
  } else if (s === 'IN_TRANSIT' || s === 'DELIVERED_UNVERIFIED' || s === 'DISPUTED') {
    steps[0].state = 'done'
    steps[1].state = 'done'
    steps[2].state = 'current'
  } else if (s === 'COMPLETED') {
    steps.forEach((step) => {
      step.state = 'done'
    })
  } else if (s === 'CANCELLED') {
    steps[0].state = 'done'
    steps[1].state = 'done'
  }
  return steps
}

export function fmtEtb(n) {
  return `${Number(n).toLocaleString('en-ET', { minimumFractionDigits: 2 })} ETB`
}

export function displayName(user) {
  return user?.legal_name || user?.username || 'Account'
}

export function initials(name) {
  const parts = String(name || '').trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return 'ET'
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
  return `${parts[0][0]}${parts[1][0]}`.toUpperCase()
}
