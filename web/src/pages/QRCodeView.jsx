import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { QRCodeSVG } from 'qrcode.react'
import { useAuth } from '../context/AuthContext'
import * as api from '../lib/api'

function QRCodeView() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const contractId = searchParams.get('id')
  const { token, user, loading: authLoading } = useAuth()
  const [contract, setContract] = useState(null)
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)
  const [pin, setPin] = useState('')

  useEffect(() => {
    if (authLoading) return
    if (!token) {
      navigate('/login', {
        replace: true,
        state: { from: { pathname: `/qr-code${contractId ? `?id=${contractId}` : ''}` } },
      })
      return
    }
    if (!contractId) {
      setError('Open this page from a transaction to see its delivery QR.')
      return
    }
    api.getContract(token, contractId)
      .then(setContract)
      .catch((err) => setError(err.message || 'Contract not found.'))
  }, [authLoading, token, contractId, navigate])

  const isBuyer = user && contract && String(user.id) === String(contract.buyer_id)

  async function handleConfirm() {
    setBusy(true)
    setError(null)
    try {
      await api.confirmDelivery(
        token,
        contract.id,
        pin.trim()
          ? { pin: pin.trim() }
          : { qrToken: contract.delivery_qr_token },
      )
      navigate(`/delivery-verified?id=${contract.id}`)
    } catch (err) {
      setError(err.message || 'Could not confirm delivery.')
      setBusy(false)
    }
  }

  const qrValue = contract?.delivery_qr_token || ''

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8 text-center">
        <div className="flex items-center gap-3 mb-6 text-left">
          <button type="button" aria-label="Go back" onClick={() => navigate(-1)}>
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Delivery</h1>
        </div>

        <h2 className="text-lg font-bold mb-2">Show this QR code at delivery</h2>
        <p className="text-sm text-[var(--text-muted)] mb-6">
          The buyer confirms with this QR or the deal PIN. Funds release only after a match.
        </p>

        {qrValue ? (
          <div className="bg-white rounded-2xl p-6 inline-block mb-6">
            <QRCodeSVG value={qrValue} size={200} />
          </div>
        ) : (
          <p className="text-sm text-[var(--text-muted)] mb-6">
            {error || 'Loading delivery QR…'}
          </p>
        )}

        <div className="text-left space-y-2 text-sm border-t border-[var(--border)] pt-4 mb-6">
          <div className="flex justify-between">
            <span className="text-[var(--text-muted)]">Transaction</span>
            <span className="font-medium">{contract ? `ET-${contract.id}` : '—'}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-[var(--text-muted)]">Amount</span>
            <span className="font-medium">
              {contract ? `${Number(contract.amount).toFixed(2)} ETB` : '—'}
            </span>
          </div>
        </div>

        {isBuyer && (
          <div className="text-left mb-4">
            <label className="block text-sm text-[var(--text)] mb-1.5" htmlFor="delivery-pin">
              Delivery PIN (optional)
            </label>
            <input
              id="delivery-pin"
              value={pin}
              onChange={(e) => setPin(e.target.value)}
              className="w-full bg-[var(--input-bg)] border border-[var(--border)] rounded-xl px-4 py-3 text-[var(--text-h)] focus:outline-none focus:border-[var(--brand)]"
              placeholder="Enter PIN if you are confirming by PIN"
            />
          </div>
        )}

        {error && contract && (
          <p className="text-sm text-red-500 mb-4">{error}</p>
        )}

        {isBuyer && (
          <button
            type="button"
            disabled={!contract || busy}
            onClick={handleConfirm}
            className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] disabled:opacity-50 text-white font-semibold py-3.5 rounded-xl transition-colors"
          >
            {busy ? 'Confirming…' : 'Confirm delivery'}
          </button>
        )}
      </div>
    </div>
  )
}

export default QRCodeView
