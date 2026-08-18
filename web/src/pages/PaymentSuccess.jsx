import { useNavigate } from 'react-router-dom'
import { Check } from 'lucide-react'

function PaymentSuccess() {
  const navigate = useNavigate()

  // TODO: replace with the real transaction total, fetched or passed from Payment.jsx.
  const total = 510.0

  const nextSteps = [
    'Seller will deliver your order',
    'After you receive it, show the QR code',
    'Delivery person scans the QR',
    'Funds are released to the seller',
  ]

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">        <div className="w-16 h-16 bg-[var(--brand)] rounded-full flex items-center justify-center mx-auto mb-4">
          <Check className="w-8 h-8 text-white" strokeWidth={3} />
        </div>

        <h1 className="text-xl font-bold mb-1">Payment Successful</h1>
        <p className="text-2xl font-bold text-[var(--brand)] mb-4">{total.toFixed(2)} ETB</p>
        <p className="text-sm text-[var(--text-muted)] mb-6">
          Your payment is now safely held in escrow. The seller has been notified.
        </p>

        <div className="bg-[var(--surface-hover)] rounded-xl p-4 mb-6 text-left">
          <p className="text-sm font-semibold mb-2">What happens next?</p>
          <ol className="text-sm text-[var(--text)] space-y-1 list-decimal list-inside">
            {nextSteps.map((step) => (
              <li key={step}>{step}</li>
            ))}
          </ol>
        </div>

        <button
          type="button"
          onClick={() => navigate('/transactions')}
          className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] text-white font-semibold py-3.5 rounded-xl transition-colors"
        >
          View Transaction
        </button>
      </div>
    </div>
  )
}

export default PaymentSuccess