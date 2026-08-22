import { Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

function Field({ label, value }) {
  return (
    <div className="rounded-[12px] border border-[var(--border)] bg-[var(--surface)] px-4 py-3">
      <p className="m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-[var(--brand)]">
        {label}
      </p>
      <p className="mt-1 mb-0 text-[15px] text-[var(--text-h)]">
        {value || '—'}
      </p>
    </div>
  )
}

export default function Profile() {
  const { user, logout } = useAuth()

  return (
    <div className="mx-auto flex max-w-[720px] flex-col gap-6">
      <div>
        <p className="m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-[var(--brand)]">
          Account
        </p>
        <h2 className="mt-2 mb-2 text-[28px] font-semibold tracking-[-0.03em] text-[var(--text-h)]">
          Profile
        </h2>
        <p className="m-0 max-w-[560px] text-[14px] leading-[1.6] text-[var(--text)]">
          Details from your Fayda-backed Escrow ET account.
        </p>
      </div>

      <div className="grid gap-3 sm:grid-cols-2">
        <Field label="Username" value={user?.username} />
        <Field label="Role" value={user?.role} />
        <Field label="Phone" value={user?.phone_number} />
        <Field
          label="KYC"
          value={user?.kyc_verified ? 'Verified' : 'Not verified'}
        />
        <Field label="Email" value={user?.email} />
        <Field
          label="Joined"
          value={
            user?.created_at
              ? new Date(user.created_at).toLocaleDateString('en-ET', {
                  day: '2-digit',
                  month: 'short',
                  year: 'numeric',
                })
              : ''
          }
        />
      </div>

      <div className="flex flex-wrap gap-3">
        <Link
          to="/dashboard"
          className="inline-flex h-[38px] items-center justify-center rounded-[8px] bg-[var(--brand)] px-4 text-[13px] font-semibold text-white no-underline"
        >
          Go to dashboard
        </Link>
        <Link
          to="/settings/developer"
          className="inline-flex h-[38px] items-center justify-center rounded-[8px] border border-[var(--border)] px-4 text-[13px] font-semibold text-[var(--text-h)] no-underline"
        >
          Developer settings
        </Link>
        <button
          type="button"
          onClick={logout}
          className="inline-flex h-[38px] items-center justify-center rounded-[8px] border border-[var(--border)] px-4 text-[13px] font-semibold text-[var(--text-h)]"
        >
          Log out
        </button>
      </div>
    </div>
  )
}
