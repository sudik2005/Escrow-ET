import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import * as api from '../lib/api'
import { statusLabel, timelineSteps } from '../lib/status'

function fmtDate(iso) {
  if (!iso) return 'Pending'
  return new Date(iso).toLocaleString('en-ET', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

function ContractDetail({ contract, user, onUpdated }) {
  const navigate = useNavigate()
  const { token } = useAuth()
  const timeline = timelineSteps(contract.status)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState(null)
  const isSeller = user && String(user.id) === String(contract.seller_id)
  const canShip = isSeller && contract.status === 'FUNDED'
  const canDispute = ['FUNDED', 'IN_TRANSIT', 'DELIVERED_UNVERIFIED'].includes(contract.status)

  async function handleShip() {
    setBusy(true)
    setError(null)
    try {
      const next = await api.markShipped(token, contract.id)
      onUpdated(next)
    } catch (err) {
      setError(err.message || 'Could not mark as shipped.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div>
      <div className="flex justify-between items-start mb-1">
        <p className="font-semibold">Transaction #ET-{contract.id}</p>
        <span className="text-xs bg-[var(--warning-soft)] text-[var(--warning)] font-medium px-2 py-1 rounded-full">
          {statusLabel(contract.status)}
        </span>
      </div>
      <p className="text-sm text-[var(--text-muted)] mb-1">{contract.item_name}</p>
      <p className="text-sm text-[var(--text-muted)] mb-6">
        Seller: {contract.seller_username || contract.seller_phone || '—'}
      </p>

      <div className="mb-6">
        {timeline.map((step, i) => (
          <div key={step.label} className="flex gap-3">
            <div className="flex flex-col items-center">
              <div
                className={`w-3 h-3 rounded-full shrink-0 mt-1 ${
                  step.state === 'done'
                    ? 'bg-[var(--success)]'
                    : step.state === 'current'
                    ? 'bg-[var(--warning)]'
                    : 'bg-[var(--border-strong)]'
                }`}
              />
              {i < timeline.length - 1 && (
                <div className="w-px flex-1 bg-[var(--border)] my-1" />
              )}
            </div>
            <div className="pb-6">
              <p
                className={`text-sm font-semibold ${
                  step.state === 'upcoming' ? 'text-[var(--text-muted)]' : 'text-[var(--text-h)]'
                }`}
              >
                {step.label}
              </p>
              <p className="text-xs text-[var(--text-subtle)]">
                {step.state === 'done'
                  ? fmtDate(contract.updated_at || contract.created_at)
                  : step.state === 'current'
                  ? 'In progress…'
                  : 'Pending'}
              </p>
            </div>
          </div>
        ))}
      </div>

      <div className="flex justify-between text-sm mb-6 pt-2 border-t border-[var(--border)]">
        <span className="text-[var(--text-muted)]">Amount</span>
        <span className="font-bold">{Number(contract.amount).toFixed(2)} ETB</span>
      </div>

      {error && <p className="text-sm text-red-500 mb-3">{error}</p>}

      {canShip && (
        <button
          type="button"
          disabled={busy}
          onClick={handleShip}
          className="w-full mb-2 bg-[var(--brand)] hover:bg-[var(--brand-hover)] disabled:opacity-50 text-white font-semibold py-3.5 rounded-xl transition-colors"
        >
          {busy ? 'Updating…' : 'Mark as shipped'}
        </button>
      )}

      <button
        type="button"
        onClick={() => navigate(`/qr-code?id=${contract.id}`)}
        className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] text-white font-semibold py-3.5 rounded-xl transition-colors"
      >
        View QR code
      </button>
      {canDispute && (
        <button
          type="button"
          onClick={() => navigate(`/disputes?id=${contract.id}`)}
          className="w-full mt-2 border border-[var(--border)] text-[var(--text-h)] font-semibold py-3.5 rounded-xl transition-colors"
        >
          Open dispute
        </button>
      )}
      {contract.dispute_id && (
        <button
          type="button"
          onClick={() => navigate(`/disputes/messages?id=${contract.dispute_id}`)}
          className="w-full mt-2 border border-[var(--border)] text-[var(--text-h)] font-semibold py-3.5 rounded-xl transition-colors"
        >
          View dispute messages
        </button>
      )}
    </div>
  )
}

function TransactionTracking() {
  const { token, user } = useAuth()
  const [searchParams] = useSearchParams()
  const focusId = searchParams.get('id')

  const [contracts, setContracts] = useState([])
  const [selected, setSelected] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (!token) {
      setLoading(false)
      return
    }
    api.mineContracts(token)
      .then((data) => {
        const list = Array.isArray(data) ? data : []
        setContracts(list)
        if (focusId) {
          const match = list.find((c) => String(c.id) === focusId)
          if (match) setSelected(match)
        } else if (list.length > 0) {
          setSelected(list[0])
        }
      })
      .catch((err) => setError(err.message || 'Failed to load transactions.'))
      .finally(() => setLoading(false))
  }, [token, focusId])

  function handleUpdated(next) {
    setContracts((prev) => prev.map((c) => (c.id === next.id ? next : c)))
    setSelected(next)
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4">
      <div className="max-w-4xl mx-auto">
        <div className="flex items-center gap-3 mb-6">
          <button type="button" aria-label="Go back" onClick={() => window.history.back()}>
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Transaction Tracking</h1>
        </div>

        {loading && (
          <div className="flex justify-center py-12">
            <div className="w-8 h-8 border-2 border-[var(--brand)] border-t-transparent rounded-full animate-spin" />
          </div>
        )}

        {error && <p className="text-center text-red-500 py-8">{error}</p>}

        {!loading && !error && contracts.length === 0 && (
          <p className="text-center text-[var(--text-muted)] py-12">No transactions yet.</p>
        )}

        {!loading && contracts.length > 0 && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-1 space-y-2">
              {contracts.map((c) => (
                <button
                  key={c.id}
                  type="button"
                  onClick={() => setSelected(c)}
                  className={`w-full text-left bg-[var(--surface)] rounded-xl p-4 border transition-colors ${
                    selected?.id === c.id
                      ? 'border-[var(--brand)]'
                      : 'border-[var(--border)] hover:border-[var(--brand-border)]'
                  }`}
                >
                  <p className="font-semibold text-sm truncate">{c.item_name}</p>
                  <p className="text-xs text-[var(--text-muted)]">{Number(c.amount).toFixed(2)} ETB</p>
                  <p className="text-xs text-[var(--text-subtle)] mt-1">{statusLabel(c.status)}</p>
                </button>
              ))}
            </div>

            <div className="md:col-span-2 bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">
              {selected ? (
                <ContractDetail contract={selected} user={user} onUpdated={handleUpdated} />
              ) : (
                <p className="text-center text-[var(--text-muted)]">Select a transaction.</p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default TransactionTracking
