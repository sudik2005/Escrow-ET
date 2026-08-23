import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import * as api from '../lib/api'

function Payment() {
  const navigate = useNavigate()
  const { contractId } = useParams()
  const { token, loading: authLoading } = useAuth()

  const [contract, setContract] = useState(null)
  const [loading, setLoading] = useState(true)
  const [fetchError, setFetchError] = useState(null)
  const [payError, setPayError] = useState(null)
  const [redirecting, setRedirecting] = useState(false)
  const [sandboxBusy, setSandboxBusy] = useState(false)

  useEffect(() => {
    if (authLoading) return
    if (!token) {
      navigate('/login', { replace: true, state: { from: { pathname: `/payment/${contractId || ''}` } } })
      return
    }
    if (!contractId) {
      setLoading(false)
      return
    }
    api.getContract(token, contractId)
      .then((data) => setContract(data))
      .catch((err) => setFetchError(err.message || 'Contract not found.'))
      .finally(() => setLoading(false))
  }, [authLoading, token, contractId, navigate])

  async function handlePayNow() {
    setPayError(null)
    setRedirecting(true)
    try {
      const existing = contract?.payment_link
      if (existing) {
        window.location.href = existing
        return
      }
      const data = await api.pay(token, contractId)
      const chapaUrl =
        data.payment_link || data.checkout_url || data.chapa_url || data.url
      if (chapaUrl) {
        window.location.href = chapaUrl
        return
      }
      setPayError('Chapa did not return a checkout URL. Try sandbox payment.')
      setRedirecting(false)
    } catch (err) {
      setPayError(err.message || 'Payment initiation failed. Try again.')
      setRedirecting(false)
    }
  }

  async function handleSandboxFund() {
    setPayError(null)
    setSandboxBusy(true)
    try {
      await api.sandboxFund(token, contractId)
      navigate(`/payment-success?id=${contractId}`)
    } catch (err) {
      setPayError(err.message || 'Sandbox fund failed.')
      setSandboxBusy(false)
    }
  }

  const itemAmount = contract ? Number(contract.amount) : 0
  const total = itemAmount

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">
        <div className="flex items-center gap-3 mb-2">
          <button type="button" aria-label="Go back" onClick={() => navigate(-1)}>
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Payment</h1>
        </div>

        <div className="flex items-center justify-center gap-2 mb-6 text-xs">
          <span className="flex items-center gap-1.5 text-[var(--text-muted)]">
            <span className="w-5 h-5 rounded-full border border-[var(--border)] flex items-center justify-center text-[10px]">1</span>
            Review
          </span>
          <span className="text-[var(--text-subtle)]">→</span>
          <span className="flex items-center gap-1.5 font-semibold text-[var(--brand)]">
            <span className="w-5 h-5 rounded-full bg-[var(--brand)] text-white flex items-center justify-center text-[10px]">2</span>
            Payment
          </span>
          <span className="text-[var(--text-subtle)]">→</span>
          <span className="flex items-center gap-1.5 text-[var(--text-muted)]">
            <span className="w-5 h-5 rounded-full border border-[var(--border)] flex items-center justify-center text-[10px]">3</span>
            Confirm
          </span>
        </div>

        {loading && (
          <div className="flex justify-center py-12">
            <div className="w-8 h-8 border-2 border-[var(--brand)] border-t-transparent rounded-full animate-spin" />
          </div>
        )}

        {fetchError && (
          <p className="text-center text-red-500 py-8">{fetchError}</p>
        )}

        {contract && (
          <>
            <h2 className="text-sm font-semibold text-[var(--text)] mb-3">Order Summary</h2>
            <div className="flex gap-3 mb-4 pb-4 border-b border-[var(--border)]">
              <div className="w-14 h-14 bg-[var(--surface-hover)] rounded-lg shrink-0 flex items-center justify-center">
                <span className="text-2xl">🛒</span>
              </div>
              <div>
                <p className="font-semibold">{contract.item_name}</p>
                <p className="text-sm text-[var(--text-muted)]">
                  by {contract.seller_username || contract.seller_phone || 'Seller'}
                </p>
              </div>
            </div>

            <div className="space-y-2 mb-4 pb-4 border-b border-[var(--border)] text-sm">
              <div className="flex justify-between text-[var(--text)]">
                <span>Amount held in escrow</span>
                <span>{itemAmount.toFixed(2)} ETB</span>
              </div>
            </div>

            <div className="flex justify-between font-bold mb-6">
              <span>Total Amount</span>
              <span>{total.toFixed(2)} ETB</span>
            </div>

            <div className="bg-[var(--brand-soft)] border border-[var(--brand-border)] rounded-xl p-4 mb-6 flex items-start gap-2">
              <span className="text-[var(--brand)] mt-0.5">✓</span>
              <div>
                <p className="text-sm font-semibold text-[var(--brand)]">Your payment is protected</p>
                <p className="text-sm text-[var(--text)]">
                  Money is securely held in escrow until delivery is verified.
                </p>
              </div>
            </div>

            <p className="text-sm font-semibold mb-1">Ready to pay?</p>
            <p className="text-sm text-[var(--text-muted)] mb-4">
              You will be redirected to Chapa to complete your payment securely.
            </p>

            {payError && (
              <p className="text-sm text-red-500 bg-red-50 dark:bg-red-900/20 rounded-lg px-3 py-2 mb-4">
                {payError}
              </p>
            )}

            <button
              type="button"
              onClick={handlePayNow}
              disabled={redirecting || sandboxBusy}
              className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] disabled:opacity-50 text-white font-semibold py-3.5 rounded-xl transition-colors mb-3"
            >
              {redirecting ? 'Redirecting to Chapa…' : `Pay Now — ${total.toFixed(2)} ETB`}
            </button>

            <button
              type="button"
              onClick={handleSandboxFund}
              disabled={redirecting || sandboxBusy}
              className="w-full bg-transparent border border-[var(--border)] hover:bg-[var(--surface-hover)] disabled:opacity-50 text-[var(--text)] font-semibold py-3 rounded-xl transition-colors mb-4 text-sm"
            >
              {sandboxBusy ? 'Processing…' : 'Sandbox — Simulate Payment'}
            </button>

            <p className="text-center text-xs text-[var(--text-subtle)]">
              By proceeding, you agree to our Terms of Service and Privacy Policy.
            </p>
          </>
        )}
      </div>
    </div>
  )
}

export default Payment
