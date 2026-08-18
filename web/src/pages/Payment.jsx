import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'

function Payment() {
  const navigate = useNavigate()
  const [isRedirecting, setIsRedirecting] = useState(false)

  // TODO: replace with real order data fetched from Django (same deal as Checkout.jsx).
  const deal = {
    productPrice: 500.0,
    escrowFee: 10.0,
  }
  const total = deal.productPrice + deal.escrowFee

  async function handlePayNow() {
    setIsRedirecting(true)
    try {
      // TODO: replace this mock with a real call to the Django backend, e.g.:
      // const res = await fetch('/api/payments/initiate/', {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify({ transactionId: deal.id }),
      // })
      // const data = await res.json()
      // window.location.href = data.chapaCheckoutUrl

      await new Promise((resolve) => setTimeout(resolve, 1000))
      navigate('/payment-success')
    } catch (err) {
      console.error('Payment initiation failed:', err)
      setIsRedirecting(false)
    }
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-sm p-8">
        <div className="flex items-center gap-3 mb-2">
          <button type="button" aria-label="Go back">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Payment</h1>
        </div>

        <div className="flex items-center justify-center gap-2 mb-2 text-xs">
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

        <button type="button" className="text-sm text-[var(--text-muted)] mb-4 block">
          ← Back to Dashboard
        </button>

        <h2 className="text-sm font-semibold text-[var(--text)] mb-3">Order Summary</h2>
        <div className="flex gap-3 mb-4 pb-4 border-b border-[var(--border)]">
          <div className="w-14 h-14 bg-[var(--surface-hover)] rounded-lg shrink-0" />
          <div>
            <p className="font-semibold">Yirgacheffe Coffee</p>
            <p className="text-sm text-[var(--text-muted)]">by Buna Coffee</p>
            <p className="text-sm text-[var(--text-muted)]">1kg freshly roasted coffee beans</p>
          </div>
        </div>

        <div className="space-y-2 mb-4 pb-4 border-b border-[var(--border)] text-sm">
          <div className="flex justify-between text-[var(--text)]">
            <span>Product Price</span>
            <span>{deal.productPrice.toFixed(2)} ETB</span>
          </div>
          <div className="flex justify-between text-[var(--text)]">
            <span>Escrow Protection Fee</span>
            <span>{deal.escrowFee.toFixed(2)} ETB</span>
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
              The money will be securely held in escrow until delivery is verified.
            </p>
          </div>
        </div>

        <p className="text-sm font-semibold mb-1">Ready to pay?</p>
        <p className="text-sm text-[var(--text-muted)] mb-6">
          You will be redirected to our secure payment partner (Chapa) to complete your payment.
        </p>

        <button
          type="button"
          onClick={handlePayNow}
          disabled={isRedirecting}
          className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] disabled:opacity-50 text-white font-semibold py-3.5 rounded-xl transition-colors mb-4"
        >
          {isRedirecting ? 'Redirecting...' : `Pay Now — ${total.toFixed(2)} ETB`}
        </button>

        <p className="text-center text-xs text-[var(--text-subtle)]">
          By proceeding, you agree to our Terms of Service and Privacy Policy.
        </p>
      </div>
    </div>
  )
}

export default Payment