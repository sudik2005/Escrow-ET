import { Link } from 'react-router-dom';

import PageCard from '../components/ui/PageCard';
import { BASE_URL } from '../lib/api';

const sampleCreate = `curl -X POST ${BASE_URL}/escrow/create/ \\
  -H "Authorization: Token YOUR_AUTH_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "buyer_phone": "0911123456",
    "item_name": "Used iPhone",
    "amount": "4500.00",
    "verification_pin": "99119911"
  }'`;

const samplePay = `curl -X POST ${BASE_URL}/escrow/<contract-id>/pay/ \\
  -H "Authorization: Token BUYER_AUTH_TOKEN"`;

export default function DeveloperDocs() {
  return (
    <div className="mx-auto flex max-w-[880px] flex-col gap-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <p className="m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-[var(--brand)]">
            Escrow API
          </p>
          <h2 className="mt-2 mb-2 text-[28px] font-semibold tracking-[-0.03em] text-[var(--text-h)]">
            Integration docs
          </h2>
          <p className="m-0 max-w-[620px] text-[14px] leading-[1.6] text-[var(--text)]">
            The live API is <code className="text-[var(--text-h)]">{BASE_URL}</code>.
            Sign in with Fayda, then send <code className="text-[var(--text-h)]">Authorization: Token …</code>.
          </p>
        </div>
        <Link
          to="/settings/developer"
          className="inline-flex h-[38px] items-center justify-center rounded-[8px] border border-[var(--border-strong)] bg-[var(--surface)] px-4 text-[13px] font-semibold text-[var(--text-h)] no-underline hover:bg-[var(--surface-hover)]"
        >
          Back to keys
        </Link>
      </div>

      <PageCard eyebrow="Auth" title="How to authenticate">
        <ul className="m-0 list-disc space-y-2 pl-5 text-[14px] leading-[1.6] text-[var(--text)]">
          <li>
            Register: <code className="text-[var(--text-h)]">POST /auth/register/</code> with
            Fayda <code className="text-[var(--text-h)]">raw_payload</code>, phone, and role.
          </li>
          <li>
            Login: <code className="text-[var(--text-h)]">POST /auth/login/</code> with
            Fayda payload or username/password.
          </li>
          <li>
            Session token: <code className="text-[var(--text-h)]">Authorization: Token &lt;key&gt;</code>
          </li>
          <li>
            Merchant <code className="text-[var(--text-h)]">pk_live_</code> /{' '}
            <code className="text-[var(--text-h)]">sk_live_</code> keys are stored on
            your account at <code className="text-[var(--text-h)]">GET /merchant/settings/</code>.
          </li>
        </ul>
      </PageCard>

      <PageCard eyebrow="Flow" title="Create an escrow">
        <p className="mt-0 text-[14px] leading-[1.6] text-[var(--text)]">
          Seller or merchant only. Status starts at{' '}
          <code className="text-[var(--text-h)]">PENDING_PAYMENT</code>, then{' '}
          <code className="text-[var(--text-h)]">FUNDED</code> →{' '}
          <code className="text-[var(--text-h)]">IN_TRANSIT</code> →{' '}
          <code className="text-[var(--text-h)]">COMPLETED</code>.
        </p>
        <pre className="m-0 overflow-x-auto rounded-[8px] border border-[var(--border)] bg-[var(--input-bg)] p-4 font-mono text-[12px] leading-[1.55] text-[var(--text-h)]">
          {sampleCreate}
        </pre>
      </PageCard>

      <PageCard eyebrow="Checkout" title="Collect payment">
        <p className="mt-0 text-[14px] leading-[1.6] text-[var(--text)]">
          Share <code className="text-[var(--text-h)]">/checkout/&lt;id&gt;</code>. The
          buyer calls pay and is sent to Chapa. The API returns{' '}
          <code className="text-[var(--text-h)]">payment_link</code>.
        </p>
        <pre className="m-0 overflow-x-auto rounded-[8px] border border-[var(--border)] bg-[var(--input-bg)] p-4 font-mono text-[12px] leading-[1.55] text-[var(--text-h)]">
          {samplePay}
        </pre>
      </PageCard>

      <PageCard eyebrow="Webhooks" title="Events we send">
        <p className="mt-0 text-[14px] leading-[1.6] text-[var(--text)]">
          Set your URL on Developer settings. Chapa posts to{' '}
          <code className="text-[var(--text-h)]">POST /webhooks/chapa/</code> when
          the buyer pays. Save your store URL on{' '}
          <code className="text-[var(--text-h)]">PATCH /merchant/settings/</code>.
        </p>
      </PageCard>
    </div>
  );
}
