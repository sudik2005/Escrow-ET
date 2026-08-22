import { useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { QRCodeSVG } from 'qrcode.react'

function QRCodeView() {
  const navigate = useNavigate()

  // TODO: replace with a real GET /escrow/<id>/ response from Django.
  // delivery_qr_token is the real field name the backend already returns.
  const transaction = {
    id: 'ET-10294',
    amount: 500.0,
    delivery_qr_token: 'a1b2c3d4-mock-token',
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8 text-center">
        <div className="flex items-center gap-3 mb-6 text-left">
          <button type="button" aria-label="Go back" onClick={() => navigate(-1)}>
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Delivery</h1>
        </div>

        <h2 className="text-lg font-bold mb-2">Show this QR code to the delivery person</h2>
        <p className="text-sm text-[var(--text-muted)] mb-6">
          This code is unique to your transaction and will expire after use.
        </p>

        <div className="bg-white rounded-2xl p-6 inline-block mb-6">
          <QRCodeSVG value={transaction.delivery_qr_token} size={200} />
        </div>

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

        {/* TEMP: dev-only shortcut to preview the next screen without a real scan.
            Remove once real-time status updates (polling or webhooks) are wired up. */}
        <button
          onClick={() => navigate('/delivery-verified')}
          className="text-xs text-[var(--text-muted)] underline"
        >
          (Dev only: simulate delivery scan →)
        </button>
      </div>
    </div>
  )
}

export default QRCodeView