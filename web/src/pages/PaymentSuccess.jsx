import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { Check } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import * as api from '../lib/api'

function PaymentSuccess() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const contractId = searchParams.get('id')
  const { token } = useAuth()
  const [contract, setContract] = useState(null)

  useEffect(() => {
    if (!token || !contractId) return
    api.getContract(token, contractId).then(setContract).catch(() => {})
  }, [token, contractId])

  const total = contract ? Number(contract.amount) : null
  const funded = contract && ['FUNDED', 'IN_TRANSIT', 'COMPLETED'].includes(contract.status)

  const nextSteps = [
    'Seller will deliver your order',
    'After you receive it, show the QR code',
    'Confirm delivery with the QR or PIN',
    'Funds are released to the seller',
  ]

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">
        <div className="w-16 h-16 bg-[var(--brand)] rounded-full flex items-center justify-center mx-auto mb-4">
          <Check className="w-8 h-8 text-white" strokeWidth={3} />
        </div>

        <h1 className="text-xl font-bold mb-1">
          {funded ? 'Payment successful' : 'Payment started'}
        </h1>
        <p className="text-2xl font-bold text-[var(--brand)] mb-4">
          {total != null ? `${total.toFixed(2)} ETB` : 'Escrow ET'}
        </p>
        <p className="text-sm text-[var(--text-muted)] mb-6">
          {funded
            ? 'Your payment is now safely held in escrow. The seller has been notified.'
            : 'If you paid on Chapa, funds lock as soon as the webhook arrives. Refresh this page in a moment.'}
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
          onClick={() =>
            navigate(contractId ? `/transactions?id=${contractId}` : '/transactions')
          }
          className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] text-white font-semibold py-3.5 rounded-xl transition-colors"
        >
          View transaction
        </button>
      </div>
    </div>
  )
}

export default PaymentSuccess
