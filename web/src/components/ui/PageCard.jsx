export default function PageCard({ eyebrow, title, children, actions }) {
  return (
    <section
      className="
        relative
        overflow-hidden
        rounded-[10px]
        border
        border-[var(--border)]
        bg-[var(--surface)]
        shadow-[var(--shadow-md)]
      "
    >
      <div className="h-[3px] bg-[var(--brand)]" />
      <div className="px-7 py-7 max-sm:px-5 max-sm:py-6">
        <div className="mb-5 flex flex-wrap items-start justify-between gap-4">
          <div className="min-w-0">
            {eyebrow ? (
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
                {eyebrow}
              </p>
            ) : null}
            {title ? (
              <h2
                className="
                  m-0
                  mt-2
                  text-[22px]
                  font-semibold
                  tracking-[-0.02em]
                  text-[var(--text-h)]
                "
              >
                {title}
              </h2>
            ) : null}
          </div>
          {actions}
        </div>
        {children}
      </div>
    </section>
  );
}
