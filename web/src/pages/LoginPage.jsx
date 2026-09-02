import { useState } from 'react'
import { useNavigate, useLocation, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import FaydaQrInput from '../components/auth/FaydaQrInput'
import BrandLogo from '../components/ui/BrandLogo'

export default function LoginPage() {
  const { login, loginWithFayda } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const from = location.state?.from?.pathname
  const [mode, setMode] = useState('password')
  const [form, setForm] = useState({ username: '', password: '' })
  const [rawPayload, setRawPayload] = useState('')
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)

  function goNext(user) {
    if (user?.role === 'ADMIN') {
      navigate('/admin', { replace: true })
      return
    }
    const fallback = user?.role === 'BUYER' ? '/transactions' : '/dashboard'
    navigate(from || fallback, { replace: true })
  }

  async function handlePassword(e) {
    e.preventDefault()
    setError(null)
    setBusy(true)
    try {
      const user = await login(form.username.trim(), form.password)
      goNext(user)
    } catch (err) {
      setError(err.message || 'Login failed. Check your credentials.')
    } finally {
      setBusy(false)
    }
  }

  async function handleFayda(e) {
    e.preventDefault()
    setError(null)
    if (!rawPayload.trim()) {
      setError('Scan or paste your Fayda QR first.')
      return
    }
    setBusy(true)
    try {
      const user = await loginWithFayda(rawPayload.trim())
      goNext(user)
    } catch (err) {
      setError(err.message || 'Fayda sign-in failed.')
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
          <h1 className="text-xl font-bold">Sign in</h1>
          <p className="text-sm text-[var(--text-muted)] mt-1">Welcome back to Escrow ET</p>
        </div>

        <div className="grid grid-cols-2 gap-2 mb-6">
          {[
            { id: 'password', label: 'Password' },
            { id: 'fayda', label: 'Fayda QR' },
          ].map((tab) => (
            <button
              key={tab.id}
              type="button"
              onClick={() => {
                setMode(tab.id)
                setError(null)
              }}
              className={`py-2.5 rounded-xl border text-sm font-semibold ${
                mode === tab.id
                  ? 'bg-[var(--brand)] border-[var(--brand)] text-white'
                  : 'bg-[var(--input-bg)] border-[var(--border)] text-[var(--text)]'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {mode === 'password' ? (
          <form onSubmit={handlePassword} className="space-y-4">
            <div>
              <label className="block text-sm text-[var(--text)] mb-1.5">Username</label>
              <input
                name="username"
                type="text"
                required
                autoComplete="username"
                value={form.username}
                onChange={(e) => setForm((prev) => ({ ...prev, username: e.target.value }))}
                placeholder="your_username"
                className="w-full bg-[var(--input-bg)] border border-[var(--border)] rounded-xl px-4 py-3 text-[var(--text-h)] focus:outline-none focus:border-[var(--brand)]"
              />
            </div>
            <div>
              <label className="block text-sm text-[var(--text)] mb-1.5">Password</label>
              <input
                name="password"
                type="password"
                required
                autoComplete="current-password"
                value={form.password}
                onChange={(e) => setForm((prev) => ({ ...prev, password: e.target.value }))}
                placeholder="••••••••"
                className="w-full bg-[var(--input-bg)] border border-[var(--border)] rounded-xl px-4 py-3 text-[var(--text-h)] focus:outline-none focus:border-[var(--brand)]"
              />
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
              {busy ? 'Signing in…' : 'Sign In'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleFayda} className="space-y-4">
            <FaydaQrInput value={rawPayload} onChange={setRawPayload} />
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
              {busy ? 'Signing in…' : 'Sign in with Fayda'}
            </button>
          </form>
        )}

        <p className="text-center text-sm text-[var(--text-muted)] mt-6">
          No account?{' '}
          <Link to="/register" className="text-[var(--brand)] font-semibold hover:underline">
            Create one
          </Link>
        </p>
      </div>
    </div>
  )
}
