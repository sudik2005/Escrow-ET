import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';

import PageCard from '../components/ui/PageCard';
import KeyRow from '../components/ui/KeyRow';
import {
  createSandboxKeys,
  loadOrCreateDeveloperSettings,
  saveDeveloperSettings,
} from '../lib/merchantKeys';

export default function DeveloperSettings() {
  const [settings, setSettings] = useState(null);
  const [revealed, setRevealed] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    setSettings(loadOrCreateDeveloperSettings());
  }, []);

  if (!settings) {
    return null;
  }

  const rotateKeys = () => {
    const confirmed = window.confirm(
      'Rotate keys? The old secret will stop working in this browser.',
    );
    if (!confirmed) {
      return;
    }
    const next = {
      ...settings,
      ...createSandboxKeys(),
    };
    saveDeveloperSettings(next);
    setSettings(next);
    setRevealed(true);
  };

  const saveWebhook = (event) => {
    event.preventDefault();
    saveDeveloperSettings(settings);
    setSaved(true);
    window.setTimeout(() => setSaved(false), 1600);
  };

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
            Merchant portal
          </p>
          <h2 className="mt-2 mb-2 text-[28px] font-semibold tracking-[-0.03em] text-[var(--text-h)]">
            Developer settings
          </h2>
          <p className="m-0 max-w-[560px] text-[14px] leading-[1.6] text-[var(--text)]">
            Use these sandbox keys on your site. Buyers pay into escrow from
            your checkout. Secret key stays on your server only.
          </p>
        </div>
        <Link
          to="/docs"
          className="
            inline-flex
            h-[38px]
            items-center
            justify-center
            rounded-[8px]
            border
            border-[var(--brand)]
            bg-[var(--brand)]
            px-4
            text-[13px]
            font-semibold
            text-white
            no-underline
            transition-colors
            hover:border-[var(--brand-hover)]
            hover:bg-[var(--brand-hover)]
            hover:text-white
          "
        >
          Read docs
        </Link>
      </div>

      <PageCard
        eyebrow="Sandbox"
        title="API keys"
        actions={
          <button
            type="button"
            onClick={rotateKeys}
            className="
              h-[38px]
              rounded-[8px]
              border
              border-[var(--border-strong)]
              bg-[var(--surface)]
              px-4
              text-[13px]
              font-semibold
              text-[var(--text-h)]
              hover:bg-[var(--surface-hover)]
            "
          >
            Rotate keys
          </button>
        }
      >
        <KeyRow
          label="Publishable key"
          value={settings.publicKey}
        />
        <KeyRow
          label="Secret key"
          value={settings.secretKey}
          secret
          revealed={revealed}
          onToggleReveal={() => setRevealed((current) => !current)}
        />
        <p className="mb-0 mt-4 text-[13px] leading-[1.55] text-[var(--text)]">
          Keys are stored in this browser until the merchant API is live.
          They match <code className="text-[var(--text-h)]">MerchantSettings</code> on
          the database: <code className="text-[var(--text-h)]">public_key</code> and{' '}
          <code className="text-[var(--text-h)]">secret_key</code>.
        </p>
      </PageCard>

      <PageCard eyebrow="Callbacks" title="Webhook URL">
        <form onSubmit={saveWebhook} className="flex flex-col gap-3">
          <label className="text-[13px] font-semibold text-[var(--text-h)]" htmlFor="webhook-url">
            HTTPS endpoint for escrow events
          </label>
          <input
            id="webhook-url"
            type="url"
            placeholder="https://your-store.com/webhooks/escrow-et"
            value={settings.webhookUrl}
            onChange={(event) =>
              setSettings((current) => ({
                ...current,
                webhookUrl: event.target.value,
              }))
            }
            className="
              min-h-[42px]
              rounded-[8px]
              border
              border-[var(--border)]
              bg-[var(--input-bg)]
              px-3
              text-[14px]
              text-[var(--text-h)]
              outline-none
              focus:border-[var(--brand)]
              focus:shadow-[0_0_0_3px_var(--brand-soft)]
            "
          />
          <div className="flex items-center gap-3">
            <button
              type="submit"
              className="
                h-[38px]
                rounded-[8px]
                border
                border-[var(--brand)]
                bg-[var(--brand)]
                px-4
                text-[13px]
                font-semibold
                text-white
                hover:border-[var(--brand-hover)]
                hover:bg-[var(--brand-hover)]
              "
            >
              Save webhook
            </button>
            {saved ? (
              <span className="text-[13px] font-semibold text-[var(--success)]">
                Saved
              </span>
            ) : null}
          </div>
        </form>
      </PageCard>
    </div>
  );
}
