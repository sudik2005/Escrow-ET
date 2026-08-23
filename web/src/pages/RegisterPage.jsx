import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import FaydaQrInput from '../components/auth/FaydaQrInput'
import BrandLogo from '../components/ui/BrandLogo'

const ROLES = [
  { id: 'SELLER', label: 'Seller' },
  { id: 'BUYER', label: 'Buyer' },
  { id: 'MERCHANT', label: 'Merchant' },
]

export default function RegisterPage() {
  const { register } = useAuth()
  const navigate = useNavigate()
  const [form, setForm] = useState({
    phoneNumber: '',
    role: 'SELLER',
    rawPayload: '',
  })
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    setError(null)
    if (!form.rawPayload.trim()) {
      setError('Scan or paste your Fayda QR first.')
      return
    }
    setBusy(true)
    try {
      await register({
        phoneNumber: form.phoneNumber,
        role: form.role,
        rawPayload: form.rawPayload.trim(),
      })
      navigate(form.role === 'BUYER' ? '/transactions' : '/dashboard', { replace: true })
    } catch (err) {
      setError(err.message || 'Registration failed. Try again.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] flex items-center justify-center p-4">
      <div className="max-w-sm w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">
        <div className="mb-8 text-center">
          <div className="w-12 h-12 rounded-xl overflow-hidden mx-auto mb-3 border border-[var(--border)]">
            <BrandLogo className="w-full h-full object-contain" />
          </div>
          <h1 className="text-xl font-bold">Create account</h1>
          <p className="text-sm text-[var(--text-muted)] mt-1">
            Scan the back of your Fayda ID. Name, gender, and FAN come from the card.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <FaydaQrInput
            value={form.rawPayload}
            onChange={(rawPayload) => setForm((prev) => ({ ...prev, rawPayload }))}
          />

          <div>
            <label className="block text-sm text-[var(--text)] mb-1.5">Phone number</label>
            <input
              name="phoneNumber"
              type="tel"
              required
              value={form.phoneNumber}
              onChange={(e) => setForm((prev) => ({ ...prev, phoneNumber: e.target.value }))}
              placeholder="09…"
              className="w-full bg-[var(--input-bg)] border border-[var(--border)] rounded-xl px-4 py-3 text-[var(--text-h)] focus:outline-none focus:border-[var(--brand)]"
            />
          </div>

          <div>
            <label className="block text-sm text-[var(--text)] mb-1.5">I am a…</label>
            <div className="grid grid-cols-3 gap-2">
              {ROLES.map((r) => (
                <button
                  key={r.id}
                  type="button"
                  onClick={() => setForm((prev) => ({ ...prev, role: r.id }))}
                  className={`py-3 rounded-xl border text-sm font-semibold transition-colors ${
                    form.role === r.id
                      ? 'bg-[var(--brand)] border-[var(--brand)] text-white'
                      : 'bg-[var(--input-bg)] border-[var(--border)] text-[var(--text)]'
                  }`}
                >
                  {r.label}
                </button>
              ))}
            </div>
          </div>

          {error && (
            <p className="text-sm text-red-500 bg-red-50 dark:bg-red-900/20 rounded-lg px-3 py-2">
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={busy}
            className="w-full bg-[var(--brand)] hover:bg-[var(--brand-hover)] disabled:opacity-50 text-white font-semibold py-3.5 rounded-xl transition-colors mt-2"
          >
            {busy ? 'Creating account…' : 'Create Account'}
          </button>
        </form>

        <p className="text-center text-sm text-[var(--text-muted)] mt-6">
          Already have an account?{' '}
          <Link to="/login" className="text-[var(--brand)] font-semibold hover:underline">
            Sign in
          </Link>
        </p>
      </div>
    </div>
  )
}
