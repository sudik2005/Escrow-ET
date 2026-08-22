import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';

import PageCard from '../components/ui/PageCard';
import KeyRow from '../components/ui/KeyRow';
import { useAuth } from '../context/AuthContext';
import * as api from '../lib/api';

function mapSettings(data) {
  return {
    publicKey: data.public_key,
    secretKey: data.secret_key,
    webhookUrl: data.webhook_url || '',
  };
}

export default function DeveloperSettings() {
  const { token } = useAuth();
  const [settings, setSettings] = useState(null);
  const [error, setError] = useState(null);
  const [revealed, setRevealed] = useState(false);
  const [saved, setSaved] = useState(false);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!token) return;
    api
      .getMerchantSettings(token)
      .then((data) => setSettings(mapSettings(data)))
      .catch((err) => setError(err.message || 'Could not load API keys.'));
  }, [token]);

  const rotateKeys = async () => {
    const confirmed = window.confirm(
      'Rotate keys? The old secret will stop working immediately.',
    );
    if (!confirmed) return;
    setBusy(true);
    setError(null);
    try {
      const data = await api.rotateMerchantKeys(token);
      setSettings(mapSettings(data));
      setRevealed(true);
    } catch (err) {
      setError(err.message || 'Could not rotate keys.');
    } finally {
      setBusy(false);
    }
  };

  const saveWebhook = async (event) => {
    event.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const data = await api.updateMerchantSettings(token, {
        webhook_url: settings.webhookUrl || null,
      });
      setSettings(mapSettings(data));
      setSaved(true);
      window.setTimeout(() => setSaved(false), 1600);
    } catch (err) {
      setError(err.message || 'Could not save webhook.');
    } finally {
      setBusy(false);
    }
  };

  if (error && !settings) {
    return (
      <div className="mx-auto max-w-[880px]">
        <p className="text-[14px] text-red-500">{error}</p>
      </div>
    );
  }

  if (!settings) {
    return (
      <div className="flex justify-center py-12">
        <div className="w-8 h-8 border-2 border-[var(--brand)] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="mx-auto flex max-w-[880px] flex-col gap-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <p className="m-0 text-[11px] font-bold uppercase tracking-[0.12em] text-[var(--brand)]">
            Merchant portal
          </p>
          <h2 className="mt-2 mb-2 text-[28px] font-semibold tracking-[-0.03em] text-[var(--text-h)]">
            Developer settings
          </h2>
          <p className="m-0 max-w-[560px] text-[14px] leading-[1.6] text-[var(--text)]">
            These keys live in Postgres on <code>MerchantSettings</code>. Keep the
            secret on your server only.
          </p>
        </div>
        <Link
          to="/docs"
          className="inline-flex h-[38px] items-center justify-center rounded-[8px] border border-[var(--brand)] bg-[var(--brand)] px-4 text-[13px] font-semibold text-white no-underline hover:bg-[var(--brand-hover)]"
        >
          Read docs
        </Link>
      </div>

      {error && <p className="m-0 text-[13px] text-red-500">{error}</p>}

      <PageCard
        eyebrow="Live keys"
        title="API keys"
        actions={
          <button
            type="button"
            onClick={rotateKeys}
            disabled={busy}
            className="h-[38px] rounded-[8px] border border-[var(--border-strong)] bg-[var(--surface)] px-4 text-[13px] font-semibold text-[var(--text-h)] hover:bg-[var(--surface-hover)] disabled:opacity-50"
          >
            Rotate keys
          </button>
        }
      >
        <KeyRow label="Publishable key" value={settings.publicKey} />
        <KeyRow
          label="Secret key"
          value={settings.secretKey}
          secret
          revealed={revealed}
          onToggleReveal={() => setRevealed((current) => !current)}
        />
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
            className="min-h-[42px] rounded-[8px] border border-[var(--border)] bg-[var(--input-bg)] px-3 text-[14px] text-[var(--text-h)] outline-none focus:border-[var(--brand)]"
          />
          <div className="flex items-center gap-3">
            <button
              type="submit"
              disabled={busy}
              className="h-[38px] rounded-[8px] border border-[var(--brand)] bg-[var(--brand)] px-4 text-[13px] font-semibold text-white hover:bg-[var(--brand-hover)] disabled:opacity-50"
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
