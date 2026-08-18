import { Link } from 'react-router-dom';

import PageCard from '../components/ui/PageCard';

const sampleCreate = `curl -X POST https://api.escrow-et.et/api/escrow/ \\
  -H "Authorization: Bearer YOUR_SECRET_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "seller_id": "uuid-of-seller",
    "item_name": "Used iPhone",
    "amount": "4500.00",
    "currency": "ETB"
  }'`;

const sampleCheckout = `escrowEt.checkout({
  publicKey: "YOUR_PUBLISHABLE_KEY",
  escrowId: "uuid-from-create",
  onSuccess: () => window.location.reload(),
});`;

export default function DeveloperDocs() {
  return (
    <div className="mx-auto flex max-w-[880px] flex-col gap-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <p
            className="
              m-0
              text-[11px]
              font-bold
              uppercase
              tracking-[0.12em]
              text-[var(--brand)]
            "
          >
            Merchant API
          </p>
          <h2 className="mt-2 mb-2 text-[28px] font-semibold tracking-[-0.03em] text-[var(--text-h)]">
            Integration docs
          </h2>
          <p className="m-0 max-w-[620px] text-[14px] leading-[1.6] text-[var(--text)]">
            Put the publishable key in your storefront. Keep the secret key on
            your server. Funds stay in escrow until the buyer confirms delivery
            with QR or PIN.
          </p>
        </div>
        <Link
          to="/settings/developer"
          className="
            inline-flex
            h-[38px]
            items-center
            justify-center
            rounded-[8px]
            border
            border-[var(--border-strong)]
            bg-[var(--surface)]
            px-4
            text-[13px]
            font-semibold
            text-[var(--text-h)]
            no-underline
            hover:bg-[var(--surface-hover)]
          "
        >
          Back to keys
        </Link>
      </div>

      <PageCard eyebrow="Keys" title="Authenticate">
        <ul className="m-0 list-disc space-y-2 pl-5 text-[14px] leading-[1.6] text-[var(--text)]">
          <li>
            <strong className="text-[var(--text-h)]">Publishable key</strong> — safe in the browser. Starts with{' '}
            <code className="text-[var(--text-h)]">pk_test_</code>.
          </li>
          <li>
            <strong className="text-[var(--text-h)]">Secret key</strong> — server only. Starts with{' '}
            <code className="text-[var(--text-h)]">sk_test_</code>. Send it as{' '}
            <code className="text-[var(--text-h)]">Authorization: Bearer sk_test_…</code>
          </li>
        </ul>
      </PageCard>

      <PageCard eyebrow="Flow" title="Create an escrow">
        <p className="mt-0 text-[14px] leading-[1.6] text-[var(--text)]">
          Status starts at <code className="text-[var(--text-h)]">PENDING_PAYMENT</code>,
          then <code className="text-[var(--text-h)]">FUNDED</code> →{' '}
          <code className="text-[var(--text-h)]">IN_TRANSIT</code> →{' '}
          <code className="text-[var(--text-h)]">DELIVERED_UNVERIFIED</code> →{' '}
          <code className="text-[var(--text-h)]">COMPLETED</code>.
        </p>
        <pre
          className="
            m-0
            overflow-x-auto
            rounded-[8px]
            border
            border-[var(--border)]
            bg-[var(--input-bg)]
            p-4
            font-mono
            text-[12px]
            leading-[1.55]
            text-[var(--text-h)]
          "
        >
          {sampleCreate}
        </pre>
      </PageCard>

      <PageCard eyebrow="Checkout" title="Collect payment">
        <p className="mt-0 text-[14px] leading-[1.6] text-[var(--text)]">
          Buyer pays through Chapa sandbox. Do not take the money yourself.
          Escrow ET holds it until delivery is confirmed.
        </p>
        <pre
          className="
            m-0
            overflow-x-auto
            rounded-[8px]
            border
            border-[var(--border)]
            bg-[var(--input-bg)]
            p-4
            font-mono
            text-[12px]
            leading-[1.55]
            text-[var(--text-h)]
          "
        >
          {sampleCheckout}
        </pre>
      </PageCard>

      <PageCard eyebrow="Webhooks" title="Events we send">
        <p className="mt-0 text-[14px] leading-[1.6] text-[var(--text)]">
          Set your URL on Developer settings. We POST JSON when status changes:
        </p>
        <ul className="mb-0 list-disc space-y-2 pl-5 text-[14px] leading-[1.6] text-[var(--text)]">
          <li><code className="text-[var(--text-h)]">escrow.funded</code></li>
          <li><code className="text-[var(--text-h)]">escrow.released</code></li>
          <li><code className="text-[var(--text-h)]">escrow.refunded</code></li>
          <li><code className="text-[var(--text-h)]">escrow.disputed</code></li>
        </ul>
      </PageCard>
    </div>
  );
}
