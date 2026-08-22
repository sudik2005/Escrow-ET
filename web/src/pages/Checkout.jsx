import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import * as api from '../lib/api'

const ESCROW_FEE_RATE = 0.02  // 2 % fee (mirrors Flutter app)

function Checkout() {
  const navigate = useNavigate()
  const { contractId } = useParams()
  const { token, loading: authLoading } = useAuth()

  const [contract, setContract] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (authLoading) return
    if (!token) {
      navigate('/login', { replace: true, state: { from: { pathname: `/checkout/${contractId || ''}` } } })
      return
    }
    if (!contractId) {
      setLoading(false)
      return
    }
    api.getContract(token, contractId)
      .then((data) => setContract(data))
      .catch((err) => setError(err.message || 'Contract not found.'))
      .finally(() => setLoading(false))
  }, [authLoading, token, contractId, navigate])

  const whyEscrowSteps = [
    'Pay safely and securely',
    'Funds are held in escrow',
    'Delivery person scans the QR',
    'Funds are released after delivery',
  ]

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">
        <div className="flex items-center gap-3 mb-6">
          <button type="button" aria-label="Go back" onClick={() => navigate(-1)}>
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Checkout</h1>
        </div>

        {/* Step indicator */}
        <div className="flex items-center justify-center gap-2 mb-6 text-xs">
          <span className="flex items-center gap-1.5 font-semibold text-[var(--brand)]">
            <span className="w-5 h-5 rounded-full bg-[var(--brand)] text-white flex items-center justify-center text-[10px]">1</span>
            Review
          </span>
          <span className="text-[var(--text-subtle)]">→</span>
          <span className="flex items-center gap-1.5 text-[var(--text-muted)]">
            <span className="w-5 h-5 rounded-full border border-[var(--border)] flex items-center justify-center text-[10px]">2</span>
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

        {error && (
          <div className="text-center py-8">
            <p className="text-red-500 mb-4">{error}</p>
            <button
              type="button"
              onClick={() => navigate('/')}
              className="text-[var(--brand)] hover:underline text-sm"
            >
              Go home
            </button>
          </div>
        )}

        {!loading && !error && !contractId && (
          <p className="text-center text-[var(--text-muted)] py-8">No contract ID in URL.</p>
        )}

        {contract && (() => {
          const itemAmount = Number(contract.amount)
          const escrowFee = parseFloat((itemAmount * ESCROW_FEE_RATE).toFixed(2))
          const total = itemAmount + escrowFee
          return (
            <>
              <h2 className="text-sm font-semibold text-[var(--text)] mb-3">Order Summary</h2>
              <div className="flex gap-3 mb-4 pb-4 border-b border-[var(--border)]">
                <div className="w-14 h-14 bg-[var(--surface-hover)] rounded-lg shrink-0 flex items-center justify-center">
                  <span className="text-2xl">🛒</span>
                </div>
                <div>
                  <p className="font-semibold">{contract.item_name}</p>
                  <p className="text-sm text-[var(--text-muted)]">
                    by {contract.seller_username || 'Seller'}
                  </p>
                </div>
              </div>

              <div className="space-y-2 mb-4 pb-4 border-b border-[var(--border)] text-sm">
                <div className="flex justify-between text-[var(--text)]">
                  <span>Item Amount</span>
                  <span>{itemAmount.toFixed(2)} ETB</span>
                </div>
                <div className="flex justify-between text-[var(--text)]">
                  <span>Escrow Protection Fee (2%)</span>
                  <span>{escrowFee.toFixed(2)} ETB</span>
                </div>
              </div>

              <div className="flex justify-between font-bold mb-6">
                <span>Total</span>
                <span>{total.toFixed(2)} ETB</span>
              </div>

              <div className="bg-[var(--surface-hover)] rounded-xl p-4 mb-6">
                <p className="text-sm font-semibold mb-2">Why Escrow ET?</p>
                <ol className="text-sm text-[var(--text)] space-y-1 list-decimal list-inside">
                  {whyEscrowSteps.map((step) => (
                    <li key={step}>{step}</li>
                  ))}
                </ol>
              </div>

              <button
                type="button"
                onClick={() => navigate(`/payment/${contract.id}`)}
                className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] text-white font-semibold py-3.5 rounded-xl transition-colors"
              >
                Continue to Payment
              </button>
            </>
          )
        })()}
      </div>
    </div>
  )
}

export default Checkout
