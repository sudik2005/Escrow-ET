import { ArrowLeft } from 'lucide-react'
import { useNavigate } from 'react-router-dom'

function TransactionTracking() {
  // TODO: replace with real transaction data + status fetched from Django,
  // which will update as it receives Chapa webhooks.

  const navigate = useNavigate()
  const transaction = {
    id: 'ET-10294',
    productName: 'Yirgacheffe Coffee',
    seller: 'Buna Coffee',
    amount: 500.0,
    status: 'Funds Locked', // Payment Initiated | Funds Locked | Delivery In Progress | Funds Released
  }

  const timeline = [
    { label: 'Payment Initiated', time: 'Aug 12, 2026, 10:30 AM', state: 'done' },
    { label: 'Funds Locked', time: 'Aug 12, 2026, 10:32 AM', state: 'current' },
    { label: 'Delivery in Progress', time: 'Seller is preparing your order.', state: 'upcoming' },
    { label: 'Funds Released', time: 'Pending', state: 'upcoming' },
  ]

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">        <div className="flex items-center gap-3 mb-6">
          <button type="button" aria-label="Go back">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Transaction Tracking</h1>
        </div>

        <div className="flex justify-between items-start mb-1">
          <p className="font-semibold">Transaction #{transaction.id}</p>
          <span className="text-xs bg-[var(--warning-soft)] text-[var(--warning)] font-medium px-2 py-1 rounded-full">
            {transaction.status}
          </span>
        </div>
        <p className="text-sm text-[var(--text-muted)] mb-1">{transaction.productName}</p>
        <p className="text-sm text-[var(--text-muted)] mb-6">Seller: {transaction.seller}</p>

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
                <p className="text-xs text-[var(--text-subtle)]">{step.time}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="flex justify-between text-sm mb-6 pt-2 border-t border-[var(--border)]">
          <span className="text-[var(--text-muted)]">Amount</span>
          <span className="font-bold">{transaction.amount.toFixed(2)} ETB</span>
        </div>

        <button
          type="button"
          onClick={() => navigate('/qr-code')}
          className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] text-white font-semibold py-3.5 rounded-xl transition-colors"
        >
          View QR Code
        </button>
      </div>
    </div>
  )
}

export default TransactionTracking