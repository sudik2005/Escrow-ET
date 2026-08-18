import { useNavigate } from 'react-router-dom'
import { Check } from 'lucide-react'

function DeliveryVerified() {
  const navigate = useNavigate()

  // TODO: replace with real data from the POST /escrow/<id>/confirm-delivery/ response.
  const transaction = {
    id: 'ET-10294',
    amount: 500.0,
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8 text-center">
        <div className="w-16 h-16 bg-[var(--brand)] rounded-full flex items-center justify-center mx-auto mb-4">
          <Check className="w-8 h-8 text-white" strokeWidth={3} />
        </div>

        <h1 className="text-xl font-bold mb-2">Delivery Verified!</h1>
        <p className="text-sm text-[var(--text-muted)] mb-6">
          The order has been verified successfully. Funds are being released to the seller.
        </p>

        <div className="text-left space-y-2 text-sm border-t border-[var(--border)] pt-4 mb-6">
          <div className="flex justify-between">
            <span className="text-[var(--text-muted)]">Transaction</span>
            <span className="font-medium">{transaction.id}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-[var(--text-muted)]">Amount</span>
            <span className="font-medium">{transaction.amount.toFixed(2)} ETB</span>
          </div>
        </div>

        <button
          type="button"
          onClick={() => navigate('/transactions')}
          className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] text-white font-semibold py-3.5 rounded-xl transition-colors"
        >
          Done
        </button>
      </div>
    </div>
  )
}

export default DeliveryVerified