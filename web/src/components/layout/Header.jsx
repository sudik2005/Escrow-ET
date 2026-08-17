// web/src/components/layout/Header.jsx

import { useLocation } from 'react-router-dom';
import { useTheme } from '../../context/useTheme';

const routeTitles = {
  '/': 'Dashboard',
  '/transactions': 'Transactions',
  '/payment-links': 'Payment Links',
  '/disputes': 'Disputes',
  '/settings/developer': 'Developer Settings',
};

const Header = ({ sidebarOpen, setSidebarOpen }) => {
  const { theme, toggleTheme } = useTheme();
  const location = useLocation();

  const currentTitle =
    routeTitles[location.pathname] || 'Dashboard';

  return (
    <header
      className="
        sticky
        top-0
        z-30
        flex
        min-h-[72px]
        w-full
        items-center
        justify-between
        overflow-visible
        border-b
        border-[var(--border)]
        bg-[var(--surface)]
        px-7
        py-2
        text-[var(--text)]
        transition-colors
        duration-200
      "
    >
      {/* =====================================================
          LEFT SIDE
      ====================================================== */}
      <div
        className="
          flex
          min-w-0
          flex-1
          items-center
          gap-4
          overflow-visible
        "
      >
        {/* Mobile / Tablet menu */}
        <button
          type="button"
          onClick={setSidebarOpen}
          className="
            inline-flex
            h-[38px]
            w-[38px]
            shrink-0
            items-center
            justify-center
            rounded-[7px]
            border
            border-[var(--border)]
            bg-transparent
            text-[var(--text-h)]
            transition-all
            duration-150
            hover:border-[var(--brand)]
            hover:bg-[var(--surface-hover)]
            hover:text-[var(--brand)]
            focus-visible:outline
            focus-visible:outline-2
            focus-visible:outline-[var(--brand)]
            focus-visible:outline-offset-2
            lg:hidden
          "
          aria-label={
            sidebarOpen
              ? 'Close navigation'
              : 'Open navigation'
          }
          aria-expanded={sidebarOpen}
          title={
            sidebarOpen
              ? 'Close navigation'
              : 'Open navigation'
          }
        >
          <span
            className="
              flex
              items-center
              justify-center
              text-[22px]
              leading-none
            "
            aria-hidden="true"
          >
            ☰
          </span>
        </button>

        {/* =================================================
            TITLE GROUP

            Explicit padding + line heights prevent the
            Merchant Portal eyebrow from being clipped.
        ================================================== */}
        <div
          className="
            flex
            min-h-[56px]
            min-w-0
            flex-col
            justify-center
            overflow-visible
            py-[7px]
          "
        >
          <span
            className="
              block
              h-[14px]
              overflow-visible
              whitespace-nowrap
              text-[10px]
              font-semibold
              uppercase
              leading-[14px]
              tracking-[1px]
              text-[var(--text)]
              opacity-80
          "
          >
            Merchant Portal
          </span>

          <h1
            className="
              m-0
              block
              max-w-full
              overflow-hidden
              text-ellipsis
              whitespace-nowrap
              text-[20px]
              font-semibold
              leading-[25px]
              tracking-[-0.3px]
              text-[var(--text-h)]
            "
          >
            {currentTitle}
          </h1>
        </div>
      </div>

      {/* =====================================================
          RIGHT SIDE
      ====================================================== */}
      <div
        className="
          flex
          shrink-0
          items-center
          gap-[7px]
        "
      >
        {/* Theme toggle */}
        <button
          type="button"
          onClick={toggleTheme}
          className="
            inline-flex
            h-[38px]
            w-[38px]
            items-center
            justify-center
            rounded-[7px]
            border
            border-transparent
            bg-transparent
            text-[17px]
            leading-none
            text-[var(--text)]
            transition-all
            duration-150
            hover:border-[var(--brand)]
            hover:bg-[var(--surface-hover)]
            hover:text-[var(--brand)]
            focus-visible:outline
            focus-visible:outline-2
            focus-visible:outline-[var(--brand)]
            focus-visible:outline-offset-2
          "
          aria-label={
            theme === 'dark'
              ? 'Switch to light mode'
              : 'Switch to dark mode'
          }
          aria-pressed={theme === 'dark'}
          title={
            theme === 'dark'
              ? 'Switch to light mode'
              : 'Switch to dark mode'
          }
        >
          <span aria-hidden="true">
            {theme === 'dark' ? '☀' : '☾'}
          </span>
        </button>

        {/* Notifications */}
        <button
          type="button"
          className="
            inline-flex
            h-[38px]
            w-[38px]
            items-center
            justify-center
            rounded-[7px]
            border
            border-transparent
            bg-transparent
            text-[17px]
            leading-none
            text-[var(--text)]
            transition-all
            duration-150
            hover:border-[var(--border)]
            hover:bg-[var(--surface-hover)]
            hover:text-[var(--brand)]
            focus-visible:outline
            focus-visible:outline-2
            focus-visible:outline-[var(--brand)]
            focus-visible:outline-offset-2
          "
          aria-label="Notifications"
          title="Notifications"
        >
          <span aria-hidden="true">🔔</span>
        </button>

        {/* Profile */}
        <button
          type="button"
          className="
            inline-flex
            h-[38px]
            w-[38px]
            items-center
            justify-center
            rounded-[7px]
            border
            border-transparent
            bg-transparent
            text-[17px]
            leading-none
            text-[var(--text)]
            transition-all
            duration-150
            hover:border-[var(--border)]
            hover:bg-[var(--surface-hover)]
            hover:text-[var(--brand)]
            focus-visible:outline
            focus-visible:outline-2
            focus-visible:outline-[var(--brand)]
            focus-visible:outline-offset-2
          "
          aria-label="Profile"
          title="Profile"
        >
          <span aria-hidden="true">👤</span>
        </button>
      </div>
    </header>
  );
};

export default Header;