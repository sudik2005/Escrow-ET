import { useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'

function Checkout() {
  const navigate = useNavigate()

  // TODO: replace this hardcoded data with a real fetch from Django,
  // using a transaction/link ID pulled from the URL (e.g. /checkout/:linkId).
  const deal = {
    productName: 'Yirgacheffe Coffee',
    sellerName: 'Buna Coffee',
    description: 'Top quality freshly roasted coffee beans',
    itemAmount: 500.0,
    escrowFee: 10.0,
  }
  const total = deal.itemAmount + deal.escrowFee

  const whyEscrowSteps = [
    'Pay safely and securely',
    'Funds are held in escrow',
    'Delivery person scans the QR',
    'Funds are released after delivery',
  ]

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">        <div className="flex items-center gap-3 mb-6">
          <button type="button" aria-label="Go back">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Checkout</h1>
        </div>

        {/* Step indicator: Review -> Payment -> Confirm */}
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

        <h2 className="text-sm font-semibold text-[var(--text)] mb-3">Order Summary</h2>
        <div className="flex gap-3 mb-4 pb-4 border-b border-[var(--border)]">
          <div className="w-14 h-14 bg-[var(--surface-hover)] rounded-lg shrink-0" />
          <div>
            <p className="font-semibold">{deal.productName}</p>
            <p className="text-sm text-[var(--text-muted)]">by {deal.sellerName}</p>
            <p className="text-sm text-[var(--text-muted)]">{deal.description}</p>
          </div>
        </div>

        <div className="space-y-2 mb-4 pb-4 border-b border-[var(--border)] text-sm">
          <div className="flex justify-between text-[var(--text)]">
            <span>Item Amount</span>
            <span>{deal.itemAmount.toFixed(2)} ETB</span>
          </div>
          <div className="flex justify-between text-[var(--text)]">
            <span>Escrow Protection Fee</span>
            <span>{deal.escrowFee.toFixed(2)} ETB</span>
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
          onClick={() => navigate('/payment')}
          className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] text-white font-semibold py-3.5 rounded-xl transition-colors"
        >
          Continue to Payment
        </button>
      </div>
    </div>
  )
}

export default Checkout