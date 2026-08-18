import { useState } from 'react';

export default function KeyRow({ label, value, secret = false, revealed, onToggleReveal }) {
  const [copied, setCopied] = useState(false);
  const shown = secret && !revealed ? '•'.repeat(28) : value;

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1600);
    } catch {
      setCopied(false);
    }
  };

  return (
    <div
      className="
        flex
        flex-col
        gap-2
        border-b
        border-[var(--border)]
        py-4
        last:border-b-0
        last:pb-0
        first:pt-0
      "
    >
      <div className="flex items-center justify-between gap-3">
        <p className="m-0 text-[13px] font-semibold text-[var(--text-h)]">
          {label}
        </p>
        <div className="flex gap-2">
          {secret ? (
            <button
              type="button"
              onClick={onToggleReveal}
              className="
                h-[34px]
                rounded-[7px]
                border
                border-[var(--border)]
                bg-transparent
                px-3
                text-[12px]
                font-semibold
                text-[var(--text-h)]
                transition-colors
                hover:border-[var(--brand)]
                hover:text-[var(--brand)]
              "
            >
              {revealed ? 'Hide' : 'Reveal'}
            </button>
          ) : null}
          <button
            type="button"
            onClick={copy}
            className="
              h-[34px]
              rounded-[7px]
              border
              border-[var(--border)]
              bg-transparent
              px-3
              text-[12px]
              font-semibold
              text-[var(--text-h)]
              transition-colors
              hover:border-[var(--brand)]
              hover:text-[var(--brand)]
            "
          >
            {copied ? 'Copied' : 'Copy'}
          </button>
        </div>
      </div>
      <code
        className="
          block
          overflow-x-auto
          rounded-[8px]
          border
          border-[var(--border)]
          bg-[var(--input-bg)]
          px-3
          py-2.5
          font-mono
          text-[13px]
          text-[var(--text-h)]
        "
      >
        {shown}
      </code>
    </div>
  );
}
