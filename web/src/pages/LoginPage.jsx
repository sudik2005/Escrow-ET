import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [form, setForm] = useState({ username: '', password: '' })
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)

  function handleChange(e) {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }))
  }

  async function handleSubmit(e) {
    e.preventDefault()
    setError(null)
    setBusy(true)
    try {
      await login(form.username, form.password)
      navigate('/dashboard', { replace: true })
    } catch (err) {
      setError(err.message || 'Login failed. Check your credentials.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-h)] flex items-center justify-center p-4">
      <div className="max-w-sm w-full bg-[var(--surface)] rounded-2xl shadow-[var(--shadow-card)] p-8">
        <div className="mb-8 text-center">
          <div className="w-10 h-10 bg-[var(--brand)] rounded-xl flex items-center justify-center mx-auto mb-3">
            <span className="text-white font-bold text-sm">ET</span>
          </div>
          <h1 className="text-xl font-bold">Sign in</h1>
          <p className="text-sm text-[var(--text-muted)] mt-1">Welcome back to Escrow ET</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-[var(--text)] mb-1.5">Username</label>
            <input
              name="username"
              type="text"
              required
              autoComplete="username"
              value={form.username}
              onChange={handleChange}
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
              onChange={handleChange}
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
