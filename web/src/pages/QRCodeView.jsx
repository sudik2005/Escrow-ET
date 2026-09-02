import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { ArrowLeft, Eye, EyeOff, Copy, Check } from 'lucide-react'
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
  const [sellerPin, setSellerPin] = useState(null)
  const [pinVisible, setPinVisible] = useState(false)
  const [copied, setCopied] = useState(false)

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
      .then((c) => {
        setContract(c)
        setSellerPin(api.loadPin(c.id))
      })
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

  function handleCopy() {
    if (!sellerPin) return
    navigator.clipboard.writeText(sellerPin).then(() => {
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    })
  }

  function formatPin(p) {
    if (!p) return ''
    const half = Math.floor(p.length / 2)
    return `${p.slice(0, half)}  ${p.slice(half)}`
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

        {/* ── Seller PIN display ── */}
        {!isBuyer && sellerPin && (
          <div className="text-left mb-6 border border-[var(--border)] rounded-xl p-4">
            <div className="flex items-center gap-2 mb-3">
              <span className="text-xs font-bold tracking-widest text-[var(--brand)] uppercase">
                Delivery PIN
              </span>
              <span className="ml-auto">
                <button
                  type="button"
                  onClick={() => setPinVisible((v) => !v)}
                  className="text-[var(--text-muted)] hover:text-[var(--text-h)] transition-colors"
                  aria-label={pinVisible ? 'Hide PIN' : 'Show PIN'}
                >
                  {pinVisible ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </span>
            </div>
            <div className="flex items-center gap-3">
              <span
                className="font-mono text-2xl font-bold tracking-[0.25em] flex-1"
                style={{ color: pinVisible ? 'var(--text-h)' : 'transparent', textShadow: pinVisible ? 'none' : '0 0 10px var(--text-muted)' }}
              >
                {pinVisible ? formatPin(sellerPin) : '●●●●  ●●●●'}
              </span>
              {pinVisible && (
                <button
                  type="button"
                  onClick={handleCopy}
                  className="flex items-center gap-1.5 text-xs font-bold text-[var(--brand)] bg-[var(--brand)]/10 px-3 py-1.5 rounded-lg transition-colors hover:bg-[var(--brand)]/20"
                >
                  {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
                  {copied ? 'Copied' : 'Copy'}
                </button>
              )}
            </div>
            <p className="text-xs text-[var(--text-muted)] mt-3 leading-relaxed">
              Share this PIN with your buyer so they can confirm delivery remotely.
            </p>
          </div>
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

        {/* ── Buyer PIN entry ── */}
        {isBuyer && (
          <div className="text-left mb-4">
            <label className="block text-sm text-[var(--text)] mb-1.5" htmlFor="delivery-pin">
              Delivery PIN
            </label>
            <p className="text-xs text-[var(--text-muted)] mb-2">
              Can't scan the QR? Ask your seller for the PIN and enter it below.
            </p>
            <input
              id="delivery-pin"
              value={pin}
              onChange={(e) => setPin(e.target.value)}
              className="w-full bg-[var(--input-bg)] border border-[var(--border)] rounded-xl px-4 py-3 text-[var(--text-h)] focus:outline-none focus:border-[var(--brand)] text-center font-mono text-xl tracking-widest"
              placeholder="Enter PIN"
              maxLength={8}
              inputMode="numeric"
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
